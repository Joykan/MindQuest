import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/quiz_chat_screen.dart';
import 'screens/ai_chat_screen.dart';
import 'screens/mood_screen.dart';
import 'screens/resources_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initializes Firebase with the configuration from flutterfire configure
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MindQuestApp());
}

class MindQuestApp extends StatelessWidget {
  const MindQuestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "MindQuest",
      theme: ThemeData(
        useMaterial3: true,
        // Clinical/Calm Theme Colors
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4DB6AC), // Soft Teal
          primary: const Color(0xFF4DB6AC),
          secondary: const Color(0xFF80CBC4),
          surface: Colors.white,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F7FB), // Pale Blue-Grey
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF37474F), // Charcoal Text
          elevation: 0,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4DB6AC),
            foregroundColor: Colors.white,
            minimumSize: const Size(250, 55),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Gradient background for a welcoming feel
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE0F2F1), Color(0xFFF5F7FB)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Branding Icon
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 15,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(
                Icons.psychology,
                size: 80,
                color: Color(0xFF4DB6AC),
              ),
            ),
            const SizedBox(height: 25),

            // Welcome Text
            const Text(
              "MindQuest",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF37474F),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
              child: Text(
                "Your secure AI companion for mental wellness and insights.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            ),
            const SizedBox(height: 40),

            // NAVIGATION BUTTONS
            _buildNavBtn(context, "AI Chat Assistant 💬", const AiChatScreen()),
            const SizedBox(height: 15),
            _buildNavBtn(context, "Mood Analysis 🧠", const MoodScreen()),
            const SizedBox(height: 15),
            _buildNavBtn(context, "Gamified Quest 🎮", const QuizChatScreen()),
            const SizedBox(height: 15),
            _buildNavBtn(
              context,
              "Wellness Library 📚",
              const ResourcesScreen(),
            ),
          ],
        ),
      ),
    );
  }

  // Helper Widget for consistent buttons
  Widget _buildNavBtn(BuildContext context, String title, Widget targetPage) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => targetPage),
        );
      },
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }
}
