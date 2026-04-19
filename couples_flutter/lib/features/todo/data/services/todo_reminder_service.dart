import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../domain/entities/todo_entry.dart';
import '../../domain/entities/todo_item.dart';

class TodoReminderService {
  TodoReminderService() : _plugin = FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;

  Future<void> ensureInitialized() async {
    if (_initialized) {
      return;
    }

    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Shanghai'));

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    const settings = InitializationSettings(android: android, iOS: ios);
    await _plugin.initialize(settings);

    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
    await _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    _initialized = true;
  }

  Future<void> syncReminders(List<TodoEntry> entries) async {
    await ensureInitialized();
    for (final entry in entries) {
      final item = entry.item;
      final shouldRemind =
          item.dueAt != null &&
          !entry.progress.meDone &&
          item.owner != TodoOwner.partner;

      if (!shouldRemind) {
        await cancel(item.id);
        continue;
      }

      await schedule(entry);
    }
  }

  Future<void> schedule(TodoEntry entry) async {
    await ensureInitialized();
    final dueAt = entry.item.dueAt;
    if (dueAt == null) {
      await cancel(entry.item.id);
      return;
    }

    final now = DateTime.now();
    var scheduledAt = dueAt.subtract(const Duration(minutes: 30));
    if (scheduledAt.isBefore(now.add(const Duration(seconds: 10)))) {
      scheduledAt = dueAt;
    }
    if (scheduledAt.isBefore(now.add(const Duration(seconds: 10)))) {
      await cancel(entry.item.id);
      return;
    }

    await _plugin.zonedSchedule(
      _notificationId(entry.item.id),
      '待办提醒',
      '即将到期：${entry.item.title}',
      tz.TZDateTime.from(scheduledAt, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'todo_due_channel',
          '待办提醒',
          channelDescription: '情侣待办的本地提醒通知',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: entry.item.id,
    );
  }

  Future<void> cancel(String todoId) async {
    await ensureInitialized();
    await _plugin.cancel(_notificationId(todoId));
  }

  int _notificationId(String todoId) {
    return todoId.codeUnits.fold<int>(
      7000,
      (value, element) => (value * 31 + element) & 0x7fffffff,
    );
  }
}
