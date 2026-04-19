import '../entities/distance_info.dart';
import '../repositories/distance_repository.dart';

class EnableDistance {
  const EnableDistance(this._repository);

  final DistanceRepository _repository;

  Future<DistanceInfo> call() {
    return _repository.enableDistance();
  }
}
