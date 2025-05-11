import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // Initialize notification service
  Future<void> init() async {
    // Request permissions
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Setup local notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@drawable/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Get FCM token
    String? token = await _messaging.getToken();
    if (token != null) {
      await _saveTokenToDatabase(token);
    }

    // Listen to token refreshes
    _messaging.onTokenRefresh.listen(_saveTokenToDatabase);

    // Set up background message handling
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  // Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) async {
    // Display a local notification
    await _showLocalNotification(
      title: message.notification?.title ?? 'New Notification',
      body: message.notification?.body ?? '',
      payload: message.data.toString(),
    );
  }

  // Show local notification
  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'default_channel_id',
      'Default Channel',
      channelDescription: 'Default notification channel',
      importance: Importance.max,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails();

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _localNotifications.show(
      0, // Notification ID
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  // Handler for notification taps
  void _onNotificationTapped(NotificationResponse details) {
    // Handle notification tap (e.g., navigate to specific screen)
    // This would be implemented based on the app's navigation requirements
  }

  // Save FCM token to Firestore
  Future<void> _saveTokenToDatabase(String token) async {
    final userId = _auth.currentUser?.uid;
    if (userId != null) {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('tokens')
          .doc(token)
          .set({
        'token': token,
        'createdAt': FieldValue.serverTimestamp(),
        'platform': _getPlatform(),
      });
    }
  }

  // Get device platform
  String _getPlatform() {
    if (bool.hasEnvironment('dart.library.io')) {
      return 'mobile';
    } else if (bool.hasEnvironment('dart.library.html')) {
      return 'web';
    } else {
      return 'unknown';
    }
  }

  // Subscribe to specific topics based on user preferences
  Future<void> subscribeToTopics(
      Map<String, bool> notificationPreferences) async {
    if (notificationPreferences['orderUpdates'] == true) {
      await _messaging.subscribeToTopic('orderUpdates');
    } else {
      await _messaging.unsubscribeFromTopic('orderUpdates');
    }

    if (notificationPreferences['promotions'] == true) {
      await _messaging.subscribeToTopic('promotions');
    } else {
      await _messaging.unsubscribeFromTopic('promotions');
    }

    if (notificationPreferences['newProducts'] == true) {
      await _messaging.subscribeToTopic('newProducts');
    } else {
      await _messaging.unsubscribeFromTopic('newProducts');
    }
  }

  // Clean up tokens when user logs out
  Future<void> cleanupTokens() async {
    final userId = _auth.currentUser?.uid;
    if (userId != null) {
      final token = await _messaging.getToken();
      if (token != null) {
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('tokens')
            .doc(token)
            .delete();
      }
    }
  }
}

// Define this at the top level for background message handling
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Handle background messages
  // Note: This needs to be implemented outside the class as a top-level function
}
