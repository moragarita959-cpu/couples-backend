import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/usecases/get_last_poke.dart';
import '../../domain/usecases/send_poke.dart';
import 'poke_state.dart';

class PokeController extends StateNotifier<PokeState> {
  PokeController(
    this._sendPoke,
    this._getLastPoke,
  ) : super(const PokeState()) {
    load();
  }

  final SendPoke _sendPoke;
  final GetLastPoke _getLastPoke;

  Future<void> load() async {
    final last = await _getLastPoke();
    state = state.copyWith(
      lastPoke: last,
      errorMessage: null,
    );
  }

  Future<void> send() async {
    state = state.copyWith(
      isPoking: true,
      showFeedback: false,
      errorMessage: null,
    );

    try {
      final event = await _sendPoke();
      state = state.copyWith(
        lastPoke: event,
        isPoking: false,
        showFeedback: true,
        errorMessage: null,
      );

      await Future<void>.delayed(const Duration(milliseconds: 900));
      state = state.copyWith(showFeedback: false, errorMessage: null);
    } catch (_) {
      state = state.copyWith(
        isPoking: false,
        showFeedback: false,
        errorMessage: '\u6233\u4e00\u4e0b\u5931\u8d25\uff0c\u8bf7\u7a0d\u540e\u518d\u8bd5',
      );
    }
  }
}
