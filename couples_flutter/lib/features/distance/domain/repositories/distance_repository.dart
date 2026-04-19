import '../entities/distance_info.dart';

abstract class DistanceRepository {
  Future<DistanceInfo> getDistanceInfo();

  Future<DistanceInfo> enableDistance();

  Future<DistanceInfo> disableDistance();

  Future<DistanceInfo> updateDistanceText(String distanceText);
}
