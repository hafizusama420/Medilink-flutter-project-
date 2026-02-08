// lib/app/modules/assignments/viewmodels/create_assignment_viewmodel.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../models/assignment_model.dart';
import '../../../services/assignment_service.dart';
import '../../../data/services/user_service.dart';

class CreateAssignmentViewModel extends GetxController {
  final AssignmentService _assignmentService = AssignmentService();
  final UserService _userService = UserService();

  // Form controllers
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  
  // Observable variables
  final isLoading = false.obs;
  final selectedCategory = 'Exercise'.obs;
  final selectedPriority = 'Medium'.obs;
  final selectedFrequency = 'Daily'.obs;
  final startDate = Rx<DateTime?>(null);
  final dueDate = Rx<DateTime?>(null);

  // Categories
  final categories = ['Exercise', 'Medication', 'Lifestyle', 'Monitoring', 'Follow-up'];
  final priorities = ['Low', 'Medium', 'High'];
  final frequencies = ['Daily', 'Weekly', 'As Needed', 'One-time'];

  // Patient and appointment info from arguments
  String? patientId;
  String? patientName;
  String? appointmentId;
  String? doctorName;
  AssignmentModel? existingAssignment;
  bool isEditMode = false;

  @override
  void onInit() {
    super.onInit();
    _loadArguments();
  }

  void _loadArguments() async {
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      patientId = args['patientId'] as String?;
      patientName = args['patientName'] as String?;
      appointmentId = args['appointmentId'] as String?;
      existingAssignment = args['assignment'] as AssignmentModel?;
      isEditMode = args['isEdit'] == true;

      if (existingAssignment != null) {
        _populateFormWithExistingData();
      }
    }

    // Get doctor name
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      try {
        final userProfile = await _userService.getUserProfile(userId);
        doctorName = userProfile?.fullName;
      } catch (e) {

      }
    }
  }

  void _populateFormWithExistingData() {
    if (existingAssignment == null) return;

    titleController.text = existingAssignment!.title ?? '';
    descriptionController.text = existingAssignment!.description ?? '';
    selectedCategory.value = existingAssignment!.category ?? 'Exercise';
    selectedPriority.value = existingAssignment!.priority ?? 'Medium';
    selectedFrequency.value = existingAssignment!.frequency ?? 'Daily';
    startDate.value = existingAssignment!.startDate;
    dueDate.value = existingAssignment!.dueDate;
  }

  Future<void> selectStartDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: startDate.value ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      startDate.value = picked;
    }
  }

  Future<void> selectDueDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: dueDate.value ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: startDate.value ?? DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      dueDate.value = picked;
    }
  }

  Future<void> saveAssignment() async {
    // Validation
    if (titleController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Please enter assignment title');
      return;
    }

    if (patientId == null) {
      Get.snackbar('Error', 'Patient information is missing');
      return;
    }

    if (startDate.value == null) {
      Get.snackbar('Error', 'Please select start date');
      return;
    }

    if (dueDate.value == null) {
      Get.snackbar('Error', 'Please select due date');
      return;
    }

    try {
      isLoading.value = true;

      final assignment = AssignmentModel(
        id: existingAssignment?.id,
        patientId: patientId,
        patientName: patientName,
        doctorId: FirebaseAuth.instance.currentUser?.uid,
        doctorName: doctorName,
        appointmentId: appointmentId,
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        category: selectedCategory.value,
        priority: selectedPriority.value,
        frequency: selectedFrequency.value,
        startDate: startDate.value,
        dueDate: dueDate.value,
        status: existingAssignment?.status ?? 'Pending',
        createdAt: existingAssignment?.createdAt,
        updatedAt: DateTime.now(),
      );

      if (isEditMode && existingAssignment != null) {
        await _assignmentService.updateAssignment(assignment);
        Get.back();
        Get.snackbar('Success', 'Assignment updated successfully');
      } else {
        await _assignmentService.createAssignment(assignment);
        Get.back();
        Get.snackbar('Success', 'Assignment created successfully');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to save assignment: $e');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    super.onClose();
  }
}
