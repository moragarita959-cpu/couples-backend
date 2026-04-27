enum BillStatsGranularity {
  day,
  week,
  month,
  year,
  last30,
  custom,
}

enum BillStatsChartKind {
  line,
  pie,
}

(DateTime start, DateTime end) billStatsRangeBounds(
  BillStatsGranularity g, {
  DateTime? focusMonth,
  DateTime? focusDay,
  DateTime? customStart,
  DateTime? customEnd,
}) {
  final now = DateTime.now();
  final baseMonth = focusMonth == null
      ? DateTime(now.year, now.month, 1)
      : DateTime(focusMonth.year, focusMonth.month, 1);
  final today = focusDay == null
      ? DateTime(now.year, now.month, now.day)
      : DateTime(focusDay.year, focusDay.month, focusDay.day);
  switch (g) {
    case BillStatsGranularity.day:
      return (today, today);
    case BillStatsGranularity.week:
      final start = today.subtract(Duration(days: today.weekday - DateTime.monday));
      return (start, start.add(const Duration(days: 6)));
    case BillStatsGranularity.month:
      return (
        DateTime(baseMonth.year, baseMonth.month, 1),
        DateTime(baseMonth.year, baseMonth.month + 1, 0),
      );
    case BillStatsGranularity.year:
      return (
        DateTime(baseMonth.year, 1, 1),
        DateTime(baseMonth.year, 12, 31),
      );
    case BillStatsGranularity.last30:
      return (
        today.subtract(const Duration(days: 29)),
        today,
      );
    case BillStatsGranularity.custom:
      final start = customStart == null
          ? DateTime(baseMonth.year, baseMonth.month, 1)
          : DateTime(customStart.year, customStart.month, customStart.day);
      final end = customEnd == null
          ? DateTime(baseMonth.year, baseMonth.month + 1, 0)
          : DateTime(customEnd.year, customEnd.month, customEnd.day);
      if (start.isAfter(end)) {
        return (end, start);
      }
      return (start, end);
  }
}
