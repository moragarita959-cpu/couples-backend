import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/usecases/bind_couple_by_pair_code.dart';
import '../../domain/usecases/get_local_couple_profile.dart';
import 'couple_state.dart';

class CoupleController extends StateNotifier<CoupleState> {
  CoupleController(
    this._bindCoupleByPairCode,
    this._getLocalCoupleProfile,
    this._currentUserIdResolver,
    this._onBound,
  ) : super(const CoupleState()) {
    loadLocalProfile();
  }

  final BindCoupleByPairCode _bindCoupleByPairCode;
  final GetLocalCoupleProfile _getLocalCoupleProfile;
  final String? Function() _currentUserIdResolver;
  final void Function(String coupleId) _onBound;

  Future<void> loadLocalProfile() async {
    final profile = await _getLocalCoupleProfile();
    if (profile == null) {
      return;
    }

    state = state.copyWith(
      status: CoupleStatus.bound,
      profile: profile,
      errorMessage: null,
    );
  }

  Future<void> bind({
    required String targetPairCode,
  }) async {
    final currentUserId = _currentUserIdResolver();
    if (currentUserId == null || currentUserId.isEmpty) {
      state = state.copyWith(
        status: CoupleStatus.failure,
        errorMessage: '请先建立当前设备身份。',
      );
      return;
    }

    state = state.copyWith(
      status: CoupleStatus.loading,
      errorMessage: null,
    );

    try {
      final profile = await _bindCoupleByPairCode(
        currentUserId: currentUserId,
        targetPairCode: targetPairCode.trim(),
      );
      state = state.copyWith(
        status: CoupleStatus.bound,
        profile: profile,
        errorMessage: null,
      );
      _onBound(profile.coupleId);
    } catch (error) {
      state = state.copyWith(
        status: CoupleStatus.failure,
        errorMessage: _mapErrorMessage(error),
      );
    }
  }

  String _mapErrorMessage(Object error) {
    final message = error.toString();
    if (message.contains('cannot_bind_self')) {
      return '不能绑定自己的配对码。';
    }
    if (message.contains('invalid_pair_code')) {
      return '配对码不正确，请检查后重试。';
    }
    if (message.contains('current_user_already_bound')) {
      return '你已经完成绑定。';
    }
    if (message.contains('target_user_already_bound')) {
      return '对方已经和其他人绑定。';
    }
    return '绑定失败，请稍后再试。';
  }
}
