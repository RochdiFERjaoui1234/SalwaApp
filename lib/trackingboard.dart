import 'package:flutter/material.dart';
import 'package:usage_stats/usage_stats.dart';
import 'package:device_apps/device_apps.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:awesome_notifications/awesome_notifications.dart';

String formatMilliseconds(int ms) {
  int seconds = ms ~/ 1000;
  int minutes = (seconds ~/ 60) % 60;
  int hours = seconds ~/ 3600;
  return '${hours}h ${minutes.toString().padLeft(2, '0')}min';
}

class UsageStatsPage extends StatefulWidget {
  @override
  _UsageStatsPageState createState() => _UsageStatsPageState();
}

class _UsageStatsPageState extends State<UsageStatsPage> {
  Future<List<Map<String, dynamic>>>? _usageStatsFuture;

  @override
  void initState() {
    super.initState();
    AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: 'high_usage_channel',
          channelName: 'High Usage Alerts',
          channelDescription: 'Notification channel for high usage alerts',
          importance: NotificationImportance.High,
          defaultColor: Colors.deepPurple,
          ledColor: Colors.white
        )
      ],
    );
    _usageStatsFuture = _getUsageStats();
  }

  Future<List<Map<String, dynamic>>> _getUsageStats() async {
  List<Map<String, dynamic>> usageStatsList = [];
  DateTime endDate = DateTime.now();
  DateTime startDate = DateTime(endDate.year, endDate.month, endDate.day);

  UsageStats.grantUsagePermission();
  bool isPermissionGranted = await UsageStats.checkUsagePermission() ?? false;

  if (isPermissionGranted) {
    List<UsageInfo> usageStats = await UsageStats.queryUsageStats(startDate, endDate);

    for (UsageInfo usageInfo in usageStats) {
      if (usageInfo.packageName != null) {
        ApplicationWithIcon? app = await DeviceApps.getApp(usageInfo.packageName!, true) as ApplicationWithIcon?;
        if (app != null &&
            !app.packageName.startsWith('com.android') &&
            !app.packageName.startsWith('com.google')) {
          int totalTimeInForeground = int.tryParse(usageInfo.totalTimeInForeground ?? '') ?? 0;
          if (totalTimeInForeground > 3600000) { // Check if usage is more than an hour
            _showNotification(app.appName, totalTimeInForeground);
          }
          String formattedTime = formatMilliseconds(totalTimeInForeground);
          var stat = {
            'appName': app.appName,
            'totalTimeInForeground': formattedTime, // Storing formatted time
            'icon': base64Encode(app.icon)
          };

          // Save to Firestore
          await FirebaseFirestore.instance.collection('usageStats2').add(stat);

          usageStatsList.add(stat);
        }
      }
    }
    usageStatsList.sort((a, b) => b['totalTimeInForeground'].compareTo(a['totalTimeInForeground']));
  } else {
    print('Usage permission is not granted.');
  }

  return usageStatsList;
}

  Future<void> _showNotification(String appName, int totalTimeInForeground) async {
    String formattedTime = formatMilliseconds(totalTimeInForeground);
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        channelKey: 'high_usage_channel',
        title: 'High Usage Alert',
        body: '$appName has been used for $formattedTime today',
        notificationLayout: NotificationLayout.Default
      )
    );
  }

  @override
  Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Your Recent Activities'),
          backgroundColor: Colors.deepPurple,
        ),
        body: FutureBuilder<List<Map<String, dynamic>>>(
          future: _usageStatsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.hasData) {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  Map<String, dynamic> item = snapshot.data![index];
                  // 'totalTimeInForeground' is now a formatted string, not an int
                  String formattedTime = item['totalTimeInForeground'];

                  return Card(
                    elevation: 5.0,
                    margin: EdgeInsets.all(10.0),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: MemoryImage(base64Decode(item['icon'])),
                        backgroundColor: Colors.deepPurple,
                      ),
                      title: Text(
                        item['appName'],
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Total time in foreground: $formattedTime',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  );
                },
              );
            } else {
              return Center(child: Text('No data available'));
            }
          },
        ),
      );
    }

}

//777