import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class QuizChatScreen extends StatefulWidget {
  const QuizChatScreen({super.key});

  @override
  State<QuizChatScreen> createState() => _QuizChatScreenState();
}

class _QuizChatScreenState extends State<QuizChatScreen> {
  List<dynamic> questions = [];
  int currentIndex = 0;
  List<Map<String, String>> chatMessages = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      final String response = await rootBundle.loadString(
        'assets/questions.json',
      );
      final List<dynamic> data = await json.decode(response);
      if (data.isNotEmpty) {
        setState(() {
          questions = data;
          isLoading = false;
        });
        _startMission();
      } else {
        throw Exception("JSON is empty");
      }
    } catch (e) {
      debugPrint("Safety Hatch Triggered: $e");
      setState(() {
        isLoading = false;
        // Fallback mission if JSON fails
        questions = [
          {
            "question":
                "Connection Error: Check your assets/questions.json file.",
            "options": ["Retry", "Skip"],
            "answer": "Retry",
          },
        ];
      });
      _startMission();
    }
  }

  void _startMission() {
    if (questions.isEmpty) {
      return;
    }
    _addMessage(
      "bot",
      "🚀 Mission ${currentIndex + 1}: ${questions[currentIndex]['question']}",
    );
  }

  void _addMessage(String sender, String text) {
    setState(() {
      chatMessages.add({"sender": sender, "text": text});
    });
  }

  void _handleAnswer(String selectedOption) {
    String correctAnswer = questions[currentIndex]['answer'];
    _addMessage("user", selectedOption);

    if (selectedOption == correctAnswer) {
      _addMessage("bot", "✅ Correct! MindQuest XP Gained.");

      // Delay before next mission to let user read the feedback
      Future.delayed(const Duration(seconds: 2), () {
        // FIXED: Using proper braces and setState to advance index
        if (currentIndex < questions.length - 1) {
          setState(() {
            currentIndex++;
          });
          _startMission();
        } else {
          _addMessage("bot", "🏆 Quest Complete! You are a MindQuest Master.");
        }
      });
    } else {
      _addMessage("bot", "❌ Not quite. Focus and try that mission again!");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("MindQuest Gamified")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: chatMessages.length,
              itemBuilder: (context, index) {
                final msg = chatMessages[index];
                final isBot = msg['sender'] == 'bot';
                return Align(
                  alignment: isBot
                      ? Alignment.centerLeft
                      : Alignment.centerRight,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isBot ? Colors.white : const Color(0xFF4DB6AC),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: Text(
                      msg['text']!,
                      style: TextStyle(
                        color: isBot ? Colors.black : Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // BOTTOM OPTIONS AREA
          if (currentIndex < questions.length)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: (questions[currentIndex]['options'] as List).map((
                  option,
                ) {
                  return ElevatedButton(
                    onPressed: () => _handleAnswer(option),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(120, 45),
                    ),
                    child: Text(option),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}
