import '../../../../core/storage/drift/app_database.dart';
import '../../domain/entities/couple_profile.dart';

class CoupleLocalDataSource {
  const CoupleLocalDataSource(this._db);

  final AppDatabase _db;

  Future<CoupleProfile?> getCurrentProfile() async {
    final row = await (_db.select(
      _db.localCoupleProfileTable,
    )..limit(1)).getSingleOrNull();
    if (row == null) {
      return null;
    }

    return CoupleProfile(
      coupleId: row.coupleId,
      currentUserId: row.currentUserId,
      currentUserNickname: row.currentUserNickname,
      partnerUserId: row.partnerUserId,
      partnerNickname: row.partnerNickname,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  Future<void> saveProfile(CoupleProfile profile) async {
    await _db.transaction(() async {
      await _db.delete(_db.localCoupleProfileTable).go();
      await _db.into(_db.localCoupleProfileTable).insert(
            LocalCoupleProfileTableCompanion.insert(
              coupleId: profile.coupleId,
              currentUserId: profile.currentUserId,
              currentUserNickname: profile.currentUserNickname,
              partnerUserId: profile.partnerUserId,
              partnerNickname: profile.partnerNickname,
              createdAt: profile.createdAt,
              updatedAt: profile.updatedAt,
            ),
          );
    });
  }
}
