// lib/app/modules/assignments/viewmodels/assignment_list_viewmodel.dart

import 'package:get/get.dart';
import '../../../models/assignment_model.dart';
import '../../../services/assignment_service.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/user_service.dart';
import '../../../models/user_model.dart';

class AssignmentListViewModel extends GetxController {
  final AssignmentService _assignmentService = AssignmentService();
  final AuthService _authService = Get.find<AuthService>();
  final UserService _userService = UserService();

  // Observable variables
  final isLoading = false.obs;
  final allAssignments = <AssignmentModel>[].obs;
  final filteredAssignments = <AssignmentModel>[].obs;
  final currentFilter = 'All'.obs; // All, Pending, Completed, Overdue
  final errorMessage = ''.obs;
  final currentUser = Rx<UserModel?>(null);

  // Check if user is doctor
  bool get isDoctor => currentUser.value?.role == 'Doctor';
  String? get userId => _authService.currentUser?.uid;

  @override
  void onInit() {
    super.onInit();
    _initUserAndLoad();
  }

  /// Initialize user profile and then load assignments
  Future<void> _initUserAndLoad() async {
    if (userId == null) {
      errorMessage.value = 'User not authenticated';
      return;
    }

    try {
      isLoading.value = true;
      final profile = await _userService.getUserProfile(userId!);
      currentUser.value = profile;
      loadAssignments();
    } catch (e) {
      errorMessage.value = 'Failed to load user profile: $e';
      isLoading.value = false;
    }
  }

  /// Load assignments based on user role
  void loadAssignments() {
    if (userId == null) {
      errorMessage.value = 'User not authenticated';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      if (isDoctor) {
        // Doctor: Load assignments they created
        _assignmentService.getDoctorAssignments(userId!).listen(
          (assignments) {
            allAssignments.value = assignments;
            applyFilter(currentFilter.value);
            isLoading.value = false;
          },
          onError: (error) {
            errorMessage.value = 'Failed to load assignments: $error';
            isLoading.value = false;
          },
        );
      } else {
        // Patient: Load their assignments
        _assignmentService.getPatientAssignments(userId!).listen(
          (assignments) {
            allAssignments.value = assignments;
            applyFilter(currentFilter.value);
            isLoading.value = false;
          },
          onError: (error) {
            errorMessage.value = 'Failed to load assignments: $error';
            isLoading.value = false;
          },
        );
      }
    } catch (e) {
      errorMessage.value = 'Error loading assignments: $e';
      isLoading.value = false;
    }
  }

  /// Apply filter to assignments
  void applyFilter(String filter) {
    currentFilter.value = filter;

    switch (filter) {
      case 'Pending':
        filteredAssignments.value = allAssignments
            .where((a) => a.status == 'Pending' || a.status == 'In Progress')
            .toList();
        break;
      case 'Completed':
        filteredAssignments.value = allAssignments
            .where((a) => a.status == 'Completed')
            .toList();
        break;
      case 'Overdue':
        filteredAssignments.value = allAssignments
            .where((a) => a.isOverdue && a.status != 'Completed')
            .toList();
        break;
      default:
        filteredAssignments.value = allAssignments.toList();
    }
  }

  /// Navigate to assignment details
  void navigateToAssignmentDetails(String assignmentId) {
    Get.toNamed('/assignment-detail', arguments: {'assignmentId': assignmentId});
  }

  /// Navigate to create assignment (doctors only)
  void navigateToCreateAssignment() {
    if (isDoctor) {
      Get.toNamed('/create-assignment');
    }
  }

  /// Refresh assignments
  Future<void> refreshAssignments() async {
    loadAssignments();
  }

  /// Delete assignment (doctors only)
  Future<void> deleteAssignment(String assignmentId) async {
    try {
      await _assignmentService.deleteAssignment(assignmentId);
      Get.snackbar('Success', 'Assignment deleted successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete assignment: $e');
    }
  }

  /// Get count by status
  int get pendingCount => allAssignments
      .where((a) => a.status == 'Pending' || a.status == 'In Progress')
      .length;

  int get completedCount =>
      allAssignments.where((a) => a.status == 'Completed').length;

  int get overdueCount =>
      allAssignments.where((a) => a.isOverdue && a.status != 'Completed').length;
}
