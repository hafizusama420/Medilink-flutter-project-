import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../models/health_record_model.dart';
import '../../../services/health_service.dart';
import '../../../data/services/user_service.dart';
import '../../../models/user_model.dart';

class HealthTrackerViewModel extends GetxController {
  final HealthService _healthService = HealthService();
  final UserService _userService = UserService();
  
  var isLoading = false.obs;
  var latestRecords = <HealthRecordType, HealthRecord>{}.obs;
  var currentUser = Rxn<UserModel>();

  // Patient context for doctors
  var targetPatientId = Rxn<String>();
  var targetPatientName = Rxn<String>();
  
  // Reactive current user ID to ensure stream updates on auth changes
  final RxString _currentAuthId = ''.obs;
  StreamSubscription? _recordsSubscription;
  StreamSubscription? _authSubscription;

  @override
  void onInit() {
    super.onInit();
    
    // Check for patient context from arguments (e.g. from AppointmentDetails)
    if (Get.arguments != null) {
      if (Get.arguments is Map) {
        targetPatientId.value = Get.arguments['patientId'];
        targetPatientName.value = Get.arguments['patientName'];
      }
    }

    // Listen to Auth State Changes
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      _currentAuthId.value = user?.uid ?? '';
      _loadUserData();
    });

    // Re-listen to health records whenever IDs change
    ever(_currentAuthId, (_) => _listenToHealthRecords());
    ever(targetPatientId, (_) => _listenToHealthRecords());
    
    // Load initial data
    _loadUserData();
    _listenToHealthRecords();
  }

  @override
  void onClose() {
    _recordsSubscription?.cancel();
    _authSubscription?.cancel();
    super.onClose();
  }

  Future<void> _loadUserData() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      final user = await _userService.getUserProfile(userId);
      currentUser.value = user;
    }
  }

  void _listenToHealthRecords() {
    final userId = targetPatientId.value ?? _currentAuthId.value;
    if (userId.isEmpty) return;

    _recordsSubscription?.cancel();
    _recordsSubscription = _healthService.getLatestHealthRecords(userId).listen((records) {
      Map<HealthRecordType, HealthRecord> map = {};
      for (var record in records) {
        map[record.type] = record;
      }
      latestRecords.value = map;
      latestRecords.refresh(); // Force GetX to notify observers
    }, onError: (error) {

    });
  }

  // BMI Calculation Logic
  double calculateBMI(double weight, double height) {
    if (height <= 0) return 0;
    return weight / ((height / 100) * (height / 100));
  }

  String getBMICategory(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  Color getBMIColor(String category) {
    switch (category) {
      case 'Underweight': return Colors.blue;
      case 'Normal': return Colors.green;
      case 'Overweight': return Colors.orange;
      case 'Obese': return Colors.red;
      default: return Colors.grey;
    }
  }

  // Save Record
  Future<void> saveRecord({
    required HealthRecordType type,
    required Map<String, dynamic> data,
    String? notes,
  }) async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) return;

    // Determine who we are saving for
    final userId = targetPatientId.value ?? currentUserId;
    final isRecordingForPatient = targetPatientId.value != null && currentUser.value?.role == 'Doctor';

    try {
      isLoading.value = true;
      final record = HealthRecord(
        userId: userId,
        recordedBy: isRecordingForPatient ? currentUserId : null,
        recordedByName: isRecordingForPatient ? currentUser.value?.fullName : null,
        type: type,
        data: data,
        timestamp: DateTime.now(),
        notes: notes,
      );
      await _healthService.addHealthRecord(record);
      Get.back(); // Return after saving
      Get.snackbar(
        'Success',
        'Health record saved successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 1),
        animationDuration: const Duration(milliseconds: 300),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
        animationDuration: const Duration(milliseconds: 300),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Get display value for each type
  String getDisplayValue(HealthRecordType type) {
    final record = latestRecords[type];
    if (record == null) return 'No data';

    switch (type) {
      case HealthRecordType.bmi:
        return '${record.bmiValue?.toStringAsFixed(1)} (${record.bmiCategory})';
      case HealthRecordType.bloodPressure:
        return '${record.bpSystolic}/${record.bpDiastolic} mmHg';
      case HealthRecordType.sugarLevel:
        return '${record.sugarValue} mg/dL';
      case HealthRecordType.bodyTemperature:
        return '${record.temperature}°C';
      case HealthRecordType.oxygenSaturation:
        return '${record.oxygen}%';
      case HealthRecordType.hemoglobin:
        return '${record.hemoglobin} g/dL';
      case HealthRecordType.weight:
        return '${record.weight} kg';
    }
  }

  Future<void> refreshRecords() async {
    _listenToHealthRecords();
  }
}
