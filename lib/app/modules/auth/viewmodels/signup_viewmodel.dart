// lib/app/modules/auth/viewmodels/signup_viewmodel.dart
// ViewModel for user signup/registration functionality
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/services/auth_service.dart';

/// SignupViewModel manages the user registration process
/// Handles email/password signup and email verification flow
class SignupViewModel extends GetxController {
  // Auth service for Firebase Authentication operations
  final AuthService _authService = AuthService();

  // Observable state variables
  var email = ''.obs;              // User's email address
  var password = ''.obs;           // User's password
  var isLoading = false.obs;       // Loading state during signup

  /// Registers a new user with email and password
  /// 
  /// Process:
  /// 1. Validates and trims input
  /// 2. Creates Firebase Auth account
  /// 3. Sends verification email
  /// 4. Navigates to email verification screen
  Future<void> signup() async {
    try {
      // Set loading state to disable signup button
      isLoading.value = true;
      
      // Trim inputs to remove accidental whitespace
      final emailInput = email.value.trim();
      final passwordInput = password.value.trim();
      
      // Create new user account via Firebase Auth
      final user = await _authService.signup(emailInput, passwordInput);
      
      if (user != null) {
        // Show success message
        Get.snackbar(
          'Success',
          'Verification email sent! Please check your inbox.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
        
        // Navigate to email verification screen
        Get.offNamed('/email-verification');
      }
    } catch (e) {
      // Show error message if signup fails
      Get.snackbar(
        'Signup Failed',
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
