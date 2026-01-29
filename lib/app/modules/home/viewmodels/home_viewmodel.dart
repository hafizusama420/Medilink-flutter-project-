import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/services/user_service.dart';
import '../../../data/services/doctor_service.dart';
import '../../../data/services/appointment_service.dart';
import '../../../models/user_model.dart';
import '../../../models/appointment_model.dart';
import '../../../routes/app_routes.dart';

class HomeViewModel extends GetxController {
  final UserService _userService = UserService();
  final DoctorService _doctorService = DoctorService();
  final AppointmentService _appointmentService = AppointmentService();
  
  var currentUser = Rx<UserModel?>(null);
  var topDoctors = <UserModel>[].obs;
  
  // Doctor Dashboard specific
  var todayAppointments = <AppointmentModel>[].obs;
  var pendingCount = 0.obs;
  var completedCount = 0.obs;
  var nextAppointment = Rx<AppointmentModel?>(null);
  var isOnline = false.obs;
  
  // Analytics for Doctors
  var todayEarnings = 0.0.obs;
  var weeklyPatients = 0.obs;
  
  var isLoading = false.obs;
  var isDoctorsLoading = false.obs;
  var selectedTabIndex = 0.obs;
  StreamSubscription<UserModel?>? _userSubscription;
  StreamSubscription<List<AppointmentModel>>? _appointmentsSubscription;
  Timer? _statusTimer;
  Timer? _undoTimer;
  var undoAppointmentId = Rx<String?>(null);
  var undoCountdown = 5.obs;

  // Static list for labs/partners (typically from a service, but dummy for UI demo)
  final List<Map<String, String>> partnerLabs = [
    {
      'name': 'Chughtai Lab',
      'image': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRz-M8vE62Hj-C9b-_mK3_0m_L9-9H5v6P0WQ&s',
      'discount': 'Upto 20%',
    },
    {
      'name': 'IDC Lab',
      'image': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT7w4Vp-2z6L-I6m5v7z-0_l_L9-9H5v6P0WQ&s',
      'discount': 'Upto 15%',
    },
  ];

  @override
  void onInit() {
    super.onInit();
    _subscribeToUser();
    fetchTopDoctors();
  }

  void _initDoctorDash() {
    if (isDoctor && currentUser.value != null) {
      isOnline.value = currentUser.value?.isOnline ?? false;
      _subscribeToTodayAppointments();
    }
  }

  void _initGeneralDash() {
    _startStatusTimer();
  }

  void _startStatusTimer() {
    _statusTimer?.cancel();
    _statusTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      _checkAndCompletePastAppointments();
    });
  }

  void _checkAndCompletePastAppointments() {
    final now = DateTime.now();
    for (var appt in todayAppointments) {
      if (appt.isStaleForAutoCompletion(now)) {
        print('🕒 Auto-completing stale appointment in DB: ${appt.id}');
        updateAppointmentStatus(appt.id!, 'Completed', silent: true);
      }
    }
    // Refresh UI to update effectiveStatus
    todayAppointments.refresh();
  }

  void _subscribeToTodayAppointments() {
    _appointmentsSubscription?.cancel();
    _appointmentsSubscription = _appointmentService
        .getDoctorAppointmentsStream(currentUser.value!.uid!)
        .listen((appointments) {
      final now = DateTime.now();
      final todayStr = "${now.year}-${now.month}-${now.day}";
      
      // Filter for today only
      final todayList = appointments.where((a) {
        if (a.appointmentDate == null) return false;
        final d = a.appointmentDate!;
        return "${d.year}-${d.month}-${d.day}" == todayStr;
      }).toList();

      // Sort by time
      todayList.sort((a, b) => a.appointmentDate!.compareTo(b.appointmentDate!));
      
      todayAppointments.value = todayList;
      
      // Calculate counts based on effective status (optimistic UI)
      pendingCount.value = todayList.where((a) => 
        a.effectiveStatus != 'completed' && a.effectiveStatus != 'cancelled'
      ).length;
      
      final completed = todayList.where((a) => a.effectiveStatus == 'completed').toList();
      completedCount.value = completed.length;
      
      // Calculate Today's Earnings (Dynamic Sync)
      final fee = currentUser.value?.consultationFee ?? 350.0;
      todayEarnings.value = completed.length * fee;
      
      // Weekly Patients (Dummy tracker for UI, would normally be a separate query)
      weeklyPatients.value = appointments.where((a) {
        if (a.appointmentDate == null) return false;
        final now = DateTime.now();
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        return a.appointmentDate!.isAfter(startOfWeek);
      }).length;
      
      // Find next upcoming
      final upcoming = todayList.where((a) => 
        (a.effectiveStatus != 'completed' && a.effectiveStatus != 'cancelled') && 
        a.appointmentDate!.isAfter(now)
      ).toList();
      
      nextAppointment.value = upcoming.isNotEmpty ? upcoming.first : null;
    });
  }

  @override
  void onClose() {
    _userSubscription?.cancel();
    _appointmentsSubscription?.cancel();
    _statusTimer?.cancel();
    super.onClose();
  }

  void _subscribeToUser() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      isLoading.value = true;
      _userSubscription = _userService.getUserStream(user.uid).listen(
        (profile) {
          currentUser.value = profile;
          isLoading.value = false;
          _initGeneralDash();
          if (isDoctor) _initDoctorDash();
        },
        onError: (e) {
          // print('HomeViewModel: Error in user stream: $e');
          isLoading.value = false;
        },
      );
    }
  }

  Future<void> fetchTopDoctors() async {
    try {
      isDoctorsLoading.value = true;
      final doctors = await _doctorService.getAllDoctors();
      // Take first 5 or any logic for "Top Doctors"
      topDoctors.value = doctors.take(5).toList();
      isDoctorsLoading.value = false;
    } catch (e) {
      isDoctorsLoading.value = false;
      print('HomeViewModel: Error fetching doctors: $e');
    }
  }

  Future<void> refreshData() async {
    await fetchTopDoctors();
  }

  Future<void> loadUserProfile() async {
    // No-op as stream handles updates, kept for compatibility
    // print('HomeViewModel: Stream is active, manual reload not required');
  }

  Future<void> toggleOnlineStatus(bool status) async {
    try {
      isOnline.value = status;
      await _userService.updateUserProfile(currentUser.value!.uid!, {'isOnline': status});
    } catch (e) {
      print('HomeViewModel: Error toggling status: $e');
    }
  }

  Future<void> updateAppointmentStatus(String id, String status, {bool silent = false}) async {
    try {
      await _appointmentService.updateAppointment(id, {'status': status});
      if (!silent) {
        Get.snackbar(
          'Success', 
          'Appointment marked as $status',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppTheme.successGreen,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      if (!silent) {
        Get.snackbar('Error', 'Failed to update status: $e');
      } else {
        print('❌ Error in silent status update: $e');
      }
    }
  }

  void navigateToCalendar() {
    Get.toNamed(AppRoutes.appointments);
  }

  void confirmCancelAppointment(String id) {
    // Current logic for patients (simple confirmation)
    if (!isDoctor) {
      Get.dialog(
        AlertDialog(
          title: const Text("Cancel Appointment?"),
          content: const Text("Are you sure you want to cancel this appointment? This action cannot be undone."),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text("Back"),
            ),
            TextButton(
              onPressed: () {
                Get.back();
                updateAppointmentStatus(id, 'Cancelled');
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text("Yes, Cancel"),
            ),
          ],
        ),
      );
    } else {
      // Doctor-specific flow with dropdown
      _showDoctorCancellationDialog(id);
    }
  }

  void _showDoctorCancellationDialog(String id) {
    final appointment = todayAppointments.firstWhere((a) => a.id == id);
    String selectedReason = "Doctor Unavailable";
    final reasons = [
      "Doctor Unavailable",
      "Emergency",
      "Schedule Conflict",
      "Technical Issue",
      "Other"
    ];

    Get.dialog(
      AlertDialog(
        title: Text("Cancel with ${appointment.patientName}"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Are you sure you want to cancel the appointment at ${_formatTime(appointment.appointmentDate)}?"),
            const SizedBox(height: 20),
            const Text("Select a reason:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: selectedReason,
              items: reasons.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
              onChanged: (val) => selectedReason = val!,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("No, Go Back")),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _startUndoProcess(id, selectedReason);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Yes, Cancel"),
          ),
        ],
      ),
    );
  }

  void _startUndoProcess(String id, String reason) {
    undoAppointmentId.value = id;
    undoCountdown.value = 5;

    Get.snackbar(
      "Appointment Cancelled",
      "Cancelling in 5 seconds...",
      mainButton: TextButton(
        onPressed: () {
          _undoTimer?.cancel();
          undoAppointmentId.value = null;
          Get.back(); // Close snackbar
          Get.snackbar("Restored", "Cancellation undone", backgroundColor: AppTheme.successGreen, colorText: Colors.white);
        },
        child: const Text("UNDO", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      backgroundColor: Colors.red.withOpacity(0.9),
      colorText: Colors.white,
      duration: const Duration(seconds: 5),
      snackPosition: SnackPosition.BOTTOM,
      isDismissible: false,
    );

    _undoTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (undoCountdown.value > 1) {
        undoCountdown.value--;
      } else {
        timer.cancel();
        if (undoAppointmentId.value == id) {
          _finalizeCancellation(id, reason);
          undoAppointmentId.value = null;
        }
      }
    });
  }

  Future<void> _finalizeCancellation(String id, String reason) async {
    try {
      final appt = todayAppointments.firstWhereOrNull((a) => a.id == id);
      if (appt == null) return;

      await _appointmentService.updateAppointment(id, {
        'status': 'Cancelled',
        'cancellationReason': reason,
        'cancelledBy': 'Doctor',
      });

      // Notify patient (Simulated push notification logic)
      _notifyPatientCancellation(appt, reason);

      Get.snackbar(
        "Success",
        "Appointment with ${appt.patientName} cancelled.",
        backgroundColor: AppTheme.successGreen,
        colorText: Colors.white,
      );
    } catch (e) {
      print("Error finalizing cancellation: $e");
    }
  }

  void _notifyPatientCancellation(AppointmentModel appt, String reason) {
    // In a real app, this would trigger a Cloud Function or send via FCM service
    print("🔔 NOTIFYING PATIENT ${appt.userId}: Your appointment with Dr. $displayName at ${_formatTime(appt.appointmentDate)} has been cancelled. Reason: $reason");
    
    // If we had a direct FCM send capability in the frontend (usually restricted):
    // if (appt.fcmToken != null) {
    //   _notificationService.sendRemoteNotification(token: appt.fcmToken!, title: "Appointment Cancelled", body: "...");
    // }
  }

  void rescheduleAppointment(String id) {
    final appt = todayAppointments.firstWhereOrNull((a) => a.id == id);
    if (appt == null) return;

    // Open create appointment with pre-filled doctor data
    Get.toNamed(AppRoutes.createAppointment, arguments: {
      'uid': appt.doctorUid,
      'fullName': appt.doctorName,
      'specialty': appt.doctorSpecialty,
    });
  }

  Future<void> showAddSlotDialog() async {
    final TimeOfDay? picked = await showTimePicker(
      context: Get.context!,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryGreen,
              onPrimary: Colors.white,
              onSurface: AppTheme.textDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      try {
        isLoading.value = true;
        String newTime = "${picked.hour}:${picked.minute.toString().padLeft(2, '0')}";
        // Update the doctor's availableTime in Firestore
        await _userService.updateUserProfile(currentUser.value!.uid!, {
          'availableTime': newTime,
        });
        Get.snackbar("Success", "Daily start time updated to $newTime");
      } catch (e) {
        Get.snackbar("Error", "Failed to update slot: $e");
      } finally {
        isLoading.value = false;
      }
    }
  }

  void showBlockSlotDialog() {
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final selectedDays = List<String>.from(currentUser.value?.availableDays ?? []);

    Get.dialog(
      StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text("Manage Available Days"),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: days.map((day) {
                  return CheckboxListTile(
                    title: Text(day),
                    value: selectedDays.contains(day),
                    activeColor: AppTheme.primaryGreen,
                    onChanged: (val) {
                      setState(() {
                        if (val == true) {
                          selectedDays.add(day);
                        } else {
                          selectedDays.remove(day);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
              ElevatedButton(
                onPressed: () async {
                  Get.back();
                  try {
                    isLoading.value = true;
                    await _userService.updateUserProfile(currentUser.value!.uid!, {
                      'availableDays': selectedDays,
                    });
                    Get.snackbar("Success", "Available days updated");
                  } catch (e) {
                    Get.snackbar("Error", "Update failed: $e");
                  } finally {
                    isLoading.value = false;
                  }
                },
                child: const Text("Save Changes"),
              ),
            ],
          );
        }
      ),
    );
  }

  void changeTab(int index) {
    selectedTabIndex.value = index;
    
    // For patients, index 1 still goes to Lab Tests which is a separate page
    if (!isDoctor && index == 1) {
       Get.toNamed(AppRoutes.labTests);
       // Reset tab index on return or if it's just a jump
       selectedTabIndex.value = 0;
    }
  }

  String get userRole => currentUser.value?.role ?? 'Patient';
  bool get isDoctor => userRole == 'Doctor';
  String get displayName => currentUser.value?.fullName ?? 'User';
  String get specialization => currentUser.value?.specialty ?? 'Medical Specialist';

  String _formatTime(DateTime? date) {
    if (date == null) return "--:--";
    final hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
    final ampm = date.hour >= 12 ? "PM" : "AM";
    final minute = date.minute.toString().padLeft(2, '0');
    return "${hour.toString().padLeft(2, '0')}:$minute $ampm";
  }
}
