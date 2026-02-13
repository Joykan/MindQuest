import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  User? get user => _auth.currentUser;

  Future<void> signInWithGoogle() async {
    try {
      // ✅ Step 1: Start Google Sign In
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return; // user cancelled
      }

      // ✅ Step 2: Get authentication tokens
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // ✅ Step 3: Build Firebase credential
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // ✅ Step 4: Sign into Firebase
      await _auth.signInWithCredential(credential);

      notifyListeners();
    } catch (e) {
      debugPrint("Google Sign In Failed: $e");
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
    notifyListeners();
  }
}
