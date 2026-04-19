import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/usecases/initialize_identity.dart';
import '../../domain/usecases/restore_identity.dart';
import 'auth_state.dart';

class AuthController extends StateNotifier<AuthState> {
  AuthController(
    this._restoreIdentity,
    this._initializeIdentity,
  ) : super(const AuthState()) {
    restore();
  }

  final RestoreIdentity _restoreIdentity;
  final InitializeIdentity _initializeIdentity;

  Future<void> restore() async {
    state = state.copyWith(
      status: AuthStatus.checking,
      errorMessage: null,
    );

    try {
      final user = await _restoreIdentity();
      if (user == null) {
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          errorMessage: null,
        );
        return;
      }

      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        errorMessage: null,
      );
    } catch (_) {
      state = state.copyWith(
        status: AuthStatus.failure,
        errorMessage: '身份恢复失败，请重新进入应用。',
      );
    }
  }

  Future<void> initializeIdentity({
    required String nickname,
  }) async {
    state = state.copyWith(
      status: AuthStatus.loading,
      errorMessage: null,
    );

    try {
      final user = await _initializeIdentity(nickname);
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        errorMessage: null,
      );
    } catch (_) {
      state = state.copyWith(
        status: AuthStatus.failure,
        errorMessage: '初始化身份失败，请稍后重试。',
      );
    }
  }

  void resetToUnauthenticated() {
    state = state.copyWith(
      status: AuthStatus.unauthenticated,
      errorMessage: null,
    );
  }

  void applyCoupleId(String coupleId) {
    final user = state.user;
    if (user == null) {
      return;
    }
    state = state.copyWith(
      user: user.copyWith(
        coupleId: coupleId,
        updatedAt: DateTime.now(),
      ),
    );
  }
}
