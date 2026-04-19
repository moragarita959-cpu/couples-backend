import '../entities/course.dart';
import '../repositories/schedule_repository.dart';

class AddCourse {
  const AddCourse(this._repository);

  final ScheduleRepository _repository;

  Future<Course> call({
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
  }) {
    return _repository.addCourse(
      title: title,
      weekday: weekday,
      startMinute: startMinute,
      endMinute: endMinute,
      startWeek: startWeek,
      endWeek: endWeek,
      repeatWeekly: repeatWeekly,
      startPeriod: startPeriod,
      endPeriod: endPeriod,
      location: location,
      teacher: teacher,
      note: note,
      owner: owner,
      colorHex: colorHex,
    );
  }
}
