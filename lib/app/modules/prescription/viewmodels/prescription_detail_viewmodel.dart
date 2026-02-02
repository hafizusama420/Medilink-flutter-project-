// lib/app/modules/prescription/viewmodels/prescription_detail_viewmodel.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/prescription_model.dart';
import '../../../services/prescription_service.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/user_service.dart';
import '../../../models/user_model.dart';
import '../../../core/theme/app_theme.dart';

class PrescriptionDetailViewModel extends GetxController {
  final PrescriptionService _prescriptionService = PrescriptionService();
  final AuthService _authService = Get.find<AuthService>();
  final UserService _userService = UserService();

  // Observable variables
  final isLoading = false.obs;
  final prescription = Rx<PrescriptionModel?>(null);
  final errorMessage = ''.obs;
  final currentUserProfile = Rx<UserModel?>(null);

  String? prescriptionId;
  StreamSubscription? _prescriptionSubscription;

  // Check if user is doctor
  bool get isDoctor => currentUserProfile.value?.role == 'Doctor' || prescription.value?.doctorId == _authService.currentUser?.uid;

  @override
  void onInit() {
    super.onInit();
    _initUser();
    // Get prescription ID from arguments
    if (Get.arguments != null) {
      prescriptionId = Get.arguments['prescriptionId'] as String?;
      if (prescriptionId != null) {
        loadPrescription();
      }
    }
  }

  @override
  void onClose() {
    _prescriptionSubscription?.cancel();
    super.onClose();
  }

  /// Load user profile to check role
  Future<void> _initUser() async {
    final uid = _authService.currentUser?.uid;
    if (uid != null) {
      try {
        final profile = await _userService.getUserProfile(uid);
        currentUserProfile.value = profile;
      } catch (e) {
        print('Error loading user profile: $e');
      }
    }
  }

  /// Load prescription details with real-time streaming
  void loadPrescription() {
    if (prescriptionId == null) {
      errorMessage.value = 'Prescription ID not found';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    // Cancel previous subscription
    _prescriptionSubscription?.cancel();

    // Listen to real-time updates
    _prescriptionSubscription = _prescriptionService
        .getPrescriptionStream(prescriptionId!)
        .listen(
          (prescriptionData) {
            if (prescriptionData != null) {
              prescription.value = prescriptionData;
              errorMessage.value = '';
            } else {
              errorMessage.value = 'Prescription not found or has been deleted';
              // Auto-navigate back if prescription was deleted
              Future.delayed(const Duration(seconds: 2), () {
                if (Get.isDialogOpen == true) Get.back(); // Close any open dialogs
                Get.back(); // Navigate back
              });
            }
            isLoading.value = false;
          },
          onError: (error) {
            // Ignore permission denied errors if we are navigating away (means document was likely deleted)
            if (error.toString().contains('permission-denied')) {
              errorMessage.value = '';
              return;
            }
            errorMessage.value = 'Error loading prescription: $error';
            isLoading.value = false;
          },
        );
  }

  /// Show confirmation dialog before delete
  void confirmDelete() {
    Get.dialog(
      AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Delete Prescription',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: const Text(
          'Are you sure you want to delete this prescription? This action cannot be undone.',
          style: TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back(); // Close dialog
              deletePrescription(); // Delete
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  /// Delete prescription
  Future<void> deletePrescription() async {
    if (prescription.value?.id == null) {
      Get.snackbar(
        'Error',
        'Prescription ID not found',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;
      
      await _prescriptionService.deletePrescription(prescription.value!.id!);
      
      Get.snackbar(
        'Success',
        'Prescription deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.successGreen,
        colorText: Colors.white,
        icon: const Icon(Icons.check_circle, color: Colors.white),
      );
      
      // Navigate back after successful delete
      Future.delayed(const Duration(milliseconds: 500), () => Get.back());
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete prescription: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        icon: const Icon(Icons.error, color: Colors.white),
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Navigate to edit prescription screen
  void editPrescription() {
    if (prescription.value == null) {
      Get.snackbar(
        'Error',
        'Prescription data not loaded',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    Get.toNamed(
      '/create-prescription',
      arguments: {
        'mode': 'edit',
        'prescription': prescription.value,
        'appointmentId': prescription.value!.appointmentId,
      },
    );
  }

  /// Download prescription as PDF
  Future<void> downloadPDF() async {
    // TODO: Implement PDF generation
    Get.snackbar(
      'Coming Soon',
      'PDF download feature will be available soon',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// Share prescription
  Future<void> sharePrescription() async {
    // TODO: Implement share functionality
    Get.snackbar(
      'Coming Soon',
      'Share feature will be available soon',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// Set medication reminder
  void setMedicationReminder(String medicationId) {
    // TODO: Implement medication reminder
    Get.snackbar(
      'Coming Soon',
      'Medication reminder feature will be available soon',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// Book follow-up appointment
  void bookFollowUpAppointment() {
    if (prescription.value?.followUpRequired == true) {
      // Navigate to appointment booking with pre-filled data
      Get.toNamed('/create-appointment', arguments: {
        'doctorId': prescription.value?.doctorId,
        'doctorName': prescription.value?.doctorName,
        'specialty': prescription.value?.doctorSpecialty,
        'suggestedDate': prescription.value?.followUpDate,
      });
    }
  }
}
