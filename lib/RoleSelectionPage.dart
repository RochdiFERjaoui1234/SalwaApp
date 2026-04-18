import 'package:flutter/material.dart';
import 'parentauth.dart';
import 'childauth.dart';
import 'singup.dart'; // Import the SignupPage

class RoleSelectionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Your Role'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () => showInformationDialog(context),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton.icon(
              icon: Icon(Icons.supervisor_account),
              label: Text('Parent'),
              onPressed: () => navigateToPage(context, 'Parent'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purpleAccent,
                foregroundColor: Colors.white,
                minimumSize: Size(200, 50),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              icon: Icon(Icons.child_care),
              label: Text('Child'),
              onPressed: () => navigateToPage(context, 'Child'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlueAccent,
                foregroundColor: Colors.white,
                minimumSize: Size(200, 50),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              icon: Icon(Icons.person_add),
              label: Text('Sign Up'),
              onPressed: () => navigateToPage(context, 'SignUp'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                minimumSize: Size(200, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void navigateToPage(BuildContext context, String role) {
    if (role == 'Parent') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ParentLoginPage()),
      );
    } else if (role == 'Child') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ChildLoginPage()),
      );
    } else if (role == 'SignUp') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SignupPage()),
      );
    }
  }

  void showInformationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Welcome to Salwa App'),
          content: Text(
              'Our future-oriented child monitoring application. This platform is designed to inspire the children of tomorrow by promoting better behaviors. Please note that the app is currently in its Beta version.'),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
