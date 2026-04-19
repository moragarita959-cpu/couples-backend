import '../entities/couple_profile.dart';
import '../repositories/couple_repository.dart';

class BindCoupleByPairCode {
  const BindCoupleByPairCode(this._repository);

  final CoupleRepository _repository;

  Future<CoupleProfile> call({
    required String currentUserId,
    required String targetPairCode,
  }) {
    return _repository.bindCoupleByPairCode(
      currentUserId: currentUserId,
      targetPairCode: targetPairCode,
    );
  }
}
