import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../feed/domain/entities/feed_event.dart';
import '../../../feed/domain/services/feed_summary_builder.dart';
import '../../../feed/domain/usecases/add_feed_event.dart';
import '../../domain/entities/course.dart';
import '../../domain/usecases/add_course.dart';
import '../../domain/usecases/delete_course.dart';
import '../../domain/usecases/get_courses.dart';
import '../../domain/usecases/update_course.dart';
import 'schedule_state.dart';

class ScheduleController extends StateNotifier<ScheduleState> {
  ScheduleController(
    this._getCourses,
    this._addCourse,
    this._updateCourse,
    this._deleteCourse,
    this._addFeedEvent,
  ) : super(const ScheduleState()) {
    load();
  }

  final GetCourses _getCourses;
  final AddCourse _addCourse;
  final UpdateCourse _updateCourse;
  final DeleteCourse _deleteCourse;
  final AddFeedEvent _addFeedEvent;

  Future<void> load() async {
    try {
      final courses = await _getCourses();
      state = state.copyWith(courses: courses, errorMessage: null);
    } catch (_) {
      state = state.copyWith(errorMessage: '课表加载失败');
    }
  }

  void setViewMode(ScheduleViewMode mode) {
    state = state.copyWith(viewMode: mode, errorMessage: null);
  }

  void previousWeek() {
    final next = (state.currentWeek - 1).clamp(1, 30);
    state = state.copyWith(currentWeek: next);
  }

  void nextWeek() {
    final next = (state.currentWeek + 1).clamp(1, 30);
    state = state.copyWith(currentWeek: next);
  }

  Future<bool> create({
    required String title,
    required int weekday,
    required int startMinute,
    required int endMinute,
    required int startWeek,
    required int endWeek,
    required bool repeatWeekly,
    required String location,
    required String teacher,
    required String note,
    required CourseOwner owner,
    required String colorHex,
  }) async {
    final err = _validate(
      title: title,
      startMinute: startMinute,
      endMinute: endMinute,
      startWeek: startWeek,
      endWeek: endWeek,
    );
    if (err != null) {
      state = state.copyWith(errorMessage: err);
      return false;
    }
    try {
      final created = await _addCourse(
        title: title,
        weekday: weekday,
        startMinute: startMinute,
        endMinute: endMinute,
        startWeek: startWeek,
        endWeek: endWeek,
        repeatWeekly: repeatWeekly,
        startPeriod: _estimatePeriodFromMinute(startMinute),
        endPeriod: _estimatePeriodFromMinute(endMinute),
        location: location,
        teacher: teacher,
        note: note,
        owner: owner,
        colorHex: colorHex,
      );
      await _addFeedEvent(
        eventType: FeedEventType.courseCreated,
        actorSide: FeedActorSide.me,
        targetType: FeedTargetType.course,
        targetId: created.id,
        summaryText: FeedSummaryBuilder.courseCreated(title: created.title),
      );
      await load();
      return true;
    } catch (_) {
      state = state.copyWith(errorMessage: '新增课程失败');
      return false;
    }
  }

  Future<bool> update({
    required String id,
    required String title,
    required int weekday,
    required int startMinute,
    required int endMinute,
    required int startWeek,
    required int endWeek,
    required bool repeatWeekly,
    required String location,
    required String teacher,
    required String note,
    required CourseOwner owner,
    required String colorHex,
  }) async {
    final err = _validate(
      title: title,
      startMinute: startMinute,
      endMinute: endMinute,
      startWeek: startWeek,
      endWeek: endWeek,
    );
    if (err != null) {
      state = state.copyWith(errorMessage: err);
      return false;
    }
    try {
      await _updateCourse(
        id: id,
        title: title,
        weekday: weekday,
        startMinute: startMinute,
        endMinute: endMinute,
        startWeek: startWeek,
        endWeek: endWeek,
        repeatWeekly: repeatWeekly,
        startPeriod: _estimatePeriodFromMinute(startMinute),
        endPeriod: _estimatePeriodFromMinute(endMinute),
        location: location,
        teacher: teacher,
        note: note,
        owner: owner,
        colorHex: colorHex,
      );
      await _addFeedEvent(
        eventType: FeedEventType.courseUpdated,
        actorSide: FeedActorSide.me,
        targetType: FeedTargetType.course,
        targetId: id,
        summaryText: FeedSummaryBuilder.courseUpdated(title: title),
      );
      await load();
      return true;
    } catch (_) {
      state = state.copyWith(errorMessage: '保存课程修改失败');
      return false;
    }
  }

  Future<bool> remove(String id) async {
    try {
      final target = state.courses.cast<Course?>().firstWhere(
        (item) => item?.id == id,
        orElse: () => null,
      );
      await _deleteCourse(id);
      if (target != null) {
        await _addFeedEvent(
          eventType: FeedEventType.courseDeleted,
          actorSide: FeedActorSide.me,
          targetType: FeedTargetType.course,
          targetId: id,
          summaryText: FeedSummaryBuilder.courseDeleted(title: target.title),
        );
      }
      await load();
      return true;
    } catch (_) {
      state = state.copyWith(errorMessage: '删除课程失败');
      return false;
    }
  }

  String? _validate({
    required String title,
    required int startMinute,
    required int endMinute,
    required int startWeek,
    required int endWeek,
  }) {
    if (title.trim().isEmpty) {
      return '请输入课程标题';
    }
    if (startMinute < 0 || endMinute <= startMinute) {
      return '开始和结束时间设置不合法';
    }
    if (startWeek <= 0 || endWeek < startWeek) {
      return '起止周设置不合法';
    }
    return null;
  }

  int _estimatePeriodFromMinute(int minute) {
    if (minute < 8 * 60 + 50) return 1;
    if (minute < 9 * 60 + 50) return 2;
    if (minute < 10 * 60 + 40) return 3;
    if (minute < 11 * 60 + 30) return 4;
    if (minute < 13 * 60 + 30) return 5;
    if (minute < 14 * 60 + 20) return 6;
    if (minute < 15 * 60 + 20) return 7;
    if (minute < 16 * 60 + 10) return 8;
    if (minute < 17 * 60) return 9;
    if (minute < 19 * 60) return 10;
    if (minute < 19 * 60 + 50) return 11;
    if (minute < 20 * 60 + 40) return 12;
    if (minute < 21 * 60 + 30) return 13;
    return 14;
  }
}
