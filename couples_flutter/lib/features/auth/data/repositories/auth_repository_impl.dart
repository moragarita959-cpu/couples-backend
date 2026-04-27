import 'dart:math';

import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_cloud_data_source.dart';
import '../datasources/auth_local_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._localDataSource, this._cloudDataSource);

  final AuthLocalDataSource _localDataSource;
  final AuthCloudDataSource _cloudDataSource;
  final Random _random = Random();

  @override
  Future<AuthUser?> restoreIdentity() async {
    final localUser = await _localDataSource.getCurrentUser();
    if (localUser == null) {
      return null;
    }

    try {
      final refreshed = await _cloudDataSource.bootstrapUser(
        userId: localUser.userId,
        nickname: localUser.nickname,
      );
      await _localDataSource.saveUser(refreshed);
      return refreshed;
    } catch (_) {
      // Keep the existing local identity usable when cloud refresh fails
      // so the app can still open instead of forcing a re-login.
      return localUser;
    }
  }

  @override
  Future<AuthUser> initializeIdentity(String nickname) async {
    final trimmedNickname = nickname.trim();
    if (trimmedNickname.isEmpty) {
      throw Exception('请输入昵称');
    }

    final user = await _cloudDataSource.bootstrapUser(
      userId: _generateUserId(),
      nickname: trimmedNickname,
    );
    await _localDataSource.saveUser(user);
    return user;
  }

  String _generateUserId() {
    final suffix = (_random.nextInt(9000) + 1000).toString();
    return 'user-${DateTime.now().microsecondsSinceEpoch}-$suffix';
  }
}
