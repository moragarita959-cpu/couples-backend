import '../entities/distance_info.dart';
import '../repositories/distance_repository.dart';

class UpdateDistanceText {
  const UpdateDistanceText(this._repository);

  final DistanceRepository _repository;

  Future<DistanceInfo> call(String distanceText) {
    return _repository.updateDistanceText(distanceText);
  }
}
