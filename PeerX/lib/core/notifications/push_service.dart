import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'notification_service.dart';

// Top-level function required by Firebase for background message handling
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('[PushService] Background message received: ${message.messageId}');
}

class PushService {
  PushService._();
  static final PushService _instance = PushService._();
  factory PushService() => _instance;

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  Future<void> init() async {
    // Register background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Request permission on iOS
    if (Platform.isIOS) {
      await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    // Get FCM token safely — APNs token may not be ready immediately on iOS
    await _fetchToken();

    // Listen for token refresh
    _messaging.onTokenRefresh.listen((newToken) {
      _fcmToken = newToken;
      print('[PushService] FCM token refreshed: $newToken');
    });

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      if (notification != null) {
        final fromId     = message.data['from'] as String? ?? 'unknown';
        final senderName = notification.title ?? fromId;
        NotificationService().showMessageNotification(
          conversationId: fromId,
          senderName:     senderName,
        );
      }
    });

    // Handle notification tap from background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('[PushService] Notification tapped from background: ${message.data}');
    });

    // Handle notification tap from terminated state
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      print('[PushService] Launched from notification: ${initialMessage.data}');
    }

    // iOS: suppress Firebase's own foreground notification — we handle it
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: false,
      badge: true,
      sound: false,
    );
  }

  Future<void> _fetchToken() async {
    try {
      if (Platform.isIOS) {
        // APNs token must exist before FCM token is available.
        // Retry once after a short delay if not immediately ready.
        String? apnsToken = await _messaging.getAPNSToken();
        if (apnsToken == null) {
          await Future.delayed(const Duration(seconds: 3));
          apnsToken = await _messaging.getAPNSToken();
        }
        if (apnsToken == null) {
          print('[PushService] APNs token unavailable — add Push Notifications '
              'capability in Xcode → Runner → Signing & Capabilities.');
          return;
        }
      }
      _fcmToken = await _messaging.getToken();
      print('[PushService] FCM token: $_fcmToken');
    } catch (e) {
      // Non-fatal — app works fine without push when online
      print('[PushService] Could not get FCM token: $e');
    }
  }
}