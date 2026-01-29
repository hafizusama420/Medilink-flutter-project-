// lib/app/modules/appointment/bindings/appointment_binding.dart
import 'package:get/get.dart';
import '../../../data/services/appointment_service.dart';
import '../viewmodels/appointments_list_viewmodel.dart';
import '../viewmodels/create_appointment_viewmodel.dart';
import '../viewmodels/appointment_details_viewmodel.dart';
import '../viewmodels/edit_appointment_viewmodel.dart';

class AppointmentBinding extends Bindings {
  @override
  void dependencies() {
    // Services
    Get.lazyPut(() => AppointmentService());

    // ViewModels
    Get.lazyPut(() => AppointmentsListViewModel());
    Get.lazyPut(() => CreateAppointmentViewModel());
    Get.lazyPut(() => AppointmentDetailsViewModel());
    Get.lazyPut(() => EditAppointmentViewModel());
  }
}
