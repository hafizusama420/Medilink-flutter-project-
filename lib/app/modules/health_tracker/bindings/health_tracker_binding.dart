// lib/app/modules/health_tracker/bindings/health_tracker_binding.dart

import 'package:get/get.dart';
import '../viewmodels/health_tracker_viewmodel.dart';

class HealthTrackerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HealthTrackerViewModel>(() => HealthTrackerViewModel());
  }
}
