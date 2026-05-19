import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotifService {
  static final FlutterLocalNotificationsPlugin
      flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // CALLBACK KLIK NOTIF
  static Function(String?)? onNotificationClick;

  static Future<void> init() async {
    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@drawable/ic_notification');

    const InitializationSettings settings =
        InitializationSettings(android: androidInit);

    await flutterLocalNotificationsPlugin.initialize(
      settings,

      // SAAT NOTIF DIKLIK
      onDidReceiveNotificationResponse: (details) {
        if (onNotificationClick != null) {
          onNotificationClick!(details.payload);
        }
      },
    );
  }

  static Future<void> show(
    String title,
    String body, {
    String payload = '',
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      importance: Importance.max,
      priority: Priority.high,

      // ICON
      icon: '@drawable/ic_notification',
    );

    const NotificationDetails details =
        NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      details,

      // DATA
      payload: payload,
    );
  }
}