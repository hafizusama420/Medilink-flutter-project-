// lib/app/modules/appointment/viewmodels/create_appointment_viewmodel.dart
// ViewModel for creating new appointments
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../data/services/appointment_service.dart';
import '../../../data/services/doctor_service.dart';
import '../../../data/services/notification_service.dart';
import '../../../models/appointment_model.dart';
import '../../../routes/app_routes.dart';
import '../../../data/services/user_service.dart';

/// CreateAppointmentViewModel manages the form and logic for creating a new appointment
/// Handles validation, date/time picking, and submission to Firestore
class CreateAppointmentViewModel extends GetxController {
  // Service instances
  final AppointmentService _appointmentService = AppointmentService();
  final DoctorService _doctorService = DoctorService();
  final UserService _userService = UserService();

  // Form controllers
  final doctorNameController = TextEditingController();
  final reasonController = TextEditingController();

  // Reactive variables
  var selectedSpecialty = ''.obs;
  var selectedDate = Rx<DateTime?>(null);
  var selectedTime = Rx<TimeOfDay?>(null);
  var isLoading = false.obs;
  String? currentDoctorUid; // UID of the selected doctor

  // Available specialties for selection
  final List<String> specialties = [
    'General Physician',
    'Cardiologist',
    'Dermatologist',
    'Neurologist',
    'Orthopedist',
    'Pediatrician',
    'Psychiatrist',
    'Gynecologist',
    'Ophthalmologist',
    'ENT Specialist',
    'Dentist',
    'Other',
  ];

  @override
  void onInit() {
    super.onInit();
    // print('CreateAppointmentViewModel: onInit called');
    
    // Check if doctor data was passed from doctor list
    final doctor = Get.arguments;
    // print('CreateAppointmentViewModel: Received arguments: $doctor');
    
    if (doctor != null && doctor is Map) {
      // Case 1: Navigating from doctor list (already works)
      _prefillDoctor(doctor['uid'], doctor['fullName'], doctor['specialty']);
    } else {
      // Case 2: Navigating from other entry points (e.g. FAB)
      // If there is only one doctor in the system, pre-fill it automatically
      _autoFillIfSingleDoctor();
    }
  }

  /// Helper to pre-fill doctor details
  void _prefillDoctor(String? uid, String? name, String? specialty) {
    currentDoctorUid = uid;
    doctorNameController.text = name ?? '';
    
    if (specialty != null && specialty.isNotEmpty) {
      // Ensure the specialty exists in our list to avoid Dropdown errors
      // If it doesn't exist, we add it to the list temporary or use 'Other'
      if (!specialties.contains(specialty)) {
        specialties.insert(0, specialty);
      }
      selectedSpecialty.value = specialty;
    } else {
      selectedSpecialty.value = '';
    }
    
    // print('CreateAppointmentViewModel: Pre-filled doctor: $name, specialty: $specialty, UID: $uid');
  }

  /// Fetches doctors and auto-fills if only one is found
  Future<void> _autoFillIfSingleDoctor() async {
    try {
      // print('CreateAppointmentViewModel: Attempting auto-fill...');
      final doctors = await _doctorService.getAllDoctors();
      
      if (doctors.length == 1) {
        final doctor = doctors.first;
        _prefillDoctor(doctor.uid, doctor.fullName, doctor.specialty);
      } else if (doctors.isNotEmpty) {
        // print('CreateAppointmentViewModel: Multiple doctors found (${doctors.length}), not auto-filling');
      } else {
        // print('CreateAppointmentViewModel: No doctors found in system');
      }
    } catch (e) {
      // print('CreateAppointmentViewModel: Error during auto-fill: $e');
    }
  }

  @override
  void onClose() {
    // Dispose controllers to prevent memory leaks
    doctorNameController.dispose();
    reasonController.dispose();
    super.onClose();
  }

  /// Sets the selected specialty
  void setSpecialty(String specialty) {
    selectedSpecialty.value = specialty;
  }

  /// Sets the selected date
  void setDate(DateTime date) {
    selectedDate.value = date;
  }

  /// Sets the selected time
  void setTime(TimeOfDay time) {
    selectedTime.value = time;
  }

  /// Opens dialog to pick an appointment date
  /// Restricts selection to the next 365 days
  Future<void> pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setDate(picked);
    }
  }

  /// Opens dialog to pick an appointment time
  Future<void> pickTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime.value ?? const TimeOfDay(hour: 9, minute: 0),
    );
    if (picked != null) {
      setTime(picked);
    }
  }

  /// Validates all form fields before submission
  /// Returns true if valid, false otherwise
  bool validateForm() {
    if (doctorNameController.text.trim().isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Please enter doctor name',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return false;
    }
    if (selectedSpecialty.value.isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Please select a specialty',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return false;
    }
    if (selectedDate.value == null) {
      Get.snackbar(
        'Validation Error',
        'Please select a date',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return false;
    }
    if (selectedTime.value == null) {
      Get.snackbar(
        'Validation Error',
        'Please select a time',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return false;
    }

    // New logic: Check if selected time is in the past (for today only)
    if (selectedDate.value != null && selectedTime.value != null) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final pickedDate = DateTime(selectedDate.value!.year, selectedDate.value!.month, selectedDate.value!.day);
      
      if (pickedDate.isAtSameMomentAs(today)) {
        final pickedDateTime = DateTime(today.year, today.month, today.day, selectedTime.value!.hour, selectedTime.value!.minute);
        if (pickedDateTime.isBefore(now)) {
          Get.snackbar(
            'Validation Error',
            'You cannot book an appointment for a time that has already passed today.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orange,
            colorText: Colors.white,
          );
          return false;
        }
      }
    }
    return true;
  }

  /// Creates specific appointment and saves to Firestore
  /// 
  /// Process:
  /// 1. Validates form
  /// 2. Checks authentication
  /// 3. Combines date and time
  /// 4. Creates AppointmentModel
  /// 5. Saves via AppointmentService
  Future<void> createAppointment() async {
    if (!validateForm()) return;

    try {
      isLoading.value = true;

      final userId = FirebaseAuth.instance.currentUser?.uid;
      
      if (userId == null) {
        Get.snackbar(
          'Error',
          'User not authenticated',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // Fetch user profile to get the correct full name
      final userProfile = await _userService.getUserProfile(userId);
      final patientName = userProfile?.fullName ?? FirebaseAuth.instance.currentUser?.displayName ?? 'Patient';

      // Combine picked date and time into single DateTime object
      final appointmentDateTime = DateTime(
        selectedDate.value!.year,
        selectedDate.value!.month,
        selectedDate.value!.day,
        selectedTime.value!.hour,
        selectedTime.value!.minute,
      );

      // Create appointment model with all details
      final appointment = AppointmentModel(
        userId: userId,
        patientName: patientName,
        doctorUid: currentDoctorUid, // Now correctly linking to the doctor
        doctorName: doctorNameController.text.trim(),
        doctorSpecialty: selectedSpecialty.value,
        appointmentDate: appointmentDateTime,
        reason: reasonController.text.trim(),
        status: 'pending',
        createdAt: DateTime.now(),
      );

      // print('!!! CREATE APPOINTMENT: doctorUid=$currentDoctorUid, userId=$userId');

      // Save to Firestore
      await _appointmentService.createAppointment(appointment);

      // Show success message
      Get.snackbar(
        'Success',
        'Appointment created successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Get FCM token and save with appointment for Cloud Functions
      try {
        final fcmToken = await NotificationService().getFCMToken();
        if (fcmToken != null) {
          // Update appointment with FCM token
          await _appointmentService.updateAppointment(
            appointment.id!,
            {'fcmToken': fcmToken, 'notificationScheduled': false},
          );
          print('✅ FCM token saved with appointment for Cloud Functions');
        }
      } catch (e) {
        print('⚠️ Error saving FCM token: $e');
      }

      // Navigate back to the home screen
      Get.offAllNamed(AppRoutes.home);
    } catch (e) {
      // Handle errors and show user feedback
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      // Always reset loading state
      isLoading.value = false;
    }
  }
}
