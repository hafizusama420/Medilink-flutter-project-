import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../routes/app_routes.dart';

class OnboardingViewModel extends GetxController {
  final pageController = PageController();
  final _storage = GetStorage();
  
  var currentPage = 0.obs;
  
  final List<OnboardingContent> contents = [
    OnboardingContent(
      title: 'Connect with Experts',
      description: 'Find the best doctors in your area and get professional medical advice.',
      image: 'assets/images/onboarding_1.png',
    ),
    OnboardingContent(
      title: 'Schedule with Ease',
      description: 'Book appointments with your preferred doctors in just a few taps.',
      image: 'assets/images/onboarding_2.png',
    ),
    OnboardingContent(
      title: 'Instant Support',
      description: 'Get secure, real-time consultation through our integrated chat system.',
      image: 'assets/images/onboarding_3.png',
    ),
  ];

  void onPageChanged(int index) {
    currentPage.value = index;
  }

  void next() {
    if (currentPage.value < contents.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      completeOnboarding();
    }
  }

  void skip() {
    completeOnboarding();
  }

  void completeOnboarding() {
    _storage.write('isFirstRun', false);
    Get.offAllNamed(AppRoutes.signup);
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}

class OnboardingContent {
  final String title;
  final String description;
  final String image;

  OnboardingContent({
    required this.title,
    required this.description,
    required this.image,
  });
}
