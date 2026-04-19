import '../entities/couple_profile.dart';

abstract class CoupleRepository {
  Future<CoupleProfile?> getLocalCoupleProfile();

  Future<CoupleProfile> bindCoupleByPairCode({
    required String currentUserId,
    required String targetPairCode,
  });
}
