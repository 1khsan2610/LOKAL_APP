import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static Future<void> initialize(FlutterLocalNotificationsPlugin plugin) async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios     = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );
    await plugin.initialize(
      settings: const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: (details) {
        // Handle notification tap
      },
    );
  }

  static Future<void> show(
    FlutterLocalNotificationsPlugin plugin, {
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'ekonomi_lokal_main',
      'EkonomiLokal',
      channelDescription: 'Notifikasi pesanan, promo, dan Lokal Coin',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    await plugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: payload,
    );
  }
}
