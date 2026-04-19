class DistanceState {
  const DistanceState({
    this.isEnabled = false,
    this.distanceText = '距离显示已关闭',
    this.errorMessage,
  });

  final bool isEnabled;
  final String distanceText;
  final String? errorMessage;

  DistanceState copyWith({
    bool? isEnabled,
    String? distanceText,
    String? errorMessage,
  }) {
    return DistanceState(
      isEnabled: isEnabled ?? this.isEnabled,
      distanceText: distanceText ?? this.distanceText,
      errorMessage: errorMessage,
    );
  }
}
