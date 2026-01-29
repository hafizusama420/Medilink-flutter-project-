// lib/app/modules/home/bindings/home_binding.dart
import 'package:get/get.dart';
import '../viewmodels/home_viewmodel.dart';
import '../../appointment/viewmodels/appointments_list_viewmodel.dart';
import '../../chat/viewmodels/chat_list_viewmodel.dart';
import '../../profile/viewmodels/profile_viewmodel.dart';
import '../../../data/services/appointment_service.dart';
import '../../../data/services/chat_service.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeViewModel>(() => HomeViewModel());
    Get.lazyPut<AppointmentsListViewModel>(() => AppointmentsListViewModel(), fenix: true);
    Get.lazyPut<ChatListViewModel>(() => ChatListViewModel(), fenix: true);
    Get.lazyPut<ProfileViewModel>(() => ProfileViewModel(), fenix: true);
    Get.lazyPut<AppointmentService>(() => AppointmentService());
    Get.lazyPut<ChatService>(() => ChatService());
  }
}
