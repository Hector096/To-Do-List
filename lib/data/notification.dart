import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService extends ChangeNotifier {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  //initilize notification plugin

  Future initialize() async {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings("ic_launcher");

    IOSInitializationSettings iosInitializationSettings =
        IOSInitializationSettings();

    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: androidInitializationSettings,
            iOS: iosInitializationSettings);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  //Sheduled Notification

  Future sheduledNotification( String? title, DateTime dateTime) async {
    var interval = RepeatInterval.daily;
    var bigPicture = BigPictureStyleInformation(
        DrawableResourceAndroidBitmap("ic_launcher"),
        largeIcon: DrawableResourceAndroidBitmap("ic_launcher"),
        contentTitle: "Task Notification",
        summaryText: "This is your Task",
        htmlFormatContent: true,
        htmlFormatContentTitle: true);
    var android = AndroidNotificationDetails("id", "channel", "description",
        styleInformation: bigPicture);
    var platform = new NotificationDetails(android: android);
    await _flutterLocalNotificationsPlugin.schedule(0, title, "Remainder for you $title", dateTime, platform);
  }

  //Cancel notification

  Future cancelNotification() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }
}
