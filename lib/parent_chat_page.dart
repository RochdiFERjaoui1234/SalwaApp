import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:intl/intl.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  TextEditingController _userInput = TextEditingController();
  bool _isLoading = false; // Loading state indicator

  static const apiKey = "AIzaSyB5KCEZaTZZe4-u2lmUIMMpK0nN6ghef_0";
  final model = GenerativeModel(model: 'gemini-pro', apiKey: apiKey);
  final List<Message> _messages = [];

  Future<void> sendMessage() async {
    final message = _userInput.text;
    if (message.isEmpty) {
      return;
    }

    // Show loading indicator before sending the message
    setState(() {
      _isLoading = true;
      _messages
          .add(Message(isUser: true, message: message, date: DateTime.now()));
    });

    final content = [Content.text(message)];
    final response = await model.generateContent(content);

    // Hide loading indicator and add the response message
    setState(() {
      _isLoading = false;
      _messages.add(Message(
          isUser: false, message: response.text ?? "", date: DateTime.now()));
      _userInput.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Salwa AI"),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                if (index == _messages.length - 1 && _isLoading) {
                  // Add a loading spinner at the end of the list
                  return Column(
                    children: [
                      Messages(
                        isUser: _messages[index].isUser,
                        message: _messages[index].message,
                        date: DateFormat('HH:mm').format(_messages[index].date),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                      ),
                    ],
                  );
                }
                return Messages(
                  isUser: _messages[index].isUser,
                  message: _messages[index].message,
                  date: DateFormat('HH:mm').format(_messages[index].date),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _userInput,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white24,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      hintText: 'Enter your message here...',
                      hintStyle: TextStyle(color: Colors.white70),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Color.fromARGB(255, 115, 15, 181),
                  radius: 25,
                  child: IconButton(
                    icon: Icon(Icons.send, color: Colors.white),
                    onPressed: !_isLoading ? sendMessage : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Message {
  final bool isUser;
  final String message;
  final DateTime date;

  Message({required this.isUser, required this.message, required this.date});
}

class Messages extends StatelessWidget {
  final bool isUser;
  final String message;
  final String date;

  const Messages({
    Key? key,
    required this.isUser,
    required this.message,
    required this.date,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 17, vertical: 15),
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 20).copyWith(
        left: isUser ? 50 : 10,
        right: isUser ? 10 : 50,
      ),
      decoration: BoxDecoration(
        color: isUser ? const Color.fromARGB(255, 198, 64, 255) : Colors.grey.shade800,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          bottomLeft: isUser ? Radius.circular(20) : Radius.zero,
          topRight: Radius.circular(20),
          bottomRight: isUser ? Radius.zero : Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message,
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
          SizedBox(height: 5),
          Text(
            date,
            style: TextStyle(fontSize: 12, color: Colors.white60),
          ),
        ],
      ),
    );
  }
}
