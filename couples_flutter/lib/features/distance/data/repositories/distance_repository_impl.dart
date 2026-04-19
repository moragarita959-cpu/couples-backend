import '../../domain/entities/distance_info.dart';
import '../../domain/repositories/distance_repository.dart';
import '../datasources/distance_mock_data_source.dart';

class DistanceRepositoryImpl implements DistanceRepository {
  const DistanceRepositoryImpl(this._dataSource);

  final DistanceMockDataSource _dataSource;

  @override
  Future<DistanceInfo> getDistanceInfo() {
    return _dataSource.getDistanceInfo();
  }

  @override
  Future<DistanceInfo> enableDistance() {
    return _dataSource.enableDistance();
  }

  @override
  Future<DistanceInfo> disableDistance() {
    return _dataSource.disableDistance();
  }

  @override
  Future<DistanceInfo> updateDistanceText(String distanceText) {
    return _dataSource.updateDistanceText(distanceText);
  }
}
