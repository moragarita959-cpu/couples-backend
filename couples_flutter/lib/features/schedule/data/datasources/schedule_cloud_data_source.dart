import '../../../../core/network/api_client.dart';
import '../models/course_model.dart';

class ScheduleCloudDataSource {
  const ScheduleCloudDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<List<CourseModel>> listCourses({
    required String coupleId,
    required String currentUserId,
  }) async {
    final payload = await _apiClient.listScheduleCourses(
      coupleId: coupleId,
      currentUserId: currentUserId,
    );
    return payload.map(CourseModel.fromCloudJson).toList();
  }

  Future<CourseModel> upsertCourse(Map<String, dynamic> body) async {
    final payload = await _apiClient.upsertScheduleCourse(body);
    return CourseModel.fromCloudJson(payload);
  }

  Future<void> deleteCourse({
    required String coupleId,
    required String id,
  }) async {
    await _apiClient.deleteScheduleCourse(coupleId: coupleId, id: id);
  }
}
