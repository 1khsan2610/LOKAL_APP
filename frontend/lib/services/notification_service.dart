import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initializeNotifications() async {
    // Request permission for iOS
    if (Platform.isIOS) {
      await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: true,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
    }

    // Initialize local notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification: (id, title, body, payload) {},
    );

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _handleNotificationResponse,
    );

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);

    // Handle notification taps when app is terminated
    final initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }

    // Handle notification taps when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
  }

  /// Get FCM token
  Future<String?> getToken() async {
    try {
      return await _firebaseMessaging.getToken();
    } catch (e) {
      print('Error getting FCM token: $e');
      return null;
    }
  }

  /// Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    print('Handling foreground message: ${message.messageId}');

    // Show local notification
    _showLocalNotification(
      title: message.notification?.title ?? 'LOKAL',
      body: message.notification?.body ?? '',
      data: message.data,
    );
  }

  /// Handle background messages
  static Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    print('Handling background message: ${message.messageId}');
    // Background message handling
  }

  /// Handle notification tap
  void _handleNotificationTap(RemoteMessage message) {
    print('Notification tapped: ${message.messageId}');
    // Navigate based on message data
    // Example: if (message.data['type'] == 'order') navigateToOrderDetails();
  }

  /// Handle local notification response
  void _handleNotificationResponse(NotificationResponse response) {
    print('Notification response: ${response.payload}');
    // Handle notification tap from local notifications
  }

  /// Show local notification
  Future<void> _showLocalNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'lokal_channel',
      'LOKAL Notifications',
      channelDescription: 'Notifikasi dari Platform LOKAL',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    const DarwinNotificationDetails iosNotificationDetails =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iosNotificationDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecond,
      title,
      body,
      notificationDetails,
      payload: data != null ? Uri(queryParameters: data).toString() : null,
    );
  }

  /// Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      print('Subscribed to topic: $topic');
    } catch (e) {
      print('Error subscribing to topic: $e');
    }
  }

  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      print('Unsubscribed from topic: $topic');
    } catch (e) {
      print('Error unsubscribing from topic: $e');
    }
  }

  /// Subscribe user to notifications based on role
  Future<void> subscribeUserToTopics(String userId, String role) async {
    // Subscribe to general notifications
    await subscribeToTopic('all_users');

    // Subscribe to role-specific notifications
    if (role == 'umkm') {
      await subscribeToTopic('umkm_notifications');
      await subscribeToTopic('umkm_$userId');
    } else if (role == 'consumer') {
      await subscribeToTopic('consumer_notifications');
      await subscribeToTopic('consumer_$userId');
    } else if (role == 'producer') {
      await subscribeToTopic('producer_notifications');
      await subscribeToTopic('producer_$userId');
    }
  }

  /// Unsubscribe user from all notifications
  Future<void> unsubscribeUserFromTopics(String userId, String role) async {
    await unsubscribeFromTopic('all_users');

    if (role == 'umkm') {
      await unsubscribeFromTopic('umkm_notifications');
      await unsubscribeFromTopic('umkm_$userId');
    } else if (role == 'consumer') {
      await unsubscribeFromTopic('consumer_notifications');
      await unsubscribeFromTopic('consumer_$userId');
    } else if (role == 'producer') {
      await unsubscribeFromTopic('producer_notifications');
      await unsubscribeFromTopic('producer_$userId');
    }
  }
}
