// lib/app/modules/auth/viewmodels/login_viewmodel.dart
// ViewModel for user login functionality
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../data/services/call_service.dart';

/// LoginViewModel manages the user authentication process
/// Handles email/password login and email verification checks
class LoginViewModel extends GetxController {
  // Auth service for Firebase Authentication operations
  final AuthService _authService = AuthService();

  // Observable state variables
  var email = ''.obs;              // User's email address
  var password = ''.obs;           // User's password
  var isLoading = false.obs;       // Loading state during login
  
  // Development mode flag - set to false in production to enforce email verification
  final bool skipEmailVerification = true;

  /// Authenticates user with email and password
  /// 
  /// Process:
  /// 1. Validates email and password inputs
  /// 2. Calls Firebase Authentication
  /// 3. Checks email verification status
  /// 4. Navigates to home if successful
  Future<void> login() async {
    try {
      // Set loading state to disable login button
      isLoading.value = true;
      
      // Trim inputs to remove accidental whitespace
      final emailInput = email.value.trim();
      final passwordInput = password.value.trim();
      
      // Validate email is not empty
      if (emailInput.isEmpty) {
        Get.snackbar(
          'Validation Error',
          'Please enter your email address',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }
      
      // Validate password is not empty
      if (passwordInput.isEmpty) {
        Get.snackbar(
          'Validation Error',
          'Please enter your password',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }
      
      // Validate email format
      if (!GetUtils.isEmail(emailInput)) {
        Get.snackbar(
          'Validation Error',
          'Please enter a valid email address',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }
      
      // Attempt login via Firebase Auth
      final User? user = await _authService.login(emailInput, passwordInput);
      
      if (user != null) {
        // Reload user to get latest email verification status
        await user.reload();
        final refreshedUser = FirebaseAuth.instance.currentUser;
        
        // Check email verification (skip in development mode)
        if (!skipEmailVerification && refreshedUser != null && !refreshedUser.emailVerified) {
          // Sign out unverified user
          await FirebaseAuth.instance.signOut();
          
          // Show verification required message with resend option
          Get.snackbar(
            'Email Not Verified',
            'Please verify your email before logging in. Check your inbox for the verification link.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orange,
            colorText: Colors.white,
            duration: const Duration(seconds: 5),
            mainButton: TextButton(
              onPressed: () async {
                // Resend verification email
                try {
                  await refreshedUser.sendEmailVerification();
                  Get.back(); // Close the snackbar
                  Get.snackbar(
                    'Email Sent',
                    'Verification email has been resent. Please check your inbox.',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                  );
                } catch (e) {
                  Get.snackbar(
                    'Error',
                    'Failed to resend email. Please try again later.',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                }
              },
              child: const Text(
                'Resend Email',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          );
          return;
        }
        
        // User is verified (or verification skipped), proceed to home
        Get.snackbar(
          'Success',
          'Login successful! Welcome back.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
        
        // Initialize ZegoCloud Call Service
        print('🟢 [LoginViewModel] Initializing ZegoCloud for user: ${refreshedUser!.uid}');
        await CallService().onUserLogin(
          refreshedUser.uid,
          refreshedUser.displayName ?? refreshedUser.email?.split('@')[0] ?? 'User',
        );
        print('🟢 [LoginViewModel] ZegoCloud initialization call completed');

        // Navigate to home screen and clear navigation stack
        Get.offAllNamed('/home');
      }
    } catch (e) {
      // Show error message if login fails
      Get.snackbar(
        'Login Failed',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    } finally {
      // Always reset loading state
      isLoading.value = false;
    }
  }
}
