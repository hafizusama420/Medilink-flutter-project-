// lib/app/modules/reviews/viewmodels/add_review_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../data/services/review_service.dart';
import '../../../models/review_model.dart';

class AddReviewViewModel extends GetxController {
  final ReviewService _reviewService = ReviewService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Form controllers
  final TextEditingController commentController = TextEditingController();

  // Observable state
  var selectedRating = 0.obs;
  var isLoading = false.obs;

  // Data passed from previous screen
  String? appointmentId;
  String? doctorId;
  String? doctorName;
  String? patientName;

  @override
  void onInit() {
    super.onInit();
    // Get arguments passed from previous screen
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      appointmentId = args['appointmentId'];
      doctorId = args['doctorId'];
      doctorName = args['doctorName'];
      patientName = args['patientName'];
    }
  }

  /// Set the selected rating
  void setRating(int rating) {
    selectedRating.value = rating;
  }

  /// Validate the review form
  bool _validateReview() {
    if (selectedRating.value == 0) {
      Get.snackbar(
        'Rating Required',
        'Please select a star rating',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return false;
    }

    if (commentController.text.trim().isEmpty) {
      Get.snackbar(
        'Comment Required',
        'Please write a review comment',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return false;
    }

    if (commentController.text.trim().length < 10) {
      Get.snackbar(
        'Comment Too Short',
        'Please write at least 10 characters',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return false;
    }

    return true;
  }

  /// Submit the review
  Future<void> submitReview() async {
    if (!_validateReview()) return;

    try {
      isLoading.value = true;

      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not logged in');
      }

      if (appointmentId == null || doctorId == null) {
        throw Exception('Appointment or Doctor information is missing. Please try navigating back and opening this screen again.');
      }

      // Check if user has already reviewed this appointment
      final hasReviewed = await _reviewService.hasUserReviewedAppointment(
        appointmentId!,
        currentUser.uid,
      );

      if (hasReviewed) {
        Get.snackbar(
          'Already Reviewed',
          'You have already reviewed this appointment',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        isLoading.value = false;
        return;
      }

      // Create review model
      final review = ReviewModel(
        appointmentId: appointmentId,
        doctorId: doctorId,
        patientId: currentUser.uid,
        patientName: patientName ?? 'Anonymous',
        rating: selectedRating.value,
        comment: commentController.text.trim(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Submit review
      await _reviewService.addReview(review);

      // Show success message
      Get.snackbar(
        'Review Submitted',
        'Thank you for your feedback!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );

      // Navigate back after a short delay to allow snackbar to start showing
      Future.delayed(const Duration(milliseconds: 500), () {
        if (Get.isOverlaysOpen) {
          Get.back(); // Close snackbar if still open
        }
        Get.back(result: true); // Close the Review Page
      });
    } catch (e) {
      print('AddReviewViewModel: Error submitting review: $e');
      Get.snackbar(
        'Error',
        'Failed to submit review. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    commentController.dispose();
    super.onClose();
  }
}
