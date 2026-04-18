import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart' ;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class StepCounterScreen extends StatefulWidget {
  @override
  _StepCounterScreenState createState() => _StepCounterScreenState();
}

class _StepCounterScreenState extends State<StepCounterScreen> {
  int _totalSteps = 0;
  late StreamSubscription<StepCount> _stepCountStream;

  @override
  void initState() {
    super.initState();
    _startListening();
  }

  void _startListening() {
    _stepCountStream = Pedometer.stepCountStream.listen(
      _onStepCount,
      onError: _onStepCountError,
      cancelOnError: true,
    );
  }
  void _onStepCount(StepCount event) {
    setState(() {
      _totalSteps = event.steps; // Use the steps property of the StepCount object
    });
    _saveStepsToFirestore(_totalSteps); // Save to Firestore
  }

  void _onStepCountError(dynamic error) {
    print('Failed to get step count: $error');
    setState(() {
      _totalSteps = 0;
    });
  }

  Future<void> _saveStepsToFirestore(int steps) async {
    // Firestore document reference
    DocumentReference ref = FirebaseFirestore.instance.collection('stepCounts').doc('daily');

    // Update the Firestore document
    await ref.set({
      'date': DateTime.now(),
      'steps': steps,
    }, SetOptions(merge: true));
  }

  @override
  void dispose() {
    _stepCountStream.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Step Counter'),
        backgroundColor: Colors.black87,
      ),
      body: Container(
        color: Colors.black54,
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[900],
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    blurRadius: 10,
                    color: Colors.blueAccent,
                    spreadRadius: 5,
                  )
                ]),
              child: Center(
                child: Text(
                  '$_totalSteps',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(height: 25),
            Text(
              'Today: Total Steps',
              style: TextStyle(
                fontSize: 30,
                color: Colors.white70,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              padding: EdgeInsets.all(8),
              margin: EdgeInsets.only(top: 20),
              decoration: BoxDecoration(
                color: _totalSteps >= 10000 ? Colors.green : Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _totalSteps >= 10000 ? 'Healthy! Keep it up!' : 'You should move more!',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
