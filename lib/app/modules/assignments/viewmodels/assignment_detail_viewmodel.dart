// lib/app/modules/assignments/viewmodels/assignment_detail_viewmodel.dart

import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../models/assignment_model.dart';
import '../../../services/assignment_service.dart';
import '../../../data/services/user_service.dart';
import '../../../models/user_model.dart';

class AssignmentDetailViewModel extends GetxController {
  final AssignmentService _assignmentService = AssignmentService();
  final UserService _userService = UserService();

  // Observable variables
  final isLoading = false.obs;
  final assignment = Rx<AssignmentModel?>(null);
  final errorMessage = ''.obs;
  final currentUser = Rx<UserModel?>(null);
  final notesController = ''.obs;

  // Check if user is doctor
  bool get isDoctor => currentUser.value?.role == 'Doctor';
  String? get userId => FirebaseAuth.instance.currentUser?.uid;

  @override
  void onInit() {
    super.onInit();
    _initUserAndLoad();
  }

  /// Initialize user profile and load assignment
  Future<void> _initUserAndLoad() async {
    if (userId == null) {
      errorMessage.value = 'User not authenticated';
      return;
    }

    try {
      final profile = await _userService.getUserProfile(userId!);
      currentUser.value = profile;
      
      final args = Get.arguments as Map<String, dynamic>?;
      final assignmentId = args?['assignmentId'] as String?;
      
      if (assignmentId != null) {
        loadAssignment(assignmentId);
      }
    } catch (e) {
      errorMessage.value = 'Failed to load user profile: $e';
    }
  }

  /// Load assignment details
  void loadAssignment(String assignmentId) {
    isLoading.value = true;
    errorMessage.value = '';

    _assignmentService.getAssignmentStream(assignmentId).listen(
      (assignmentData) {
        assignment.value = assignmentData;
        notesController.value = assignmentData?.notes ?? '';
        isLoading.value = false;
      },
      onError: (error) {
        errorMessage.value = 'Failed to load assignment: $error';
        isLoading.value = false;
      },
    );
  }

  /// Mark assignment as complete (patients only)
  Future<void> markAsComplete() async {
    if (assignment.value == null || isDoctor) return;

    try {
      isLoading.value = true;
      await _assignmentService.markAsComplete(
        assignment.value!.id!,
        notes: notesController.value.isNotEmpty ? notesController.value : null,
      );
      Get.snackbar('Success', 'Assignment marked as complete');
      isLoading.value = false;
    } catch (e) {
      errorMessage.value = 'Failed to mark as complete: $e';
      Get.snackbar('Error', 'Failed to mark as complete: $e');
      isLoading.value = false;
    }
  }

  /// Update patient notes
  Future<void> updateNotes(String notes) async {
    if (assignment.value == null) return;

    try {
      final updatedAssignment = assignment.value!.copyWith(notes: notes);
      await _assignmentService.updateAssignment(updatedAssignment);
      Get.snackbar('Success', 'Notes updated successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update notes: $e');
    }
  }

  /// Delete assignment (doctors only)
  Future<void> deleteAssignment() async {
    if (assignment.value == null || !isDoctor) return;

    try {
      await _assignmentService.deleteAssignment(assignment.value!.id!);
      Get.back();
      Get.snackbar('Success', 'Assignment deleted successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete assignment: $e');
    }
  }

  /// Navigate to edit assignment (doctors only)
  void navigateToEdit() {
    if (isDoctor && assignment.value != null) {
      Get.toNamed('/create-assignment', arguments: {
        'assignment': assignment.value,
        'isEdit': true,
      });
    }
  }
}
