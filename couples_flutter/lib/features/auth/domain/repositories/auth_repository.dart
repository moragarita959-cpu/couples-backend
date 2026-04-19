import '../entities/auth_user.dart';

abstract class AuthRepository {
  Future<AuthUser?> restoreIdentity();

  Future<AuthUser> initializeIdentity(String nickname);
}
