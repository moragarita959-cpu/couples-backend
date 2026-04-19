import '../../domain/entities/countdown_event.dart';
import '../../domain/entities/countdown_settings.dart';

class CountdownState {
  const CountdownState({
    this.events = const <CountdownEvent>[],
    this.loveDays = 0,
    this.settings = const CountdownSettings(
      loveStartDate: null,
      loveDaysOverride: null,
    ),
    this.isLoading = false,
    this.isRefreshing = false,
    this.errorMessage,
  });

  static const Object _noChange = Object();

  final List<CountdownEvent> events;
  final int loveDays;
  final CountdownSettings settings;
  final bool isLoading;
  final bool isRefreshing;
  final String? errorMessage;

  CountdownState copyWith({
    List<CountdownEvent>? events,
    int? loveDays,
    CountdownSettings? settings,
    bool? isLoading,
    bool? isRefreshing,
    Object? errorMessage = _noChange,
  }) {
    return CountdownState(
      events: events ?? this.events,
      loveDays: loveDays ?? this.loveDays,
      settings: settings ?? this.settings,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      errorMessage: identical(errorMessage, _noChange)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}
