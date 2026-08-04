import 'dart:developer' as developer;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

abstract class NotificationService {
  Future<void> init();
  Future<void> showNotification({required int id, required String title, required String body});
  Future<bool> requestPermissions();
}

class NotificationServiceImpl implements NotificationService {
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  @override
  Future<void> init() async {
    // 1. Initialize Local Notifications
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    
    const initSettings = InitializationSettings(android: androidSettings, iOS: iosSettings);
    
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        developer.log('Notification tapped: ${details.payload}');
      },
    );

    // 2. Initialize Firebase Messaging (wrapped in try-catch to avoid crashes when firebase is not configured)
    try {
      if (Firebase.apps.isNotEmpty) {
        final messaging = FirebaseMessaging.instance;

        // Foreground messaging configuration
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          developer.log('FCM Foreground message received: ${message.notification?.title}');
          if (message.notification != null) {
            showNotification(
              id: message.hashCode,
              title: message.notification!.title ?? 'Weather Alert',
              body: message.notification!.body ?? '',
            );
          }
        });

        FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

        final token = await messaging.getToken();
        developer.log('FCM Token: $token');
      } else {
        developer.log('Firebase not initialized. FCM notifications disabled.');
      }
    } catch (e) {
      developer.log('Error initializing Firebase Messaging: $e');
    }
  }

  @override
  Future<void> showNotification({required int id, required String title, required String body}) async {
    const androidDetails = AndroidNotificationDetails(
      'weather_alerts_channel',
      'Weather Alerts',
      channelDescription: 'Notifications for severe weather alerts',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const platformDetails = NotificationDetails(android: androidDetails, iOS: iosDetails);
    
    await _localNotifications.show(id, title, body, platformDetails);
  }

  @override
  Future<bool> requestPermissions() async {
    // Request local notification permissions
    final androidGranted = await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission() ?? false;

    // Request iOS permissions
    final iosGranted = await _localNotifications
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true) ?? false;

    // Request FCM permissions if Firebase is initialized
    var fcmGranted = false;
    try {
      if (Firebase.apps.isNotEmpty) {
        final settings = await FirebaseMessaging.instance.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );
        fcmGranted = settings.authorizationStatus == AuthorizationStatus.authorized;
      }
    } catch (_) {}

    return androidGranted || iosGranted || fcmGranted;
  }
}

// Background FCM Handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  developer.log('Handling background message: ${message.messageId}');
}
