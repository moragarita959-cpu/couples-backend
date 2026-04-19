import '../../../countdown/domain/entities/countdown_event.dart';

class HomeSummaryFormatter {
  const HomeSummaryFormatter._();

  static String formatLoveDays(int loveDays) {
    return '\u5728\u4e00\u8d77\u7b2c $loveDays \u5929';
  }

  static String formatToday(DateTime? date) {
    if (date == null) {
      return '\u4eca\u5929';
    }
    final yyyy = date.year.toString().padLeft(4, '0');
    final mm = date.month.toString().padLeft(2, '0');
    final dd = date.day.toString().padLeft(2, '0');
    return '\u4eca\u5929\u662f $yyyy-$mm-$dd';
  }

  static String formatDistance({
    required bool isEnabled,
    required double? distanceKm,
  }) {
    if (!isEnabled || distanceKm == null) {
      return '\u8ddd\u79bb\u672a\u5f00\u542f';
    }
    return '\u4f60\u4eec\u76f8\u8ddd ${distanceKm.toStringAsFixed(1)} km';
  }

  static String formatPokeTime(DateTime? time) {
    if (time == null) {
      return '\u6700\u8fd1\u4e00\u6b21\uff1a\u6682\u65e0';
    }
    final hh = time.hour.toString().padLeft(2, '0');
    final mm = time.minute.toString().padLeft(2, '0');
    return '\u6700\u8fd1\u4e00\u6b21\uff1a$hh:$mm';
  }

  static String formatNextAnniversary({
    required CountdownEvent? nextEvent,
    required DateTime? today,
  }) {
    if (nextEvent == null) {
      return '\u6682\u65e0\u7eaa\u5ff5\u65e5';
    }
    final now = today ?? DateTime.now();
    final nowDate = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(
      nextEvent.date.year,
      nextEvent.date.month,
      nextEvent.date.day,
    );
    final diff = targetDate.difference(nowDate).inDays;
    if (diff >= 0) {
      return '${nextEvent.name} \u00b7 \u8fd8\u6709 $diff \u5929';
    }
    return '${nextEvent.name} \u00b7 \u5df2\u8fc7 ${diff.abs()} \u5929';
  }

  static String pokeButtonText({
    required bool isPoking,
    required bool justPoked,
  }) {
    if (isPoking) {
      return '\u6233\u4e00\u4e0b\u4e2d...';
    }
    if (justPoked) {
      return '\u5df2\u6233 \ud83d\udc97';
    }
    return '\u7acb\u5373\u6233\u4e00\u4e0b';
  }
}
