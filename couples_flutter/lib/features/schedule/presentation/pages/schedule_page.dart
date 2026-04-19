import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../../../core/ui/couple_ui.dart';
import '../../domain/entities/course.dart';
import '../state/schedule_controller.dart';
import '../state/schedule_state.dart';
import 'schedule_course_form_page.dart';

class SchedulePage extends ConsumerStatefulWidget {
  const SchedulePage({super.key});

  static const List<String> _weekdayLabels = <String>[
    '周一',
    '周二',
    '周三',
    '周四',
    '周五',
    '周六',
    '周日',
  ];

  @override
  ConsumerState<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends ConsumerState<SchedulePage>
    with WidgetsBindingObserver {
  Future<void> _refreshSchedule() async {
    await ref.read(scheduleControllerProvider.notifier).load();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(scheduleControllerProvider.notifier).load();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      ref.read(scheduleControllerProvider.notifier).load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(scheduleControllerProvider);
    final controller = ref.read(scheduleControllerProvider.notifier);
    final allowCreate = state.viewMode != ScheduleViewMode.partner;

    return Scaffold(
      backgroundColor: CoupleUi.pageBackground,
      appBar: AppBar(
        title: const Text('双人课表'),
        backgroundColor: CoupleUi.surface,
        foregroundColor: CoupleUi.textPrimary,
      ),
      floatingActionButton: allowCreate
          ? FloatingActionButton.extended(
              onPressed: () async {
                final created = await Navigator.of(context).push<bool>(
                  MaterialPageRoute<bool>(
                    builder: (_) => const ScheduleCourseFormPage(),
                  ),
                );
                if (created == true) {
                  await controller.load();
                }
              },
              backgroundColor: CoupleUi.primary,
              label: const Text('新建课程'),
              icon: const Icon(Icons.add),
            )
          : null,
      body: SafeArea(
        child: DecoratedBox(
          decoration: CoupleUi.pageBackgroundDecoration(),
          child: RefreshIndicator(
            onRefresh: _refreshSchedule,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: SizedBox(
                      height: constraints.maxHeight,
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                            child: _ScheduleTopBar(
                              currentWeek: state.currentWeek,
                              mode: state.viewMode,
                              onPrevWeek: controller.previousWeek,
                              onNextWeek: controller.nextWeek,
                              onModeChanged: controller.setViewMode,
                            ),
                          ),
                          if (state.errorMessage != null && state.errorMessage!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(
                                state.errorMessage!,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: state.viewMode == ScheduleViewMode.compare
                                  ? Column(
                                      children: <Widget>[
                                        Expanded(
                                          child: _TimetableBoard(
                                            title: '我的课表',
                                            courses: state.visibleCoursesForMode(
                                              ScheduleViewMode.mine,
                                            ),
                                            weekdayLabels: SchedulePage._weekdayLabels,
                                            onCourseTap: (course) => _handleCourseTap(
                                              context,
                                              controller,
                                              course,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Expanded(
                                          child: _TimetableBoard(
                                            title: 'TA 的课表',
                                            courses: state.visibleCoursesForMode(
                                              ScheduleViewMode.partner,
                                            ),
                                            weekdayLabels: SchedulePage._weekdayLabels,
                                            onCourseTap: (course) => _handleCourseTap(
                                              context,
                                              controller,
                                              course,
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  : _TimetableBoard(
                                      title: state.viewMode == ScheduleViewMode.mine
                                          ? '我的课表'
                                          : 'TA 的课表',
                                      courses: state.visibleCoursesForMode(state.viewMode),
                                      weekdayLabels: SchedulePage._weekdayLabels,
                                      onCourseTap: (course) =>
                                          _handleCourseTap(context, controller, course),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleCourseTap(
    BuildContext context,
    ScheduleController controller,
    Course course,
  ) async {
    if (course.owner == CourseOwner.partner) {
      await showModalBottomSheet<void>(
        context: context,
        backgroundColor: CoupleUi.surface,
        builder: (context) {
          return _PartnerCourseSheet(course: course);
        },
      );
      return;
    }

    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => ScheduleCourseFormPage(initialCourse: course),
      ),
    );
    if (changed == true) {
      await controller.load();
    }
  }
}

class _ScheduleTopBar extends StatelessWidget {
  const _ScheduleTopBar({
    required this.currentWeek,
    required this.mode,
    required this.onPrevWeek,
    required this.onNextWeek,
    required this.onModeChanged,
  });

  final int currentWeek;
  final ScheduleViewMode mode;
  final VoidCallback onPrevWeek;
  final VoidCallback onNextWeek;
  final ValueChanged<ScheduleViewMode> onModeChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: CoupleUi.sectionCardDecoration(),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              _WeekIconButton(icon: Icons.chevron_left, onTap: onPrevWeek),
              Expanded(
                child: Center(
                  child: Text(
                    '第 $currentWeek 周',
                    style: const TextStyle(
                      color: CoupleUi.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              _WeekIconButton(icon: Icons.chevron_right, onTap: onNextWeek),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ScheduleViewMode.values.map((item) {
              final selected = mode == item;
              String label;
              switch (item) {
                case ScheduleViewMode.mine:
                  label = '我的';
                case ScheduleViewMode.partner:
                  label = 'TA 的';
                case ScheduleViewMode.compare:
                  label = '对比';
              }
              return ChoiceChip(
                selected: selected,
                onSelected: (_) => onModeChanged(item),
                label: Text(label),
                selectedColor: const Color(0xFFF6E8EE),
                backgroundColor: CoupleUi.surfaceMuted,
                side: BorderSide(
                  color: selected
                      ? CoupleUi.primaryStrong.withValues(alpha: 0.4)
                      : CoupleUi.sectionBorder,
                ),
                labelStyle: TextStyle(
                  color: selected ? CoupleUi.primaryStrong : CoupleUi.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _WeekIconButton extends StatelessWidget {
  const _WeekIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: CoupleUi.surfaceMuted,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: CoupleUi.sectionBorder),
        ),
        child: Icon(icon, color: CoupleUi.textPrimary, size: 20),
      ),
    );
  }
}

class _TimetableBoard extends StatelessWidget {
  const _TimetableBoard({
    required this.title,
    required this.courses,
    required this.weekdayLabels,
    required this.onCourseTap,
  });

  final String title;
  final List<Course> courses;
  final List<String> weekdayLabels;
  final ValueChanged<Course> onCourseTap;

  static const int _axisStartMinute = 7 * 60;
  static const int _axisEndMinute = 23 * 60;
  static const double _hourHeight = 64;
  static const double _timeColWidth = 58;
  static const double _dayColWidth = 104;
  static const double _headerHeight = 34;

  Color _courseColor(Course course) {
    const palette = <String, Color>{
      '#E88EA3': Color(0xFFE88EA3),
      '#6A9DE8': Color(0xFF6A9DE8),
      '#A985E8': Color(0xFFA985E8),
      '#77BFA3': Color(0xFF77BFA3),
      '#F0B26A': Color(0xFFF0B26A),
      '#5BC0BE': Color(0xFF5BC0BE),
      '#90C978': Color(0xFF90C978),
      '#E58B5A': Color(0xFFE58B5A),
      '#6CB5D9': Color(0xFF6CB5D9),
      '#B98BE0': Color(0xFFB98BE0),
    };
    return palette[course.colorHex] ?? const Color(0xFF7FA0E8);
  }

  String _minuteLabel(int minute) {
    final hour = (minute ~/ 60).toString().padLeft(2, '0');
    final mins = (minute % 60).toString().padLeft(2, '0');
    return '$hour:$mins';
  }

  @override
  Widget build(BuildContext context) {
    final hourCount = (_axisEndMinute - _axisStartMinute) ~/ 60;
    final gridHeight = hourCount * _hourHeight;
    final gridWidth = weekdayLabels.length * _dayColWidth;
    final totalWidth = _timeColWidth + 3 + gridWidth;
    final totalHeight = _headerHeight + 1 + gridHeight;

    return Container(
      decoration: CoupleUi.sectionCardDecoration(),
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(
                title,
                style: const TextStyle(
                  color: CoupleUi.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              const Text(
                '双指缩放查看',
                style: TextStyle(
                  color: CoupleUi.textTertiary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: InteractiveViewer(
                minScale: 0.75,
                maxScale: 1.85,
                constrained: false,
                boundaryMargin: const EdgeInsets.all(120),
                child: SizedBox(
                  width: totalWidth,
                  height: totalHeight,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        width: _timeColWidth,
                        child: Column(
                          children: <Widget>[
                            const _AxisHeader(label: '时间'),
                            ...List<Widget>.generate(hourCount, (index) {
                              final minute = _axisStartMinute + index * 60;
                              return _TimeAxisCell(
                                label: _minuteLabel(minute),
                                height: _hourHeight,
                              );
                            }),
                          ],
                        ),
                      ),
                      const SizedBox(width: 3),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: weekdayLabels.map((label) {
                              return Container(
                                width: _dayColWidth,
                                height: _headerHeight,
                                margin: const EdgeInsets.only(right: 1),
                                alignment: Alignment.center,
                                decoration: const BoxDecoration(
                                  color: CoupleUi.surfaceMuted,
                                ),
                                child: Text(
                                  label,
                                  style: const TextStyle(
                                    color: CoupleUi.textSecondary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 1),
                          SizedBox(
                            width: gridWidth,
                            height: gridHeight,
                            child: Stack(
                              children: <Widget>[
                                _GridLines(
                                  width: gridWidth,
                                  height: gridHeight,
                                  dayCount: weekdayLabels.length,
                                  hourCount: hourCount,
                                  dayColWidth: _dayColWidth,
                                  hourHeight: _hourHeight,
                                ),
                                ...courses.map((course) {
                                  final left = (course.weekday - 1) * _dayColWidth + 2;
                                  final top =
                                      (course.startMinute - _axisStartMinute) / 60 *
                                          _hourHeight;
                                  final rawHeight =
                                      (course.endMinute - course.startMinute) / 60 *
                                          _hourHeight;
                                  final height = rawHeight < 36 ? 36.0 : rawHeight;
                                  return Positioned(
                                    left: left,
                                    top: top < 0 ? 0 : top + 2,
                                    width: _dayColWidth - 4,
                                    height: height - 4,
                                    child: _CourseBlock(
                                      course: course,
                                      color: _courseColor(course),
                                      minuteLabel: _minuteLabel,
                                      onTap: () => onCourseTap(course),
                                    ),
                                  );
                                }),
                                if (courses.isEmpty)
                                  const Positioned.fill(
                                    child: Center(
                                      child: Text(
                                        '本周还没有课程',
                                        style: TextStyle(
                                          color: CoupleUi.textTertiary,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AxisHeader extends StatelessWidget {
  const _AxisHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: CoupleUi.surfaceMuted,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: CoupleUi.textSecondary,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _TimeAxisCell extends StatelessWidget {
  const _TimeAxisCell({required this.label, required this.height});

  final String label;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      margin: const EdgeInsets.only(top: 1),
      alignment: Alignment.topCenter,
      padding: const EdgeInsets.only(top: 4),
      color: CoupleUi.surface,
      child: Text(
        label,
        style: const TextStyle(
          color: CoupleUi.textTertiary,
          fontSize: 10.6,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _GridLines extends StatelessWidget {
  const _GridLines({
    required this.width,
    required this.height,
    required this.dayCount,
    required this.hourCount,
    required this.dayColWidth,
    required this.hourHeight,
  });

  final double width;
  final double height;
  final int dayCount;
  final int hourCount;
  final double dayColWidth;
  final double hourHeight;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: _GridPainter(
        dayCount: dayCount,
        hourCount: hourCount,
        dayColWidth: dayColWidth,
        hourHeight: hourHeight,
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  const _GridPainter({
    required this.dayCount,
    required this.hourCount,
    required this.dayColWidth,
    required this.hourHeight,
  });

  final int dayCount;
  final int hourCount;
  final double dayColWidth;
  final double hourHeight;

  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()
      ..color = const Color(0x1FC2B6CA)
      ..strokeWidth = 1;
    for (var day = 0; day <= dayCount; day++) {
      final x = day * dayColWidth;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), line);
    }
    for (var hour = 0; hour <= hourCount; hour++) {
      final y = hour * hourHeight;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), line);
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) {
    return oldDelegate.dayCount != dayCount ||
        oldDelegate.hourCount != hourCount ||
        oldDelegate.dayColWidth != dayColWidth ||
        oldDelegate.hourHeight != hourHeight;
  }
}

class _CourseBlock extends StatelessWidget {
  const _CourseBlock({
    required this.course,
    required this.color,
    required this.minuteLabel,
    required this.onTap,
  });

  final Course course;
  final Color color;
  final String Function(int minute) minuteLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.94),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                course.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 11.8,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${minuteLabel(course.startMinute)}-${minuteLabel(course.endMinute)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xF1FFFFFF),
                  fontSize: 10.3,
                ),
              ),
              Text(
                course.location,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xE8FFFFFF),
                  fontSize: 10.2,
                ),
              ),
              if (course.teacher.trim().isNotEmpty)
                Text(
                  course.teacher,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xD7FFFFFF),
                    fontSize: 9.8,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PartnerCourseSheet extends StatelessWidget {
  const _PartnerCourseSheet({required this.course});

  final Course course;

  String _minuteLabel(int minute) {
    final hour = (minute ~/ 60).toString().padLeft(2, '0');
    final mins = (minute % 60).toString().padLeft(2, '0');
    return '$hour:$mins';
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              course.title,
              style: const TextStyle(
                color: CoupleUi.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            _ReadonlyLine(
              label: '时间',
              value:
                  '${_minuteLabel(course.startMinute)} - ${_minuteLabel(course.endMinute)}',
            ),
            _ReadonlyLine(label: '星期', value: '周${course.weekday}'),
            _ReadonlyLine(
              label: '周次',
              value: '${course.startWeek} - ${course.endWeek}',
            ),
            _ReadonlyLine(
              label: '地点',
              value: course.location.isEmpty ? '-' : course.location,
            ),
            _ReadonlyLine(
              label: '老师',
              value: course.teacher.isEmpty ? '-' : course.teacher,
            ),
            _ReadonlyLine(
              label: '备注',
              value: course.note.isEmpty ? '对方课程当前为只读模式。' : course.note,
            ),
            const SizedBox(height: 10),
            const Text(
              '当前阶段对方课表仅支持查看，不可直接编辑。',
              style: TextStyle(
                color: CoupleUi.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReadonlyLine extends StatelessWidget {
  const _ReadonlyLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          children: <TextSpan>[
            TextSpan(
              text: '$label: ',
              style: const TextStyle(
                color: CoupleUi.textTertiary,
                fontWeight: FontWeight.w700,
              ),
            ),
            TextSpan(
              text: value,
              style: const TextStyle(
                color: CoupleUi.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

