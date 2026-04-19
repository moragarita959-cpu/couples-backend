class CountdownSettings {
  const CountdownSettings({
    required this.loveStartDate,
    required this.loveDaysOverride,
  });

  final DateTime? loveStartDate;
  final int? loveDaysOverride;
}
