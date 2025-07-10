import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:chitchat/services/seesion_manager.dart'; 

class AnimatedDots extends StatefulWidget {
  const AnimatedDots({super.key});

  @override
  State<AnimatedDots> createState() => _AnimatedDotsState();
}

class _AnimatedDotsState extends State<AnimatedDots> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _animations = List.generate(3, (index) {
      final start = index * 0.2;
      final end = start + 0.4;
      return Tween<double>(begin: 0, end: -8).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(start, end, curve: Curves.easeInOut),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text("Typing", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w500)),
        const SizedBox(width: 6),
        ...List.generate(3, (index) {
          return AnimatedBuilder(
            animation: _controller,
            builder: (_, child) {
              return Transform.translate(
                offset: Offset(0, _animations[index].value),
                child: child,
              );
            },
            child: Container(
              width: 5,
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: const BoxDecoration(
                color: Colors.black87,
                shape: BoxShape.circle,
              ),
            ),
          );
        }),
      ],
    );
  }
}

class ChatBotScreen extends StatefulWidget {
  const ChatBotScreen({super.key});

  @override
  State<ChatBotScreen> createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, String>> messages = [];

  Future<String> sendMessage(String message) async {
    final url = Uri.parse('https://legendai.onrender.com/api/chat');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
      "session_id": SessionManager().sessionId,
  "prompt": "$message\nCustomer ID: ${SessionManager().customerId}\nName: ${SessionManager().customerName}",
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["response"] ?? "No response received.";
      } else {
        return "Server error: ${response.statusCode}";
      }
    } catch (e) {
      return "Something went wrong.";
    }
  }

  void sendMessages() async {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        messages.add({'sender': 'user', 'text': text});
        messages.add({'sender': 'bot', 'text': 'typing'});
      });

      _controller.clear();

      final botResponse = await sendMessage(text);

      setState(() {
        messages.removeLast(); // remove "typing"
        messages.add({'sender': 'bot', 'text': botResponse});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black54,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Legend AI', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black87,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final isUser = message['sender'] == 'user';
                final isTyping = message['text'] == 'typing';

                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.grey.shade300 : Colors.deepOrange.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: isTyping
                        ? const AnimatedDots()
                        : Text(
                            message['text'] ?? '',
                            style: TextStyle(color: isUser ? Colors.black87 : Colors.black87),
                          ),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            color: Colors.deepOrange,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Type your message...',
                      hintStyle: TextStyle(color: Colors.white),
                      border: InputBorder.none,
                    ),
                    style: const TextStyle(color: Colors.white),
                    onSubmitted: (_) => sendMessages(),
                  ),
                ),
                IconButton(
                  onPressed: sendMessages,
                  icon: const Icon(Icons.send),
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
