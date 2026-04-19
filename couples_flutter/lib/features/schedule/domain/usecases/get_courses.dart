import '../entities/course.dart';
import '../repositories/schedule_repository.dart';

class GetCourses {
  const GetCourses(this._repository);

  final ScheduleRepository _repository;

  Future<List<Course>> call() {
    return _repository.getCourses();
  }
}
