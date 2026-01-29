// lib/app/modules/appointment/viewmodels/edit_appointment_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/services/appointment_service.dart';
import '../../../data/services/notification_service.dart';
import '../../../models/appointment_model.dart';

class EditAppointmentViewModel extends GetxController {
  final AppointmentService _appointmentService = AppointmentService();

  // Form controllers
  final doctorNameController = TextEditingController();
  final reasonController = TextEditingController();

  // Reactive variables
  var selectedSpecialty = ''.obs;
  var selectedDate = Rx<DateTime?>(null);
  var selectedTime = Rx<TimeOfDay?>(null);
  var selectedStatus = ''.obs;
  var isLoading = false.obs;
  var isSaving = false.obs;
  var errorMessage = ''.obs;

  String? appointmentId;
  AppointmentModel? originalAppointment;

  // Available specialties
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

  // Available statuses
  final List<String> statuses = [
    'pending',
    'confirmed',
    'completed',
    'cancelled',
  ];

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    appointmentId = args?['id'];
    if (appointmentId != null) {
      loadAppointment();
    }
  }

  @override
  void onClose() {
    doctorNameController.dispose();
    reasonController.dispose();
    super.onClose();
  }

  Future<void> loadAppointment() async {
    if (appointmentId == null) return;

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await _appointmentService.getAppointmentById(appointmentId!);
      
      if (result != null) {
        originalAppointment = result;
        // Populate form with existing data
        doctorNameController.text = result.doctorName ?? '';
        reasonController.text = result.reason ?? '';
        
        // Fix for Specialty dropdown crash: ensure specialty exists in list
        final specialty = result.doctorSpecialty ?? '';
        if (specialty.isNotEmpty && !specialties.contains(specialty)) {
          specialties.insert(0, specialty);
        }
        selectedSpecialty.value = specialty;

        // Fix for Status dropdown crash: ensure status exists in list
        final status = result.status ?? 'pending';
        if (status.isNotEmpty && !statuses.contains(status)) {
          statuses.add(status); // Or insert at 0
        }
        selectedStatus.value = status;
        
        if (result.appointmentDate != null) {
          selectedDate.value = result.appointmentDate;
          selectedTime.value = TimeOfDay(
            hour: result.appointmentDate!.hour,
            minute: result.appointmentDate!.minute,
          );
        }
      } else {
        errorMessage.value = 'Appointment not found';
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void setSpecialty(String specialty) {
    selectedSpecialty.value = specialty;
  }

  void setStatus(String status) {
    selectedStatus.value = status;
  }

  void setDate(DateTime date) {
    selectedDate.value = date;
  }

  void setTime(TimeOfDay time) {
    selectedTime.value = time;
  }

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

  Future<void> pickTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime.value ?? const TimeOfDay(hour: 9, minute: 0),
    );
    if (picked != null) {
      setTime(picked);
    }
  }

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
    return true;
  }

  Future<void> updateAppointment() async {
    if (!validateForm() || appointmentId == null) return;

    try {
      isSaving.value = true;

      // Combine date and time
      final appointmentDateTime = DateTime(
        selectedDate.value!.year,
        selectedDate.value!.month,
        selectedDate.value!.day,
        selectedTime.value!.hour,
        selectedTime.value!.minute,
      );

      final updates = {
        'doctorName': doctorNameController.text.trim(),
        'doctorSpecialty': selectedSpecialty.value,
        'appointmentDate': appointmentDateTime,
        'reason': reasonController.text.trim(),
        'status': selectedStatus.value,
      };

      await _appointmentService.updateAppointment(appointmentId!, updates);

      // Handle notification rescheduling
      // Cancel old notification if appointment time changed
      if (originalAppointment?.appointmentDate != null) {
        try {
          final oldNotificationId = originalAppointment!.appointmentDate!.millisecondsSinceEpoch ~/ 1000;
          await NotificationService().cancelNotification(oldNotificationId);
          print('✅ Cancelled old notification - ID: $oldNotificationId');
        } catch (e) {
          print('⚠️ Error cancelling old notification: $e');
        }
      }

      // Schedule new notification for updated appointment
      DateTime? reminderTime;
      final oneHourBefore = appointmentDateTime.subtract(const Duration(hours: 1));
      
      if (oneHourBefore.isAfter(DateTime.now())) {
        reminderTime = oneHourBefore;
      } else if (appointmentDateTime.isAfter(DateTime.now())) {
        // If appointment is in less than an hour, schedule reminder for 2 minutes from now
        reminderTime = DateTime.now().add(const Duration(minutes: 2));
        print('🕒 Updated appointment is soon, scheduling reminder for 2 minutes from now: $reminderTime');
      }

      if (reminderTime != null) {
        try {
          final notificationId = appointmentDateTime.millisecondsSinceEpoch ~/ 1000;
          final success = await NotificationService().scheduleAppointmentReminder(
            id: notificationId,
            title: 'Upcoming Appointment',
            body: 'You have an appointment with ${doctorNameController.text.trim()} soon.',
            scheduledDate: reminderTime,
            appointmentId: notificationId.toString(),
          );
          
          if (success) {
            print('✅ New notification scheduled for: $reminderTime');
          }
        } catch (e) {
          print('⚠️ Error scheduling new notification: $e');
        }
      }


      Get.snackbar(
        'Success',
        'Appointment updated successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Navigate back to appointments list, removing edit and details screens
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
      isSaving.value = false;
    }
  }
}
