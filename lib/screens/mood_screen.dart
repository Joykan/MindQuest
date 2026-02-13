import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/ai_service.dart';

class MoodScreen extends StatefulWidget {
  const MoodScreen({super.key});

  @override
  State<MoodScreen> createState() => _MoodScreenState();
}

class _MoodScreenState extends State<MoodScreen> {
  final GeminiService gemini = GeminiService();
  final TextEditingController _moodController = TextEditingController();

  final Map<String, int> moodScores = {
    "😭": 1,
    "😞": 2,
    "😐": 3,
    "🙂": 4,
    "🤩": 5,
  };

  String aiAnalysisResult = "";
  bool isAnalyzing = false;

  void _logEmojiMood(String emoji) async {
    debugPrint("Tapped emoji: $emoji");
    final user = FirebaseAuth.instance.currentUser;

    try {
      if (user != null) {
        await FirebaseFirestore.instance.collection('mood_logs').add({
          'userId': user.uid,
          'mood': emoji,
          'score': moodScores[emoji],
          'timestamp': FieldValue.serverTimestamp(),
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("MindQuest: $emoji logged!")));
      }
    } catch (e) {
      debugPrint("Firestore Error: $e");
    }
  }

  Future<void> _analyzeTextMood() async {
    String text = _moodController.text.trim();
    if (text.isEmpty) {
      return;
    }

    setState(() {
      isAnalyzing = true;
      aiAnalysisResult = "";
    });

    try {
      String result = await gemini.analyzeMood(text);
      setState(() {
        aiAnalysisResult = result;
      });
    } catch (e) {
      setState(() {
        aiAnalysisResult = "Analysis failed. Check your API connection.";
      });
    } finally {
      if (mounted) {
        setState(() {
          isAnalyzing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("MindQuest Mood"),
          bottom: const TabBar(
            indicatorColor: Color(0xFF4DB6AC),
            tabs: [
              Tab(text: "Quick Log"),
              Tab(text: "AI Insights"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // TAB 1: QUICK LOG (Emoji Selection)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "How are you feeling?",
                    style: TextStyle(fontSize: 18, color: Colors.black54),
                  ),
                  const SizedBox(height: 40),
                  Wrap(
                    spacing: 20,
                    runSpacing: 20,
                    alignment: WrapAlignment.center,
                    children: moodScores.keys
                        .map(
                          (emoji) => Material(
                            color: Colors.white,
                            elevation: 4,
                            shape: const CircleBorder(),
                            clipBehavior: Clip.antiAlias,
                            child: InkWell(
                              onTap: () => _logEmojiMood(emoji),
                              child: Container(
                                width: 80,
                                height: 80,
                                alignment: Alignment.center,
                                child: Text(
                                  emoji,
                                  style: const TextStyle(fontSize: 40),
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
            // TAB 2: AI INSIGHTS
            SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _moodController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: "Describe your day...",
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 15),
                  ElevatedButton(
                    onPressed: isAnalyzing ? null : _analyzeTextMood,
                    child: isAnalyzing
                        ? const CircularProgressIndicator()
                        : const Text("Analyze with MindQuest AI"),
                  ),
                  if (aiAnalysisResult.isNotEmpty) ...[
                    const SizedBox(height: 25),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            // FIXED: withValues instead of withOpacity
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 5,
                          ),
                        ],
                      ),
                      child: Text(
                        aiAnalysisResult,
                        style: const TextStyle(fontSize: 16, height: 1.5),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
