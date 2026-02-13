import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class GeminiService {
  // API key should be set via environment variable GOOGLE_API_KEY
  // Do not hardcode API keys in the source code
  static String get apiKey {
    const String? envApiKey = String.fromEnvironment(
      'GOOGLE_API_KEY',
      defaultValue: '',
    );
    if (envApiKey.isEmpty) {
      return 'YOUR_API_KEY_HERE';
    }
    return envApiKey;
  }

  static String get baseUrl =>
      "https://generativelanguage.googleapis.com/v1/models/gemini-1.5-pro:generateContent";

  Future<String> _callGemini(String prompt) async {
    if (apiKey == 'YOUR_API_KEY_HERE') {
      return "Error: API key not configured. Please set the GOOGLE_API_KEY environment variable.";
    }

    final String fullUrl = "$baseUrl?key=$apiKey";

    try {
      final response = await http.post(
        Uri.parse(fullUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": prompt},
              ],
            },
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["candidates"][0]["content"]["parts"][0]["text"] ??
            "MindQuest couldn't find the right words.";
      } else {
        // --- CRITICAL DEBUGGING LOG ---
        // Check your VS Code 'Debug Console' to see the actual error from Google
        debugPrint("STATUS CODE: ${response.statusCode}");
        debugPrint("ERROR BODY: ${response.body}");

        if (response.statusCode == 404) {
          return "Error 404: AI Model path not found. Please check API activation.";
        }
        return "Error ${response.statusCode}: MindQuest is recalibrating.";
      }
    } catch (e) {
      debugPrint("CONNECTION ERROR: $e");
      return "Connection failed. Please check your internet.";
    }
  }

  // CHAT LOGIC
  Future<String> getBotReply(
    String msg, {
    String mode = "general",
    String language = "en",
  }) {
    String persona = "You are MindQuest, a mental health assistant. ";
    if (mode == "therapy") persona += "Use a compassionate therapist tone. ";
    if (mode == "coaching") persona += "Use a motivational coach tone. ";

    String langPrompt = "";
    if (language == "sg") {
      langPrompt = " Respond strictly in Sheng (Kenyan slang).";
    }
    if (language == "sw") langPrompt = " Respond strictly in Swahili.";

    return _callGemini("$persona$langPrompt\nUser: $msg");
  }

  // MOOD LOGIC
  Future<String> analyzeMood(String text) {
    String prompt =
        "Analyze this mood journal entry and provide short, helpful insights: $text";
    return _callGemini(prompt);
  }
}
