

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../routes/app_routes.dart';


class SplashViewModel extends GetxController {
  final _auth = FirebaseAuth.instance;
  final _storage = GetStorage();

  @override
  void onInit() {
    super.onInit();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    // Check if user is already logged in
    final bool isLoggedIn = _auth.currentUser != null;
    final bool isFirstRun = _storage.read('isFirstRun') ?? true;
    
    print('🧐 Splash: isFirstRun = $isFirstRun');
    print('👤 Splash: currentUser = ${_auth.currentUser?.email ?? "Null"}');
    
    // Only delay for first-time users (onboarding)
    // For logged-in users, navigate instantly to allow ZegoCloud call UI to appear
    if (isFirstRun) {
      await Future.delayed(const Duration(seconds: 1));
    } else {
      print('⚡ Splash: Instant navigation for logged-in user (for fast call UI)');
    }

    // CRITICAL FIX: Wrap navigation in addPostFrameCallback to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isFirstRun) {
        print('🚀 Splash: Navigating to Onboarding');
        Get.offAllNamed(AppRoutes.onboarding);
      } else {
        // Check auth state for navigation
        if (isLoggedIn) {
          print('🏠 Splash: Navigating to Home');
          Get.offAllNamed(AppRoutes.home);
        } else {
          print('📝 Splash: Navigating to Signup');
          Get.offAllNamed(AppRoutes.signup);
        }
      }
    });
  }
}
