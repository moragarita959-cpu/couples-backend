import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

class InitializeIdentity {
  const InitializeIdentity(this._repository);

  final AuthRepository _repository;

  Future<AuthUser> call(String nickname) {
    return _repository.initializeIdentity(nickname);
  }
}
