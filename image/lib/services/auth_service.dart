import 'package:image/services/shared_pref.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  static final AuthService _singleton = AuthService._internal();

  AuthService._internal();

  factory AuthService() {
    return _singleton;
  }

  Future<User?> getCurrentUser() async {
    return _auth.currentUser;
  }

  Future<bool> isUserLoggedIn() async {
    final user = await getCurrentUser();
    return user != null;
  }

  Future<void> signUp(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    } catch (e) {
      throw Exception("An unexpected error occurred in signUp : $e");
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);

      /// Get the user ID  from Firebase Authentication
      String userId = userCredential.user!.uid;


      /// Store userId locally for auto-login
      await SharedPreference().setStringPref(SharedPreference.userId, userId);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    } catch (e) {
      throw Exception("An unexpected error occurred in signIn : $e");
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();

      await SharedPreference().clearSharedPref(key: SharedPreference.stayLoggedIn);
    } catch (e) {
      throw Exception("Error signing out: $e");
    }
  }
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("No user is currently signed in.");
      }

      // 🔒 Re-authenticate user before updating password
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);

      // 🔑 Update password in Firebase Authentication
      await user.updatePassword(newPassword);

    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    } catch (e) {
      throw Exception("Failed to change password: $e");
    }
  }

  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'The account already exists for that email.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided for that user.';
      default:
        return 'An undefined Error happened.';
    }
  }
}