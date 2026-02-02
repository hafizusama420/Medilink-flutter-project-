// lib/app/modules/prescription/viewmodels/prescription_list_viewmodel.dart

import 'package:get/get.dart';
import '../../../models/prescription_model.dart';
import '../../../services/prescription_service.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/user_service.dart';
import '../../../models/user_model.dart';

class PrescriptionListViewModel extends GetxController {
  final PrescriptionService _prescriptionService = PrescriptionService();
  final AuthService _authService = Get.find<AuthService>();
  final UserService _userService = UserService();

  // Observable variables
  final isLoading = false.obs;
  final allPrescriptions = <PrescriptionModel>[].obs;
  final filteredPrescriptions = <PrescriptionModel>[].obs;
  final currentFilter = 'all'.obs; // all, active, expired
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

  /// Initialize user profile and then load prescriptions
  Future<void> _initUserAndLoad() async {
    if (userId == null) {
      errorMessage.value = 'User not authenticated';
      return;
    }

    try {
      isLoading.value = true;
      final profile = await _userService.getUserProfile(userId!);
      currentUser.value = profile;
      loadPrescriptions();
    } catch (e) {
      errorMessage.value = 'Failed to load user profile: $e';
      isLoading.value = false;
    }
  }

  /// Load prescriptions based on user role
  void loadPrescriptions() {
    if (userId == null) {
      errorMessage.value = 'User not authenticated';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      if (isDoctor) {
        // Doctor: Load prescriptions they created
        _prescriptionService.getDoctorPrescriptions(userId!).listen(
          (prescriptions) {
            allPrescriptions.value = prescriptions;
            applyFilter(currentFilter.value);
            isLoading.value = false;
          },
          onError: (error) {
            errorMessage.value = 'Failed to load prescriptions: $error';
            isLoading.value = false;
          },
        );
      } else {
        // Patient: Load their prescriptions
        _prescriptionService.getPatientPrescriptions(userId!).listen(
          (prescriptions) {
            allPrescriptions.value = prescriptions;
            applyFilter(currentFilter.value);
            isLoading.value = false;
          },
          onError: (error) {
            errorMessage.value = 'Failed to load prescriptions: $error';
            isLoading.value = false;
          },
        );
      }
    } catch (e) {
      errorMessage.value = 'Error loading prescriptions: $e';
      isLoading.value = false;
    }
  }

  /// Apply filter to prescriptions
  void applyFilter(String filter) {
    currentFilter.value = filter;

    switch (filter) {
      case 'active':
        filteredPrescriptions.value = allPrescriptions
            .where((p) => p.status == 'active' && !p.isExpired)
            .toList();
        break;
      case 'expired':
        filteredPrescriptions.value = allPrescriptions
            .where((p) => p.status == 'expired' || p.isExpired)
            .toList();
        break;
      default:
        filteredPrescriptions.value = allPrescriptions.toList();
    }
  }

  /// Navigate to prescription details
  void navigateToPrescriptionDetails(String prescriptionId) {
    Get.toNamed('/prescription-details', arguments: {'prescriptionId': prescriptionId});
  }

  /// Refresh prescriptions
  Future<void> refreshPrescriptions() async {
    loadPrescriptions();
  }

  /// Search prescriptions by medication name
  void searchByMedication(String query) async {
    if (query.trim().isEmpty) {
      applyFilter(currentFilter.value);
      return;
    }

    try {
      isLoading.value = true;
      final results = await _prescriptionService.searchPrescriptionsByMedication(
        userId!,
        query,
      );
      filteredPrescriptions.value = results;
      isLoading.value = false;
    } catch (e) {
      errorMessage.value = 'Search failed: $e';
      isLoading.value = false;
    }
  }
}
