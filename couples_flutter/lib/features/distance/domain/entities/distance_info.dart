class DistanceInfo {
  const DistanceInfo({
    required this.isEnabled,
    required this.distanceText,
    this.myLatitude,
    this.myLongitude,
    this.partnerLatitude,
    this.partnerLongitude,
    this.myLocationVisible = true,
    this.partnerLocationVisible = true,
    this.myLocationLabel,
    this.partnerLocationLabel,
  });

  final bool isEnabled;
  final String? distanceText;
  final double? myLatitude;
  final double? myLongitude;
  final double? partnerLatitude;
  final double? partnerLongitude;
  final bool myLocationVisible;
  final bool partnerLocationVisible;
  final String? myLocationLabel;
  final String? partnerLocationLabel;
}
