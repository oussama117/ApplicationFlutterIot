import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Initialize the FlutterLocalNotificationsPlugin globally
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> showNotification(String title, String body) async {
  const AndroidNotificationDetails androidNotificationDetails =
      AndroidNotificationDetails(
    'sheep_health_channel', // Unique channel ID
    'Sheep Health Alerts', // Channel name
    channelDescription: 'Notifications for sheep health status',
    importance: Importance.high,
    priority: Priority.high,
    showWhen: true,
    icon:
        '@mipmap/ic_notification', // Notification icon (Ensure this icon exists in your resources)
  );

  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidNotificationDetails);

  await flutterLocalNotificationsPlugin.show(
    0, // Notification ID
    title,
    body,
    platformChannelSpecifics,
  );
}
