import 'package:flutter/material.dart';
import 'chat_page.dart';
import 'taskboard.dart';
import 'trackingboard.dart';
import 'habits.dart';

class ChwelcomePage extends StatefulWidget {
  final String sessionCode;

  ChwelcomePage({required this.sessionCode});

  @override
  _ChwelcomePageState createState() => _ChwelcomePageState();
}

class _ChwelcomePageState extends State<ChwelcomePage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(_controller)
      ..addListener(() => setState(() {}));
    _controller.repeat(reverse: true); // Repeat animation
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void navigateToChatPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ChatPage()),
    );
  }

  void navigateToTaskboard() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UsageStatsPage()),
    );
  }

  void navigateToTrackingBoard() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => StepCounterScreen()),
    );
  }

  void navigateToGoodHabitsPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => GoodHabitsPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: navigateToTaskboard,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.yellow,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.yellow.withOpacity(0.5),
                          blurRadius: 10,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        Icons.star,
                        color: Colors.black,
                        size: 30,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 15),
              GestureDetector(
                onTap: navigateToTrackingBoard,
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 15),
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blueAccent.withOpacity(0.5),
                        blurRadius: 10,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Text(
                    "Today Steps",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                "Welcome to Salwa App",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              Text(
                "A Happy Child is a Child Talking To Their Parent",
                style: TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Text(
                "Session Code: ${widget.sessionCode}",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40),
              ElevatedButton(
                onPressed: navigateToGoodHabitsPage,
                child: Text('Discover a random advice'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: navigateToChatPage,
        backgroundColor: Colors.blueAccent,
        child: Icon(Icons.chat),
      ),
    );
  }
}
