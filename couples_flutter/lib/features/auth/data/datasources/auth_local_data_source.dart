import 'package:drift/drift.dart';

import '../../../../core/storage/drift/app_database.dart';
import '../models/auth_user_model.dart';

class AuthLocalDataSource {
  const AuthLocalDataSource(this._db);

  final AppDatabase _db;

  Future<AuthUserModel?> getCurrentUser() async {
    final row = await (_db.select(
      _db.localUserProfileTable,
    )..limit(1)).getSingleOrNull();
    if (row == null) {
      return null;
    }

    return AuthUserModel(
      userId: row.userId,
      nickname: row.nickname,
      pairCode: row.pairCode,
      coupleId: row.coupleId,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  Future<void> saveUser(AuthUserModel user) async {
    await _db.transaction(() async {
      await _db.delete(_db.localUserProfileTable).go();
      await _db.into(_db.localUserProfileTable).insert(
            LocalUserProfileTableCompanion.insert(
              userId: user.userId,
              nickname: user.nickname,
              pairCode: user.pairCode,
              coupleId: Value<String?>(user.coupleId),
              createdAt: user.createdAt,
              updatedAt: user.updatedAt,
            ),
          );
    });
  }

  Future<void> updateCoupleId({
    required String userId,
    required String? coupleId,
  }) async {
    await (_db.update(
      _db.localUserProfileTable,
    )..where((t) => t.userId.equals(userId))).write(
      LocalUserProfileTableCompanion(
        coupleId: Value<String?>(coupleId),
        updatedAt: Value<DateTime>(DateTime.now()),
      ),
    );
  }
}
