import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/usecases/disable_distance.dart';
import '../../domain/usecases/enable_distance.dart';
import '../../domain/usecases/get_distance_info.dart';
import '../../domain/usecases/update_distance_text.dart';
import 'distance_state.dart';

class DistanceController extends StateNotifier<DistanceState> {
  DistanceController(
    this._getDistanceInfo,
    this._enableDistance,
    this._disableDistance,
    this._updateDistanceText,
  ) : super(const DistanceState()) {
    load();
  }

  final GetDistanceInfo _getDistanceInfo;
  final EnableDistance _enableDistance;
  final DisableDistance _disableDistance;
  final UpdateDistanceText _updateDistanceText;

  Future<void> load() async {
    final info = await _getDistanceInfo();
    state = state.copyWith(
      isEnabled: info.isEnabled,
      distanceText: info.distanceText ?? '距离显示已关闭',
      errorMessage: null,
    );
  }

  Future<void> toggle() async {
    try {
      final info = state.isEnabled
          ? await _disableDistance()
          : await _enableDistance();
      state = state.copyWith(
        isEnabled: info.isEnabled,
        distanceText: info.distanceText ?? '距离显示已关闭',
        errorMessage: null,
      );
    } catch (_) {
      state = state.copyWith(errorMessage: '更新距离状态失败');
    }
  }

  Future<void> saveDistanceText(String value) async {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      state = state.copyWith(errorMessage: '距离文案不能为空');
      return;
    }

    try {
      final info = await _updateDistanceText(trimmed);
      state = state.copyWith(
        isEnabled: info.isEnabled,
        distanceText: info.distanceText ?? trimmed,
        errorMessage: null,
      );
    } catch (_) {
      state = state.copyWith(errorMessage: '保存距离文案失败');
    }
  }
}

