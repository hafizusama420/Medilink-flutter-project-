// lib/app/modules/doctors/bindings/doctor_binding.dart
import 'package:get/get.dart';
import 'package:semesterprojectgetx/app/modules/doctors/viewmodels/doctor_list_viewmodel.dart';

class DoctorBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DoctorListViewModel>(() => DoctorListViewModel());
  }
}
