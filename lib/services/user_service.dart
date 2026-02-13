import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<void> updateUserStats(int xp, int level, String badge) async {
    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      await _db.collection('users').doc(uid).set({
        'xp': xp,
        'level': level,
        'badge': badge,
        'lastPlayed': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }

  Future<Map<String, dynamic>?> getUserStats() async {
    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      final doc = await _db.collection('users').doc(uid).get();
      return doc.data();
    }
    return null;
  }
}
