// lib/app/data/services/auth_service.dart
// Service class for Firebase Authentication operations
import 'package:firebase_auth/firebase_auth.dart';

/// AuthService handles all Firebase Authentication operations
/// Provides methods for signup, login, and password reset
class AuthService {
  // Firebase Authentication instance
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Creates a new user account with email and password
  /// 
  /// Parameters:
  ///   - email: User's email address
  ///   - password: User's password
  /// 
  /// Returns:
  ///   - User object if signup successful
  /// 
  /// Throws:
  ///   - String with user-friendly error message
  Future<User?> signup(String email, String password) async {
    try {
      // Create new user account in Firebase Auth
      final cred = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      
      // Send email verification link to user's email
      await cred.user!.sendEmailVerification();
      
      return cred.user;
    } on FirebaseAuthException catch (e) {
      // Convert Firebase error to user-friendly message
      throw _handleAuthException(e);
    }
  }

  /// Authenticates user with email and password
  /// 
  /// Parameters:
  ///   - email: User's email address
  ///   - password: User's password
  /// 
  /// Returns:
  ///   - User object if login successful
  /// 
  /// Throws:
  ///   - String with user-friendly error message
  Future<User?> login(String email, String password) async {
    try {
      // Validate inputs before calling Firebase
      if (email.isEmpty || password.isEmpty) {
        throw 'Email or password is empty';
      }
      
      // Sign in user with Firebase Authentication
      final cred = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      
      return cred.user;
    } on FirebaseAuthException catch (e) {
      // Convert Firebase error to user-friendly message
      throw _handleAuthException(e);
    } catch (e) {
      // Re-throw any other errors
      rethrow;
    }
  }

  /// Sends password reset email to user
  /// 
  /// Parameters:
  ///   - email: User's email address
  /// 
  /// Throws:
  ///   - String with user-friendly error message
  Future<void> resetPassword(String email) async {
    try {
      // Send password reset email via Firebase
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      // Convert Firebase error to user-friendly message
      throw _handleAuthException(e);
    }
  }

  /// Gets the currently authenticated user
  User? get currentUser => _auth.currentUser;

  /// Converts Firebase Auth exceptions to user-friendly error messages
  /// 
  /// Parameters:
  ///   - e: FirebaseAuthException from Firebase
  /// 
  /// Returns:
  ///   - User-friendly error message string
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Invalid email or password.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password is too weak. Please use a stronger password.';
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return e.message ?? 'An error occurred. Please try again.';
    }
  }
}
