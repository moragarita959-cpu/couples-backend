import '../../domain/entities/course.dart';

enum ScheduleViewMode { mine, partner, compare }

class ScheduleState {
  const ScheduleState({
    this.courses = const <Course>[],
    this.viewMode = ScheduleViewMode.mine,
    this.currentWeek = 6,
    this.errorMessage,
  });

  static const Object _noChange = Object();

  final List<Course> courses;
  final ScheduleViewMode viewMode;
  final int currentWeek;
  final String? errorMessage;

  List<Course> visibleCoursesForMode(ScheduleViewMode mode) {
    final weekCourses = courses.where((c) => c.isActiveInWeek(currentWeek));
    switch (mode) {
      case ScheduleViewMode.mine:
        return weekCourses.where((c) => c.owner == CourseOwner.me).toList();
      case ScheduleViewMode.partner:
        return weekCourses.where((c) => c.owner == CourseOwner.partner).toList();
      case ScheduleViewMode.compare:
        return weekCourses.toList();
    }
  }

  ScheduleState copyWith({
    List<Course>? courses,
    ScheduleViewMode? viewMode,
    int? currentWeek,
    Object? errorMessage = _noChange,
  }) {
    return ScheduleState(
      courses: courses ?? this.courses,
      viewMode: viewMode ?? this.viewMode,
      currentWeek: currentWeek ?? this.currentWeek,
      errorMessage: identical(errorMessage, _noChange)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}
