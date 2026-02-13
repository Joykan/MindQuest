import 'package:flutter/material.dart';

class CrisisService {
  static final List<String> dangerWords = [
    "suicide",
    "kill myself",
    "die",
    "hurt myself",
    "kujiua",
  ];

  static bool isCrisis(String message) {
    for (var word in dangerWords) {
      if (message.toLowerCase().contains(word)) return true;
    }
    return false;
  }

  static void showHelplineDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF111B2A),
        title: const Text(
          "⚠️ Help is Available",
          style: TextStyle(color: Colors.redAccent),
        ),
        content: const Text(
          "You are not alone. Please contact a professional.\n\n📞 Befrienders Kenya: +254 722 178 177\n📞 Red Cross: 1199",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }
}
