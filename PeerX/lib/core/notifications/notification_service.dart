import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final _plugin = FlutterLocalNotificationsPlugin();

  String? _expoPushToken;
  String? get expoPushToken => _expoPushToken;

  void Function(String conversationId)? onNotificationTap;

  // ── Init ──────────────────────────────────────────────────────────────────

  Future<void> init() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload != null && onNotificationTap != null) {
          try {
            final data = jsonDecode(payload) as Map<String, dynamic>;
            final conversationId = data['conversationId'] as String?;
            if (conversationId != null) {
              onNotificationTap!(conversationId);
            }
          } catch (_) {}
        }
      },
    );

    final androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        'messages',
        'Messages',
        description: 'New encrypted messages',
        importance: Importance.high,
      ),
    );
  }

  // ── Show Notification ─────────────────────────────────────────────────────

  Future<void> showMessageNotification({
    required String conversationId,
    required String senderName,
  }) async {
    await _plugin.show(
      conversationId.hashCode,
      senderName,
      'New encrypted message',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'messages',
          'Messages',
          channelDescription: 'New encrypted messages',
          importance: Importance.high,
          priority: Priority.high,
          showWhen: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: jsonEncode({'conversationId': conversationId}),
    );
  }

  // ── Push Token ────────────────────────────────────────────────────────────

  void registerPushToken(String token) {
    _expoPushToken = token;
  }

  // ── Send Push via Expo ────────────────────────────────────────────────────

  Future<void> sendExpoPush({
    required String token,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      await http.post(
        Uri.parse('https://exp.host/--/api/v2/push/send'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'to': token,
          'title': title,
          'body': body,
          'data': data ?? {},
          'sound': 'default',
          'priority': 'high',
        }),
      );
    } catch (_) {}
  }
}