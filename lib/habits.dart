import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

class GoodHabitsPage extends StatefulWidget {
  @override
  _GoodHabitsPageState createState() => _GoodHabitsPageState();
}

class _GoodHabitsPageState extends State<GoodHabitsPage> with SingleTickerProviderStateMixin {
  List<String> habits = [
    // Your list of habits...
    'Brushing teeth twice a day',
    'Washing hands before and after meals.',
    'Making the bed after waking up.',
    'Saying "please" and "thank you" consistently.',
    'Eating a balanced diet with fruits and vegetables.',
    'Drinking plenty of water throughout the day.',
    'Engaging in physical activity or exercise regularly.',
    'Reading books for pleasure and education.',
    'Cleaning up toys and belongings after playtime.',
    'Setting aside time for homework or studying.',
    'Speaking honestly and respectfully to others.',
    'Keeping a regular sleep schedule and getting enough rest.',
    'Using manners, such as holding doors open for others.',
    'Completing chores around the house.',
    'Practicing good table manners during meals.',
    'Being mindful of personal space and boundaries.',
    'Expressing gratitude for what they have.',
    'Being responsible for their own belongings.',
    'Respecting elders and authority figures.',
    'Learning to share with siblings and friends.',
    'Being punctual and arriving on time for appointments or events.',
    'Saying "Im sorry" when they make a mistake.',
    'Being kind to animals and treating them with care.',
    'Asking for help when needed instead of struggling alone.',
    'Being open to trying new foods and experiences.',
    'Setting goals and working towards achieving them.',
    'Practicing good hygiene, including showering regularly.',
    'Being mindful of their surroundings and cleaning up litter.',
    'Offering to help others in need.',
    'Speaking up against bullying or unfair treatment.',
    'Learning to manage and express emotions in healthy ways.',
    'Keeping track of their belongings and organizing them properly.',
    'Respecting different cultures, backgrounds, and beliefs.',
    'Being a good listener and showing empathy towards others.',
    'Taking breaks and relaxing when feeling overwhelmed.',
    'Being responsible for their actions and accepting consequences.',
    'Following safety rules at home, school, and in public places.',
    'Practicing gratitude by keeping a gratitude journal.',
    'Using technology responsibly and in moderation.',
    'Being environmentally conscious by recycling and conserving resources.',
    'Being polite to neighbors and members of the community.',
    'Standing up for what is right, even if it',
        'Learning basic first aid',
    // Add more habits as needed
  ];
  String selectedHabit = 'Tap the button to get a habit';
  String randomQuote = 'Tap the button to get a quote';
  AnimationController? controller;
  Animation<double>? animation;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    animation = CurvedAnimation(parent: controller!, curve: Curves.easeInOutCirc);
  }

  void getRandomHabit() {
    final random = Random();
    int index = random.nextInt(habits.length);
    setState(() {
      selectedHabit = habits[index];
      controller!.forward(from: 0.0);
    });
    _saveHabitToFirestore(selectedHabit); // Save the selected habit to Firestore
  }

  Future<void> _saveHabitToFirestore(String habit) async {
    await FirebaseFirestore.instance.collection('selectedHabits').add({
      'habit': habit,
      'timestamp': Timestamp.now(),
    });
  }

  Future<void> fetchRandomQuote() async {
    const url = 'https://famous-quotes4.p.rapidapi.com/random?category=all&count=1';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'X-Rapidapi-Key': 'a387a6ada9msh0519e8edd6428fep1bd285jsn578d1dea7448',
          'X-Rapidapi-Host': 'famous-quotes4.p.rapidapi.com',
        },
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data is List && data.isNotEmpty && data[0]['text'] != null) {
          setState(() {
            randomQuote = data[0]['text']; // Adjust to use the 'text' field
          });
          _saveQuoteToFirestore(randomQuote); // Save the fetched quote to Firestore
        } else {
          setState(() {
            randomQuote = "No quote found.";
          });
        }
      } else {
        setState(() {
          randomQuote = "Failed to fetch quote.";
        });
      }
    } catch (e) {
      setState(() {
        randomQuote = "Error fetching quote.";
      });
    }
  }

  Future<void> _saveQuoteToFirestore(String quote) async {
    await FirebaseFirestore.instance.collection('randomQuotes').add({
      'quote': quote,
      'timestamp': Timestamp.now(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Random Advices and Quotes'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RotationTransition(
              turns: animation!,
              child: Text(
                selectedHabit,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: getRandomHabit,
              child: Text('Get a Random Habit'),
            ),
            SizedBox(height: 40),
            Text(
              randomQuote,
              style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: fetchRandomQuote,
              child: Text('Get a Random Quote'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
