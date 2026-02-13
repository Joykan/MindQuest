import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MoodService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> logMood(String emoji, String note) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _db.collection('mood_logs').add({
      'userId': user.uid,
      'moodEmoji': emoji,
      'note': note,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
