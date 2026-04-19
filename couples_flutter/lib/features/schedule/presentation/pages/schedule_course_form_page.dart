import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../domain/entities/course.dart';

class ScheduleCourseFormPage extends ConsumerStatefulWidget {
  const ScheduleCourseFormPage({super.key, this.initialCourse});

  final Course? initialCourse;

  @override
  ConsumerState<ScheduleCourseFormPage> createState() =>
      _ScheduleCourseFormPageState();
}

class _ScheduleCourseFormPageState extends ConsumerState<ScheduleCourseFormPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _teacherController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  int _weekday = 1;
  CourseOwner _owner = CourseOwner.me;
  int _startWeek = 1;
  int _endWeek = 16;
  bool _repeatWeekly = true;
  TimeOfDay _startTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 9, minute: 35);
  String _colorHex = '#E88EA3';

  bool get _isEdit => widget.initialCourse != null;

  static const List<String> _weekdayLabels = <String>[
    '周一',
    '周二',
    '周三',
    '周四',
    '周五',
    '周六',
    '周日',
  ];

  static const Map<String, Color> _colorPresets = <String, Color>{
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

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _teacherController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    final course = widget.initialCourse;
    if (course == null) {
      return;
    }
    _titleController.text = course.title;
    _locationController.text = course.location;
    _teacherController.text = course.teacher;
    _noteController.text = course.note;
    _weekday = course.weekday;
    _owner = course.owner;
    _startWeek = course.startWeek;
    _endWeek = course.endWeek;
    _repeatWeekly = course.repeatWeekly;
    _colorHex = course.colorHex;
    _startTime = TimeOfDay(
      hour: course.startMinute ~/ 60,
      minute: course.startMinute % 60,
    );
    _endTime = TimeOfDay(
      hour: course.endMinute ~/ 60,
      minute: course.endMinute % 60,
    );
  }

  String _ownerLabel(CourseOwner owner) {
    return owner == CourseOwner.me ? '我' : 'TA';
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(context: context, initialTime: _startTime);
    if (picked == null || !mounted) {
      return;
    }
    setState(() {
      _startTime = picked;
      if (_toMinute(_endTime) <= _toMinute(_startTime)) {
        _endTime = TimeOfDay(
          hour: (_startTime.hour + 1) % 24,
          minute: _startTime.minute,
        );
      }
    });
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(context: context, initialTime: _endTime);
    if (picked == null || !mounted) {
      return;
    }
    setState(() {
      _endTime = picked;
    });
  }

  String _formatTime(TimeOfDay time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  int _toMinute(TimeOfDay time) => time.hour * 60 + time.minute;

  Future<void> _submit() async {
    final controller = ref.read(scheduleControllerProvider.notifier);
    final ok = _isEdit
        ? await controller.update(
            id: widget.initialCourse!.id,
            title: _titleController.text,
            weekday: _weekday,
            startMinute: _toMinute(_startTime),
            endMinute: _toMinute(_endTime),
            startWeek: _startWeek,
            endWeek: _endWeek,
            repeatWeekly: _repeatWeekly,
            location: _locationController.text,
            teacher: _teacherController.text,
            note: _noteController.text,
            owner: _owner,
            colorHex: _colorHex,
          )
        : await controller.create(
            title: _titleController.text,
            weekday: _weekday,
            startMinute: _toMinute(_startTime),
            endMinute: _toMinute(_endTime),
            startWeek: _startWeek,
            endWeek: _endWeek,
            repeatWeekly: _repeatWeekly,
            location: _locationController.text,
            teacher: _teacherController.text,
            note: _noteController.text,
            owner: _owner,
            colorHex: _colorHex,
          );
    if (!ok || !mounted) {
      return;
    }
    Navigator.of(context).pop(true);
  }

  Future<void> _deleteCourse() async {
    if (!_isEdit) {
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('删除课程'),
          content: const Text('确认删除这门课程吗？删除后不可恢复。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('删除'),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !mounted) {
      return;
    }
    final ok = await ref
        .read(scheduleControllerProvider.notifier)
        .remove(widget.initialCourse!.id);
    if (!ok || !mounted) {
      return;
    }
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? '编辑课程' : '新增课程'),
        actions: [
          if (_isEdit)
            IconButton(
              onPressed: _deleteCourse,
              icon: const Icon(Icons.delete_outline),
              tooltip: '删除课程',
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: '课程名称',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<CourseOwner>(
                      initialValue: _owner,
                      decoration: const InputDecoration(
                        labelText: '归属',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      items: CourseOwner.values
                          .map(
                            (item) => DropdownMenuItem<CourseOwner>(
                              value: item,
                              child: Text(_ownerLabel(item)),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _owner = value;
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      initialValue: _weekday,
                      decoration: const InputDecoration(
                        labelText: '星期',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      items: List<DropdownMenuItem<int>>.generate(7, (index) {
                        final day = index + 1;
                        return DropdownMenuItem<int>(
                          value: day,
                          child: Text(_weekdayLabels[index]),
                        );
                      }),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _weekday = value;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickStartTime,
                      icon: const Icon(Icons.access_time),
                      label: Text('开始 ${_formatTime(_startTime)}'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickEndTime,
                      icon: const Icon(Icons.access_time_filled),
                      label: Text('结束 ${_formatTime(_endTime)}'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      initialValue: _startWeek,
                      decoration: const InputDecoration(
                        labelText: '起始周',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      items: List<DropdownMenuItem<int>>.generate(30, (index) {
                        final week = index + 1;
                        return DropdownMenuItem<int>(
                          value: week,
                          child: Text('第 $week 周'),
                        );
                      }),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _startWeek = value;
                            if (_endWeek < _startWeek) {
                              _endWeek = _startWeek;
                            }
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      initialValue: _endWeek,
                      decoration: const InputDecoration(
                        labelText: '结束周',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      items: List<DropdownMenuItem<int>>.generate(30, (index) {
                        final week = index + 1;
                        return DropdownMenuItem<int>(
                          value: week,
                          child: Text('第 $week 周'),
                        );
                      }),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _endWeek = value;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              SwitchListTile(
                value: _repeatWeekly,
                onChanged: (value) {
                  setState(() {
                    _repeatWeekly = value;
                  });
                },
                contentPadding: EdgeInsets.zero,
                title: const Text('每周重复'),
                subtitle: const Text('当前版本默认按周重复，后续可以再扩展单双周等规则。'),
              ),
              TextField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: '地点',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _teacherController,
                decoration: const InputDecoration(
                  labelText: '老师',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _noteController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: '备注（可选）',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: _colorHex,
                decoration: const InputDecoration(
                  labelText: '课程配色',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                items: _colorPresets.entries
                    .map(
                      (entry) => DropdownMenuItem<String>(
                        value: entry.key,
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: entry.value,
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(entry.key),
                          ],
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _colorHex = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: _submit,
                child: Text(_isEdit ? '保存修改' : '保存课程'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
