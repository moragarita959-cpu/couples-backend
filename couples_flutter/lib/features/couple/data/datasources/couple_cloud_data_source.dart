import '../../../../core/network/api_client.dart';
import '../models/couple_profile_model.dart';

class CoupleCloudDataSource {
  const CoupleCloudDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<CoupleProfileModel> bindCoupleByPairCode({
    required String currentUserId,
    required String targetPairCode,
  }) async {
    final payload = await _apiClient.bindCoupleByPairCode(
      currentUserId: currentUserId,
      targetPairCode: targetPairCode,
    );
    return CoupleProfileModel.fromJson(payload);
  }
}
