import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'child_welcome_page.dart';

class ChildLoginPage extends StatefulWidget {
  @override
  _ChildLoginPageState createState() => _ChildLoginPageState();
}

class _ChildLoginPageState extends State<ChildLoginPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController sessionCodeController = TextEditingController();

  String errorMessage = '';
  bool isError = false;

  void verifySessionCode() async {
    String sessionCode = sessionCodeController.text;

    DocumentSnapshot snapshot = await _firestore.collection('sessions').doc(sessionCode).get();

    if (snapshot.exists) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ChwelcomePage(sessionCode: sessionCode)),
      );
    } else {
      setState(() {
        errorMessage = "Invalid session code";
        isError = true;
      });
    }
  }

  InputDecoration getDecoration(String label) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(Icons.vpn_key),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      filled: true,
      fillColor: isError ? Colors.red[100] : const Color.fromARGB(255, 0, 0, 0),
      errorText: isError ? errorMessage : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Child Login'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(height: 50),
            Text(
              'Welcome!',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.lightBlueAccent,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Please enter your session code to continue',
              style: TextStyle(fontSize: 18, color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),
            TextField(
              controller: sessionCodeController,
              decoration: getDecoration('Session Code'),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: verifySessionCode,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlueAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              ),
              child: Text(
                'Verify Code',
                style: TextStyle(fontSize: 18),
              ),
            ),
            SizedBox(height: 20),
            Text(
              errorMessage,
              style: TextStyle(color: Colors.red, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
