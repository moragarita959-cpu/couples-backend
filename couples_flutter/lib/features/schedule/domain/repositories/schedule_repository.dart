import '../entities/course.dart';

abstract class ScheduleRepository {
  Future<List<Course>> getCourses();

  Future<Course> addCourse({
    required String title,
    required int weekday,
    required int startMinute,
    required int endMinute,
    required int startWeek,
    required int endWeek,
    required bool repeatWeekly,
    required int startPeriod,
    required int endPeriod,
    required String location,
    required String teacher,
    required String note,
    required CourseOwner owner,
    required String colorHex,
  });

  Future<Course> updateCourse({
    required String id,
    required String title,
    required int weekday,
    required int startMinute,
    required int endMinute,
    required int startWeek,
    required int endWeek,
    required bool repeatWeekly,
    required int startPeriod,
    required int endPeriod,
    required String location,
    required String teacher,
    required String note,
    required CourseOwner owner,
    required String colorHex,
  });

  Future<void> deleteCourse(String id);
}
