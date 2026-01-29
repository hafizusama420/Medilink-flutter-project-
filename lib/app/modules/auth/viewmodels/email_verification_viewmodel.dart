// lib/app/modules/auth/viewmodels/email_verification_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EmailVerificationViewModel extends GetxController {
  var isLoading = false.obs;
  var isResending = false.obs;

  Future<void> checkEmailVerified() async {
    try {
      isLoading.value = true;
      final user = FirebaseAuth.instance.currentUser;
      await user?.reload();
      final refreshedUser = FirebaseAuth.instance.currentUser;
      
      if (refreshedUser != null && refreshedUser.emailVerified) {
        Get.snackbar(
          'Success',
          'Email verified successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        Get.offNamed('/profile-setup');
      } else {
        Get.snackbar(
          'Not Verified Yet',
          'Please check your email and click the verification link first.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resendVerificationEmail() async {
    try {
      isResending.value = true;
      final user = FirebaseAuth.instance.currentUser;
      
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        Get.snackbar(
          'Email Sent',
          'Verification email has been resent. Please check your inbox.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to resend email. Please try again later.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isResending.value = false;
    }
  }
}
