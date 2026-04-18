import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'RoleSelectionPage.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Required for Firebase initialization
  await initializeFirebase(); // Initialize Firebase
  await initializeNotifications(); // Initialize notifications
  await showWelcomeNotification(); // Show welcome notification
  runApp(MyApp());
}
Future<void> initializeFirebase() async {
  await Firebase.initializeApp();
}

Future<void> initializeNotifications() async {
  await AwesomeNotifications().initialize(
      null, // Set the icon for your app notification here, or null to use the default icon
      [
        NotificationChannel(
          channelKey: 'scheduled_notifications',
          channelName: 'Scheduled Notifications',
          channelDescription: 'Notification channel for scheduled reminders',
          defaultColor: Colors.deepPurple,
          ledColor: Colors.white,
          playSound: true,
          enableLights: true,
          enableVibration: true,
          importance: NotificationImportance.High,
        )
      ],
      debug: true // Set to true to see logs from the notification library
      );
}

Future<void> showWelcomeNotification() async {
  bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
  if (!isAllowed) {
    isAllowed =
        await AwesomeNotifications().requestPermissionToSendNotifications();
  }

  if (isAllowed) {
    await AwesomeNotifications().createNotification(
        content: NotificationContent(
      id: 1, // Unique ID for this notification
      channelKey: 'scheduled_notifications', // Use the appropriate channel key
      title: 'Welcome to Our App!',
      body: 'Welcome Back!',
      notificationLayout: NotificationLayout.Default,
    ));
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: RoleSelectionPage(),
    );
  }
}

class AppManager {
  static const platform =
      MethodChannel('package com.example.appmanager/channel');

  Future<void> monitorApps() async {
    try {
      await platform.invokeMethod('monitorApps');
    } on PlatformException catch (e) {
      print("Failed to monitor apps: '${e.message}'.");
    }
  }
}

const platform = MethodChannel('com.yourcompany.app/notifications');
Future<void> checkAndShowNotification(String appName, int usage) async {
  if (usage > 3600000) {
    // More than an hour
    try {
      await platform.invokeMethod('showNotification', {'appName': appName});
    } catch (e) {
      print('Failed to invoke native method: $e');
    }
  }
}
