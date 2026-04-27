import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../../../core/network/api_client.dart';

class ChatPushService {
  ChatPushService(this._apiClient, this._readCurrentUserId, this._readCurrentCoupleId);

  final ApiClient _apiClient;
  final String? Function() _readCurrentUserId;
  final String? Function() _readCurrentCoupleId;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'chat_messages_channel',
    '聊天消息提醒',
    description: '聊天新消息提醒',
    importance: Importance.high,
    playSound: true,
    sound: RawResourceAndroidNotificationSound('chat_partner_pop'),
  );

  bool _initialized = false;
  StreamSubscription<String>? _tokenSubscription;

  Future<void> initialize() async {
    if (_initialized || !Platform.isAndroid) {
      return;
    }

    try {
      await Firebase.initializeApp();
    } catch (_) {
      // 缺失 google-services 配置时跳过推送初始化，不阻塞主流程。
      return;
    }

    final messaging = FirebaseMessaging.instance;
    final granted = await _requestPermission(messaging);
    if (!granted) {
      return;
    }

    await _localNotifications.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
    );
    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    final initialToken = await messaging.getToken();
    if (initialToken != null && initialToken.isNotEmpty) {
      await _registerToken(initialToken);
    }
    _tokenSubscription = messaging.onTokenRefresh.listen((token) async {
      await _registerToken(token);
    });

    _initialized = true;
  }

  Future<bool> _requestPermission(FirebaseMessaging messaging) async {
    final settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  Future<void> _registerToken(String token) async {
    final userId = _readCurrentUserId();
    final coupleId = _readCurrentCoupleId();
    if (userId == null || userId.isEmpty || coupleId == null || coupleId.isEmpty) {
      return;
    }
    try {
      await _apiClient.registerChatPushToken(
        coupleId: coupleId,
        userId: userId,
        token: token,
        platform: 'android',
      );
    } catch (_) {
      // 推送 token 上报失败不影响聊天流程。
    }
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    final notif = message.notification;
    if (notif == null) {
      return;
    }
    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      notif.title ?? '新消息',
      notif.body ?? '你收到一条新聊天消息',
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
          sound: _channel.sound,
        ),
      ),
    );
  }

  Future<void> dispose() async {
    await _tokenSubscription?.cancel();
  }
}
