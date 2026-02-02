// lib/app/modules/prescription/bindings/prescription_binding.dart

import 'package:get/get.dart';
import '../viewmodels/create_prescription_viewmodel.dart';
import '../viewmodels/prescription_list_viewmodel.dart';
import '../viewmodels/prescription_detail_viewmodel.dart';
import '../../../data/services/auth_service.dart';

class PrescriptionBinding extends Bindings {
  @override
  void dependencies() {
    // Register AuthService if not already registered
    if (!Get.isRegistered<AuthService>()) {
      Get.put(AuthService(), permanent: true);
    }
    
    // Lazy load view models as needed
    Get.lazyPut<CreatePrescriptionViewModel>(() => CreatePrescriptionViewModel());
    Get.lazyPut<PrescriptionListViewModel>(() => PrescriptionListViewModel());
    Get.lazyPut<PrescriptionDetailViewModel>(() => PrescriptionDetailViewModel());
  }
}
