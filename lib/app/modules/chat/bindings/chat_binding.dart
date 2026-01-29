// lib/app/modules/chat/bindings/chat_binding.dart
import 'package:get/get.dart';
import 'package:semesterprojectgetx/app/modules/chat/viewmodels/chat_list_viewmodel.dart';
import 'package:semesterprojectgetx/app/modules/chat/viewmodels/chat_room_viewmodel.dart';

class ChatBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ChatListViewModel>(() => ChatListViewModel());
    Get.lazyPut<ChatRoomViewModel>(() => ChatRoomViewModel());
  }
}
