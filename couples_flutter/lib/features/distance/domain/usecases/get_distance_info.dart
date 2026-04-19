import '../entities/distance_info.dart';
import '../repositories/distance_repository.dart';

class GetDistanceInfo {
  const GetDistanceInfo(this._repository);

  final DistanceRepository _repository;

  Future<DistanceInfo> call() {
    return _repository.getDistanceInfo();
  }
}
