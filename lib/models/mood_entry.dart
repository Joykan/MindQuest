import 'package:cloud_firestore/cloud_firestore.dart';

class MoodEntry {
  final String id;
  final String userId;
  final String moodEmoji; // e.g., "😊", "😐", "😭"
  final String note;
  final DateTime timestamp;

  MoodEntry({
    required this.id,
    required this.userId,
    required this.moodEmoji,
    required this.note,
    required this.timestamp,
  });

  // Convert to Map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'moodEmoji': moodEmoji,
      'note': note,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
