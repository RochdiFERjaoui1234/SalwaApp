import 'package:awesome_notifications/awesome_notifications.dart';

Future<void> scheduleLearningReminder() async {
  bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
  if (!isAllowed) {
    // Optionally, prompt the user to allow notifications.
    isAllowed = await AwesomeNotifications().requestPermissionToSendNotifications();
  }

  if (!isAllowed) return;

  await AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: 1234, // Unique ID for the notification
      channelKey: 'scheduled_notifications', // Ensure this channel is initialized in your notification setup
      title: 'Time to Learn Something New',
      body: 'Dive into your studies or explore new knowledge!',
      notificationLayout: NotificationLayout.Default,
    ),
    schedule: NotificationInterval(
      interval: 120, // Interval in minutes (120 minutes = 2 hours)
      timeZone: DateTime.now().timeZoneName,
      repeats: true,
    ),
  );
}
