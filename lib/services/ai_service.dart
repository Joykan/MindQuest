import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class GeminiService {
  // Use the provided valid API key
  static const String apiKey = "AIzaSyDQvOnbWQyk1GVTyKP-dy27yBR1Xz1vkqc";

  static String get baseUrl =>
      "https://generativelanguage.googleapis.com/v1/models/gemini-1.5-pro:generateContent";

  Future<String> _callGemini(String prompt) async {
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
