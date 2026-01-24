import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'database_service.dart';

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final DatabaseService _databaseService = DatabaseService();
  String? _fcmToken;

  String? get fcmToken => _fcmToken;

  // Initialize notifications
  Future<void> initialize() async {
    try {
      // Request permission for notifications
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint('User granted permission');

        // Get FCM token
        _fcmToken = await _messaging.getToken();
        debugPrint('FCM Token: $_fcmToken');

        // Save token to Firebase if user is logged in
        await _saveFcmTokenToFirebase(_fcmToken);

        // Listen to token refresh
        _messaging.onTokenRefresh.listen((newToken) async {
          _fcmToken = newToken;
          debugPrint('FCM Token refreshed: $newToken');
          // Save refreshed token to Firebase
          await _saveFcmTokenToFirebase(newToken);
        });

        // Handle foreground messages
        FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

        // Handle background messages
        FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler,
        );

        // Handle notification taps
        FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
      } else {
        debugPrint('User declined or has not accepted permission');
      }
    } catch (e) {
      debugPrint('Error initializing notifications: ${e.toString()}');
    }
  }

  // Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('Got a message whilst in the foreground!');
    debugPrint('Message data: ${message.data}');

    if (message.notification != null) {
      debugPrint(
        'Message also contained a notification: ${message.notification}',
      );
    }
  }

  // Handle notification tap
  void _handleNotificationTap(RemoteMessage message) {
    debugPrint('Notification tapped!');
    debugPrint('Message data: ${message.data}');
  }

  // Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      debugPrint('Subscribed to topic: $topic');
    } catch (e) {
      debugPrint('Error subscribing to topic: ${e.toString()}');
    }
  }

  // Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      debugPrint('Unsubscribed from topic: $topic');
    } catch (e) {
      debugPrint('Error unsubscribing from topic: ${e.toString()}');
    }
  }

  // Save FCM token to Firebase
  Future<void> _saveFcmTokenToFirebase(String? token) async {
    if (token == null) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await _databaseService.updateFcmToken(user.uid, token);
        debugPrint('✅ FCM token saved to Firebase for user: ${user.uid}');
      } catch (e) {
        debugPrint('❌ Error saving FCM token to Firebase: $e');
      }
    } else {
      debugPrint('⚠️ No user logged in, FCM token not saved to Firebase');
    }
  }

  // Force save current token (useful after login)
  Future<void> saveFcmToken() async {
    await _saveFcmTokenToFirebase(_fcmToken);
  }
}

// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Handling a background message: ${message.messageId}');
}
