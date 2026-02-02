// lib/app/modules/assignments/bindings/assignment_binding.dart

import 'package:get/get.dart';
import '../viewmodels/assignment_list_viewmodel.dart';
import '../viewmodels/assignment_detail_viewmodel.dart';

class AssignmentBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AssignmentListViewModel>(() => AssignmentListViewModel());
    Get.lazyPut<AssignmentDetailViewModel>(() => AssignmentDetailViewModel());
  }
}
