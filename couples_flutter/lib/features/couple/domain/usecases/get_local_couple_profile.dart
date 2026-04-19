import '../entities/couple_profile.dart';
import '../repositories/couple_repository.dart';

class GetLocalCoupleProfile {
  const GetLocalCoupleProfile(this._repository);

  final CoupleRepository _repository;

  Future<CoupleProfile?> call() {
    return _repository.getLocalCoupleProfile();
  }
}
