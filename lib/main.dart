import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:tale3ne/pages/Start/Login_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();
Future<void> backgroundMessageHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.notification?.title}");
  // You can add your custom logic here to handle the background message.

  // If your logic involves asynchronous operations, await them here
}
void showNotification(String senderName, String messageBody) async {
  try {
    var androidDetails = AndroidNotificationDetails(
      'channelId',
      'channelName',
      importance: Importance.max,
      priority: Priority.high,
      icon: 'ic_launcher',
      // Add other necessary parameters
    );

    var platformChannelSpecifics =
    NotificationDetails(android: androidDetails);

    // Debugging statements
    print("Debug: Small Icon Resource - ${androidDetails?.icon}");

    await flutterLocalNotificationsPlugin.show(
      0,
      senderName, // Use the sender's name as the title
      messageBody, // Use the message body as the body
      platformChannelSpecifics,
      payload: 'payload',
    );
  } catch (e) {
    print('Error showing notification: $e');
  }
}
void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    // Show local notification
    showNotification(
      message.notification?.title ?? 'Title',
      message.notification?.body ?? 'Body',
    );
  });

  FirebaseMessaging.onBackgroundMessage(backgroundMessageHandler);

  runApp(MaterialApp(
    initialRoute: '/',
    routes: {
      '/': (context) => LoginPage(),
    },
  ));
}

