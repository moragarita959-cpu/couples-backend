import '../repositories/schedule_repository.dart';

class DeleteCourse {
  const DeleteCourse(this._repository);

  final ScheduleRepository _repository;

  Future<void> call(String id) {
    return _repository.deleteCourse(id);
  }
}
