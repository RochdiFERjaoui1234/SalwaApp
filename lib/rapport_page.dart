import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:tflite_flutter/tflite_flutter.dart';

class ReportPage extends StatefulWidget {
  @override
  _ReportPageState createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  Interpreter? interpreter;

  @override
  void initState() {
    super.initState();
    loadModel().then((value) {
      print("Model loaded successfully");
      setState(() {});
    });
  }

  Future<void> loadModel() async {
    try {
      interpreter = await Interpreter.fromAsset('model.tflite');
    } catch (e) {
      print("Failed to load the model: $e");
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Report'),
        backgroundColor: theme.primaryColorDark,
      ),
      body: ListView(
        padding: const EdgeInsets.all(8.0),
        children: [
          habitsAndQuotesWidget(context, theme),
          collectionWidget('stepCounts', 'steps', '', context, theme),
          usageStatsWidget(context, theme),
        ],
      ),
    );
  }

  Widget habitsAndQuotesWidget(BuildContext context, ThemeData theme) {
    Stream<QuerySnapshot> stream =
        FirebaseFirestore.instance.collection('selectedHabits').snapshots();
    return buildMessageCard(theme, stream, "No habit was learned today.",
        "Your child learned a new habit today.");
  }

  Widget buildMessageCard(ThemeData theme, Stream<QuerySnapshot> stream,
      String noDataMessage, String dataMessage) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 4.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: stream,
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
              return Text(dataMessage, style: theme.textTheme.headline6);
            } else {
              return Text(noDataMessage, style: theme.textTheme.headline6);
            }
          },
        ),
      ),
    );
  }

  Widget collectionWidget(String collectionName, String primaryField,
      String secondaryField, BuildContext context, ThemeData theme) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection(collectionName).snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Error fetching data: ${snapshot.error}',
              style: theme.textTheme.headline6);
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        String displayText = "Your child is not moving.";
        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          int steps =
              int.tryParse(snapshot.data!.docs.first.get('steps').toString()) ??
                  0;
          if (steps < 10000 && steps > 0) {
            displayText = "Your child is moving but not very healthy.";
          } else if (steps >= 10000) {
            displayText = "Your child is moving and it's healthy.";
          }
        }
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 4.0),
          child: ListTile(
            title: Text(displayText, style: theme.textTheme.headline6),
          ),
        );
      },
    );
  }

  Widget usageStatsWidget(BuildContext context, ThemeData theme) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('usageStats2').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
          return Text("No usage data found.");
        }

        List<DocumentSnapshot> docs = snapshot.data!.docs;
        docs.sort((a, b) => convertToMilliseconds(
                (b.data() as Map<String, dynamic>)['totalTimeInForeground']
                    .toString())
            .compareTo(convertToMilliseconds(
                (a.data() as Map<String, dynamic>)['totalTimeInForeground']
                    .toString())));

        Set<String> seenApps = {};
        List<DataRow> rows = [];

        for (DocumentSnapshot document in docs) {
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
          String appName = data['appName'].toString();
          if (!seenApps.contains(appName)) {
            seenApps.add(appName);
            int milliseconds =
                convertToMilliseconds(data['totalTimeInForeground'].toString());
            rows.add(DataRow(cells: [
              DataCell(
                Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: MemoryImage(base64Decode(data['icon'])),
                    ),
                    SizedBox(width: 8),
                    Text(appName),
                  ],
                ),
              ),
              DataCell(Text(formatDuration(milliseconds))),
            ]));
          }
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('App Name')),
              DataColumn(label: Text('Usage Time')),
            ],
            rows: rows,
          ),
        );
      },
    );
  }

  String formatDuration(int milliseconds) {
    int seconds = milliseconds ~/ 1000;
    int minutes = seconds ~/ 60;
    int hours = minutes ~/ 60;
    minutes %= 60;
    return "$hours hours, $minutes minutes";
  }

  int convertToMilliseconds(String time) {
    List<String> parts = time.split(' ');
    int hours = int.tryParse(parts[0].replaceAll('h', '')) ?? 0;
    int minutes = int.tryParse(parts[1].replaceAll('min', '')) ?? 0;
    return (hours * 60 * 60 * 1000) + (minutes * 60 * 1000);
  }
}
