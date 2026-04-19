import '../../domain/entities/course.dart';
import '../../domain/repositories/schedule_repository.dart';
import '../datasources/schedule_cloud_data_source.dart';
import '../datasources/schedule_local_data_source.dart';
import '../models/course_model.dart';

class ScheduleRepositoryImpl implements ScheduleRepository {
  const ScheduleRepositoryImpl(
    this._localDataSource,
    this._cloudDataSource,
    this._resolveCoupleId,
    this._resolveCurrentUserId,
  );

  final ScheduleLocalDataSource _localDataSource;
  final ScheduleCloudDataSource _cloudDataSource;
  final String? Function() _resolveCoupleId;
  final String? Function() _resolveCurrentUserId;

  @override
  Future<List<Course>> getCourses() async {
    final coupleId = _resolveCoupleId();
    final currentUserId = _resolveCurrentUserId();
    if (coupleId != null &&
        coupleId.isNotEmpty &&
        currentUserId != null &&
        currentUserId.isNotEmpty) {
      final remote = await _cloudDataSource.listCourses(
        coupleId: coupleId,
        currentUserId: currentUserId,
      );
      await _localDataSource.replaceCourses(remote);
    }
    return _localDataSource.getCourses();
  }

  @override
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
  }) async {
    final now = DateTime.now();
    final draft = CourseModel(
      id: 'course-${now.microsecondsSinceEpoch}',
      title: title.trim(),
      weekday: weekday,
      startMinute: startMinute,
      endMinute: endMinute,
      startWeek: startWeek,
      endWeek: endWeek,
      repeatWeekly: repeatWeekly,
      startPeriod: startPeriod,
      endPeriod: endPeriod,
      location: location.trim(),
      teacher: teacher.trim(),
      note: note.trim(),
      owner: owner,
      colorHex: colorHex,
      createdAt: now,
    );
    await _localDataSource.upsertCourse(draft);

    final coupleId = _resolveCoupleId();
    final currentUserId = _resolveCurrentUserId();
    if (coupleId == null ||
        coupleId.isEmpty ||
        currentUserId == null ||
        currentUserId.isEmpty) {
      return draft;
    }

    final saved = await _cloudDataSource.upsertCourse(
      draft.toCloudJson(coupleId: coupleId, currentUserId: currentUserId),
    );
    await _localDataSource.upsertCourse(saved);
    return saved;
  }

  @override
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
  }) async {
    final draft = CourseModel(
      id: id,
      title: title.trim(),
      weekday: weekday,
      startMinute: startMinute,
      endMinute: endMinute,
      startWeek: startWeek,
      endWeek: endWeek,
      repeatWeekly: repeatWeekly,
      startPeriod: startPeriod,
      endPeriod: endPeriod,
      location: location.trim(),
      teacher: teacher.trim(),
      note: note.trim(),
      owner: owner,
      colorHex: colorHex,
      createdAt: DateTime.now(),
    );
    await _localDataSource.upsertCourse(draft);

    final coupleId = _resolveCoupleId();
    final currentUserId = _resolveCurrentUserId();
    if (coupleId == null ||
        coupleId.isEmpty ||
        currentUserId == null ||
        currentUserId.isEmpty) {
      return draft;
    }

    final saved = await _cloudDataSource.upsertCourse(
      draft.toCloudJson(coupleId: coupleId, currentUserId: currentUserId),
    );
    await _localDataSource.upsertCourse(saved);
    return saved;
  }

  @override
  Future<void> deleteCourse(String id) async {
    await _localDataSource.deleteCourse(id);
    final coupleId = _resolveCoupleId();
    if (coupleId == null || coupleId.isEmpty) {
      return;
    }
    await _cloudDataSource.deleteCourse(coupleId: coupleId, id: id);
  }
}
