// lib/app/modules/appointment/viewmodels/appointments_list_viewmodel.dart
// ViewModel for displaying the list of user appointments
import 'dart:async';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/services/appointment_service.dart';
import '../../../data/services/user_service.dart';
import '../../../models/appointment_model.dart';
import '../../../routes/app_routes.dart';
import 'package:flutter/material.dart';

/// AppointmentsListViewModel manages the list of appointments
/// Handles real-time appointment updates via Firestore streams
class AppointmentsListViewModel extends GetxController {
  // Service for appointment operations
  final AppointmentService _appointmentService = AppointmentService();
  final UserService _userService = UserService();
  
  // Observable state variables
  var appointments = <AppointmentModel>[].obs;  // List of appointments
  var isLoading = false.obs;                    // Loading state
  var errorMessage = ''.obs;                    // Error message
  var isDoctor = false.obs;                     // User role toggle
  var currentFilter = 'all'.obs;                // current filter: all, upcoming, completed
  
  // Stream subscription to manage real-time updates
  StreamSubscription<List<AppointmentModel>>? _appointmentsSubscription;
  Timer? _statusTimer;

  @override
  void onInit() {
    super.onInit();
    // Start listening to appointments when controller initializes
    _subscribeToAppointments();
  }

  @override
  void onClose() {
    // Cancel stream subscription and timer to prevent memory leaks
    _appointmentsSubscription?.cancel();
    _statusTimer?.cancel();
    super.onClose();
  }

  void _startStatusTimer() {
    _statusTimer?.cancel();
    _statusTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      _checkAndCompleteStaleAppointments();
    });
  }

  void _checkAndCompleteStaleAppointments() {
    final now = DateTime.now();
    bool updated = false;
    
    for (var appointment in appointments) {
      if (_shouldMarkCompleted(appointment, now)) {
        _appointmentService.updateAppointment(appointment.id!, {'status': 'completed'});
        updated = true;
      }
    }
    
    if (updated) {
      // The stream listener will handle the UI refresh when Firestore notifies us
      print('🕒 Auto-completed stale appointments');
    }

    // Always refresh the observable list to trigger UI update for effectiveStatus
    appointments.refresh();
  }

  bool _shouldMarkCompleted(AppointmentModel appointment, DateTime now) {
    return appointment.isStaleForAutoCompletion(now);
  }

  /// Subscribes to the appointment stream for the current user
  /// Updates the appointments list automatically when Firestore data changes
  void _subscribeToAppointments() {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        errorMessage.value = 'User not authenticated';
        isLoading.value = false;
        return;
      }

      // Subscribe to real-time updates from AppointmentService
      // We need to check the user role first
      _userService.getUserProfile(userId).then((user) {
        if (user == null) {
          errorMessage.value = 'Profile not found';
          isLoading.value = false;
          return;
        }

        final isUserDoctor = user.role == 'Doctor';
        isDoctor.value = isUserDoctor;
        // print('!!! APPOINTMENTS LIST: uid=$userId, role=${user.role}, isDoctor=$isUserDoctor');
        
        final stream = isUserDoctor 
            ? _appointmentService.getDoctorAppointmentsStream(userId)
            : _appointmentService.getAppointmentsStream(userId);

        _appointmentsSubscription = stream.listen(
          (appointmentsList) async {
            // Update local view
            appointmentsList.sort((a, b) => (b.appointmentDate ?? DateTime.now()).compareTo(a.appointmentDate ?? DateTime.now()));
            appointments.value = appointmentsList;
            
            // Start timer once if not already running
            if (_statusTimer == null) {
              _checkAndCompleteStaleAppointments(); // One initial check
              _startStatusTimer();
            }
            
            isLoading.value = false;
            errorMessage.value = '';
          },
          onError: (error) {
            // Handle stream errors
            errorMessage.value = error.toString();
            isLoading.value = false;
          },
        );
      });
    } catch (e) {
      // Handle subscription errors
      errorMessage.value = e.toString();
      isLoading.value = false;
    }
  }

  /// Filtered list of appointments based on currentFilter
  List<AppointmentModel> get filteredAppointments {
    if (currentFilter.value == 'all') return appointments;
    if (currentFilter.value == 'upcoming') {
      return appointments.where((a) => 
        a.effectiveStatus == 'confirmed' || 
        a.effectiveStatus == 'pending'
      ).toList();
    }
    if (currentFilter.value == 'completed') {
      return appointments.where((a) => a.effectiveStatus == 'completed').toList();
    }
    return appointments;
  }

  /// Sets the current filter
  void setFilter(String filter) {
    currentFilter.value = filter;
  }

  /// Clears all completed appointments for the current user
  Future<void> clearCompletedAppointments() async {
    try {
      final completedApps = appointments.where((a) => a.status?.toLowerCase() == 'completed').toList();
      if (completedApps.isEmpty) return;

      // Show loading
      isLoading.value = true;
      
      // Delete each completed appointment
      for (var app in completedApps) {
        if (app.id != null) {
          await _appointmentService.deleteAppointment(app.id!);
        }
      }
      
      Get.snackbar(
        'Success', 
        'Completed appointments cleared successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.successGreen,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to clear appointments: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Manually triggers a refresh (though stream handles updates automatically)
  Future<void> refreshAppointments() async {
    // The stream (setup in onInit) automatically picks up any changes,
    // so explicit refresh logic isn't strictly needed for Firestore streams,
    // but this method satisfies the RefreshIndicator requirement.
  }

  /// Navigates to the appointment creation screen
  void navigateToCreateAppointment() {
    Get.toNamed(AppRoutes.createAppointment);
  }

  /// Navigates to the details screen for a specific appointment
  void navigateToAppointmentDetails(String appointmentId) {
    Get.toNamed('/appointments/details', arguments: {'id': appointmentId});
  }
}


