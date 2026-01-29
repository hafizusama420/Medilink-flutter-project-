import 'package:get/get.dart';
import '../viewmodels/lab_tests_viewmodel.dart';

class LabTestsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LabTestsViewModel>(
      () => LabTestsViewModel(),
    );
  }
}
