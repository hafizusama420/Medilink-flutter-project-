// lib/app/modules/chat/viewmodels/chat_list_viewmodel.dart
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:semesterprojectgetx/app/data/services/chat_service.dart';
import 'package:semesterprojectgetx/app/data/services/user_service.dart';
import 'package:semesterprojectgetx/app/models/chat_room_model.dart';

class ChatListViewModel extends GetxController {
  final ChatService _chatService = ChatService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  var chatRooms = <ChatRoomModel>[].obs;
  var isLoading = true.obs;
  var totalUnreadCount = 0.obs;
  var userRole = 'Patient'.obs;
  bool get isDoctor => userRole.value == 'Doctor';

  @override
  void onInit() {
    super.onInit();
    loadUserRole();
    loadChatRooms();
    loadUnreadCount();
  }

  void loadUserRole() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // We can use UserService to get the profile
        final UserService userService = UserService();
        final profile = await userService.getUserProfile(user.uid);
        if (profile != null) {
          userRole.value = profile.role ?? 'Patient';
        }
      }
    } catch (e) {
      // print('ChatListViewModel: Error loading user role: $e');
    }
  }

  void loadChatRooms() {
    try {
      String? currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) {
        // print('ChatListViewModel: No user logged in');
        isLoading.value = false;
        return;
      }

      // print('ChatListViewModel: Loading chat rooms for user: $currentUserId');
      
      _chatService.getChatRooms(currentUserId).listen((rooms) {
        chatRooms.value = rooms;
        isLoading.value = false;
        // print('ChatListViewModel: Loaded ${rooms.length} chat rooms');
      }, onError: (error) {
        // print('ChatListViewModel: Error loading chat rooms: $error');
        isLoading.value = false;
        Get.snackbar(
          'Error',
          'Failed to load chats',
          snackPosition: SnackPosition.BOTTOM,
        );
      });
    } catch (e) {
      // print('ChatListViewModel: Error in loadChatRooms: $e');
      isLoading.value = false;
    }
  }

  void loadUnreadCount() async {
    try {
      String? currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) return;

      int count = await _chatService.getTotalUnreadCount(currentUserId);
      totalUnreadCount.value = count;
    } catch (e) {
      // print('ChatListViewModel: Error loading unread count: $e');
    }
  }

  void navigateToChatRoom(ChatRoomModel chatRoom) {
    Get.toNamed('/chat-room', arguments: chatRoom);
  }

  String getCurrentUserId() {
    return _auth.currentUser?.uid ?? '';
  }
}
