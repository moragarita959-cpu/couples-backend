import '../../../../core/network/api_client.dart';
import '../models/auth_user_model.dart';

class AuthCloudDataSource {
  const AuthCloudDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<AuthUserModel> bootstrapUser({
    required String userId,
    required String nickname,
  }) async {
    final payload = await _apiClient.bootstrapUser(
      userId: userId,
      nickname: nickname,
    );
    return AuthUserModel.fromJson(payload);
  }
}
