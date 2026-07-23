import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:forex_signals_app/core/constants/app_constants.dart';
import 'package:forex_signals_app/services/user_service.dart';

/// Background message handler must be a top-level function.
@pragma('vm:entry-point')
Future<void> firebaseBackgroundMessageHandler(RemoteMessage message) async {
  // No-op here: the OS shows the FCM notification automatically for background/terminated
  // state when the payload includes a `notification` block (as our backend sends).
}

class FcmService {
  FcmService._();
  static final FcmService instance = FcmService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  void Function(Map<String, dynamic> data)? onSignalNotificationTapped;

  Future<void> initialize() async {
    await _messaging.requestPermission(alert: true, badge: true, sound: true);

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        // Tapped a locally-shown (foreground) notification.
        if (response.payload != null) {
          onSignalNotificationTapped?.call({'signal_id': response.payload});
        }
      },
    );

    const channel = AndroidNotificationChannel(
      'forex_signals_channel',
      'AI Forex Signals',
      description: 'Notifications for new AI-generated Buy/Sell signals',
      importance: Importance.high,
    );
    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Foreground messages: FCM does NOT auto-display these, so we show a local notification.
    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      if (notification != null) {
        _localNotifications.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              importance: Importance.high,
              priority: Priority.high,
              icon: '@mipmap/ic_launcher',
            ),
          ),
          payload: message.data['signal_id'],
        );
      }
    });

    // App opened from background via notification tap
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      onSignalNotificationTapped?.call(message.data);
    });

    // App launched from terminated state via notification tap
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      onSignalNotificationTapped?.call(initialMessage.data);
    }

    await _messaging.subscribeToTopic(AppConstants.fcmSignalsTopic);
  }

  /// Call after login so the backend can also target this device individually if needed.
  Future<void> registerTokenWithBackend() async {
    try {
      final token = await _messaging.getToken();
      if (token != null) {
        await UserService().updateFcmToken(token);
      }
      _messaging.onTokenRefresh.listen((newToken) async {
        try {
          await UserService().updateFcmToken(newToken);
        } catch (e) {
          debugPrint('Failed to update refreshed FCM token: $e');
        }
      });
    } catch (e) {
      debugPrint('FCM token registration failed: $e');
    }
  }
}
