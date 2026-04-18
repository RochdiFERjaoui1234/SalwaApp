import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChildLocationUpdate extends StatefulWidget {
  @override
  _ChildLocationUpdateState createState() => _ChildLocationUpdateState();
}

class _ChildLocationUpdateState extends State<ChildLocationUpdate> {
  @override
  void initState() {
    super.initState();
    _updateLocationPeriodically();
  }

  Future<void> _updateLocationPeriodically() async {
    const locationUpdateInterval = Duration(minutes: 5); // Update every 5 minutes
    while (true) {
      await _updateLocation();
      await Future.delayed(locationUpdateInterval);
    }
  }

  Future<void> _updateLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      FirebaseFirestore.instance.collection('children').doc('childId').update({
        'location': GeoPoint(position.latitude, position.longitude),
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Failed to get location: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Child Location Service'),
        backgroundColor: Colors.blue[900], // Example color, adjust according to your app theme
      ),
      body: Center(
        child: Text('Location tracking active...', style: TextStyle(color: Colors.white)),
      ),
      backgroundColor: Colors.blue[100], // Example color, adjust according to your app theme
    );
  }
}
