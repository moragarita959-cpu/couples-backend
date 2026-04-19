import '../../../auth/data/datasources/auth_local_data_source.dart';
import '../../domain/entities/couple_profile.dart';
import '../../domain/repositories/couple_repository.dart';
import '../datasources/couple_cloud_data_source.dart';
import '../datasources/couple_local_data_source.dart';

class CoupleRepositoryImpl implements CoupleRepository {
  const CoupleRepositoryImpl(
    this._localDataSource,
    this._cloudDataSource,
    this._authLocalDataSource,
  );

  final CoupleLocalDataSource _localDataSource;
  final CoupleCloudDataSource _cloudDataSource;
  final AuthLocalDataSource _authLocalDataSource;

  @override
  Future<CoupleProfile?> getLocalCoupleProfile() {
    return _localDataSource.getCurrentProfile();
  }

  @override
  Future<CoupleProfile> bindCoupleByPairCode({
    required String currentUserId,
    required String targetPairCode,
  }) async {
    final profile = await _cloudDataSource.bindCoupleByPairCode(
      currentUserId: currentUserId,
      targetPairCode: targetPairCode,
    );
    await _localDataSource.saveProfile(profile);
    await _authLocalDataSource.updateCoupleId(
      userId: currentUserId,
      coupleId: profile.coupleId,
    );
    return profile;
  }
}
