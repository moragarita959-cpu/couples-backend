import '../../domain/entities/poke_event.dart';

class PokeState {
  const PokeState({
    this.lastPoke,
    this.isPoking = false,
    this.showFeedback = false,
    this.errorMessage,
  });

  final PokeEvent? lastPoke;
  final bool isPoking;
  final bool showFeedback;
  final String? errorMessage;

  PokeState copyWith({
    PokeEvent? lastPoke,
    bool? isPoking,
    bool? showFeedback,
    String? errorMessage,
  }) {
    return PokeState(
      lastPoke: lastPoke ?? this.lastPoke,
      isPoking: isPoking ?? this.isPoking,
      showFeedback: showFeedback ?? this.showFeedback,
      errorMessage: errorMessage,
    );
  }
}
