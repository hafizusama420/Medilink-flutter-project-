// lib/app/modules/appointment/viewmodels/appointment_details_viewmodel.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/services/appointment_service.dart';
import '../../../data/services/user_service.dart';
import '../../../data/services/review_service.dart';
import '../../../data/services/notification_service.dart';
import '../../../data/services/call_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../models/appointment_model.dart';

class AppointmentDetailsViewModel extends GetxController {
  final AppointmentService _appointmentService = AppointmentService();
  final UserService _userService = UserService();
  final ReviewService _reviewService = ReviewService();

  var appointment = Rx<AppointmentModel?>(null);
  var isLoading = false.obs;
  var isDeleting = false.obs;
  var errorMessage = ''.obs;
  var isDoctor = false.obs;
  var hasReviewed = false.obs;
  Timer? _statusTimer;

  String? appointmentId;

  @override
  void onInit() {
    super.onInit();
    // Get appointment ID from arguments
    final args = Get.arguments as Map<String, dynamic>?;
    appointmentId = args?['id'];
    if (appointmentId != null) {
      loadAppointment();
    }
    _checkUserRole();
  }

  @override
  void onClose() {
    _statusTimer?.cancel();
    super.onClose();
  }

  void _startStatusTimer() {
    _statusTimer?.cancel();
    _statusTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (appointment.value != null) {
        // Trigger UI refresh by notifying listeners
        appointment.refresh();
        
        // Also perform the database sync if it's now stale
        if (appointment.value!.isStaleForAutoCompletion()) {
          _appointmentService.updateAppointment(appointmentId!, {'status': 'completed'});
        }
      }
    });
  }

  Future<void> _checkUserRole() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      final user = await _userService.getUserProfile(userId);
      if (user != null) {
        isDoctor.value = user.role == 'Doctor';
      }
    }
  }

  Future<void> loadAppointment() async {
    if (appointmentId == null) return;
    
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final result = await _appointmentService.getAppointmentById(appointmentId!);
      
      // Auto-update status only if the appointment is truly stale (24+ hours)
      try {
        if (result != null && result.isStaleForAutoCompletion()) {
          // Sync with Firestore (silent)
          _appointmentService.updateAppointment(appointmentId!, {'status': 'completed'});
        }
      } catch (e) {
        debugPrint('Auto-status update failed: $e');
      }

      appointment.value = result;
      
      if (result == null) {
        errorMessage.value = 'Appointment not found';
      } else {
        // Check if user has reviewed this appointment
        await _checkIfReviewed();
        // Start background timer to keep status updated
        _startStatusTimer();
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void navigateToEdit() {
    if (appointmentId != null) {
      Get.toNamed('/appointments/edit', arguments: {'id': appointmentId})
          ?.then((result) {
        // Refresh appointment data if edited
        if (result == true) {
          loadAppointment();
        }
      });
    }
  }

  Future<void> cancelAppointment() async {
    if (appointmentId == null) return;

    // Show confirmation dialog
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Cancel Appointment'),
        content: const Text(
          'Are you sure you want to cancel this appointment? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('No, Keep It'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      isDeleting.value = true;

      // Cancel scheduled notification before deleting appointment
      if (appointment.value?.appointmentDate != null) {
        try {
          final notificationId = appointment.value!.appointmentDate!.millisecondsSinceEpoch ~/ 1000;
          await NotificationService().cancelNotification(notificationId);
          print('✅ Cancelled notification for deleted appointment - ID: $notificationId');
        } catch (e) {
          print('⚠️ Error cancelling notification: $e');
        }
      }

      await _appointmentService.deleteAppointment(appointmentId!);

      Get.snackbar(
        'Success',
        'Appointment cancelled successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Navigate back to appointments list
      Get.until((route) => route.settings.name == '/appointments');
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isDeleting.value = false;
    }
  }

  Future<void> _checkIfReviewed() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null && appointmentId != null) {
      hasReviewed.value = await _reviewService.hasUserReviewedAppointment(
        appointmentId!,
        userId,
      );
    }
  }

  void navigateToReview() {
    final appt = appointment.value;
    if (appt == null) return;

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    Get.toNamed('/add-review', arguments: {
      'appointmentId': appointmentId,
      'doctorId': appt.doctorUid,
      'doctorName': appt.doctorName,
      'patientName': appt.patientName,
    })?.then((result) {
      // Refresh to check if review was added
      if (result == true) {
        _checkIfReviewed();
      }
    });
  }

  bool get canLeaveReview {
    return appointment.value?.status?.toLowerCase() == 'completed' && !hasReviewed.value;
  }

  String getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'confirmed':
        return 'green';
      case 'pending':
        return 'orange';
      case 'completed':
        return 'blue';
      case 'cancelled':
        return 'red';
      default:
        return 'grey';
    }
  }

  /// Initiate audio call to patient (for doctors)
  void initiateCallToPatient() {
    final appt = appointment.value;
    if (appt == null) {
      Get.snackbar(
        'Error',
        'Appointment information not available',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (appt.userId == null || appt.userId!.isEmpty) {
      Get.snackbar(
        'Error',
        'Patient information not available',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      final CallService callService = CallService();
      final String patientName = appt.patientName ?? 'Patient';
      
      print('📞 [AppointmentDetailsViewModel] Doctor initiating call to: $patientName (${appt.userId})');
      
      callService.sendCallInvitation(appt.userId!, patientName);
      
      Get.snackbar(
        'Calling',
        'Calling $patientName...',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      print('❌ [AppointmentDetailsViewModel] Error initiating call: $e');
      Get.snackbar(
        'Error',
        'Failed to initiate call. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Initiate VIDEO call to patient (Doctor only)
  void initiateVideoCall() {
    if (!isDoctor.value) {
      Get.snackbar(
        'Error',
        'Only doctors can initiate video calls from appointments',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final appt = appointment.value;
    if (appt == null || appt.userId == null) {
      Get.snackbar(
        'Error',
        'Unable to initiate video call. Patient information missing.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      final CallService callService = CallService();
      final String patientName = appt.patientName ?? 'Patient';
      
      print('📹 [AppointmentDetailsViewModel] Doctor initiating video call to: $patientName (${appt.userId})');
      
      callService.sendVideoCallInvitation(appt.userId!, patientName);
      
      Get.snackbar(
        'Video Calling',
        'Video calling $patientName...',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      print('❌ [AppointmentDetailsViewModel] Error initiating video call: $e');
      Get.snackbar(
        'Error',
        'Failed to initiate video call. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
