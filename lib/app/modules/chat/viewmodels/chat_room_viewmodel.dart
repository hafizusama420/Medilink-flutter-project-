// lib/app/modules/chat/viewmodels/chat_room_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:semesterprojectgetx/app/data/services/chat_service.dart';
import 'package:semesterprojectgetx/app/data/services/call_service.dart';
import 'package:semesterprojectgetx/app/models/chat_room_model.dart';
import 'package:semesterprojectgetx/app/models/message_model.dart';

class ChatRoomViewModel extends GetxController {
  final ChatService _chatService = ChatService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  var messages = <MessageModel>[].obs;
  var isLoading = true.obs;
  var isSending = false.obs;
  
  ChatRoomModel? chatRoom; // Made nullable for safety
  String currentUserId = '';
  String receiverId = '';

  // Presence states
  var isOtherUserOnline = false.obs;
  var lastSeenTime = Rx<DateTime?>(null);

  @override
  void onInit() {
    super.onInit();
    
    if (Get.arguments == null || Get.arguments is! ChatRoomModel) {
      // print('ChatRoomViewModel: Error - Invalid or null arguments');
      Future.delayed(Duration.zero, () {
        Get.back();
        Get.snackbar(
          'Error',
          'Chat room data missing. Returning to list.',
          snackPosition: SnackPosition.BOTTOM,
        );
      });
      return;
    }

    chatRoom = Get.arguments as ChatRoomModel;
    currentUserId = _auth.currentUser?.uid ?? '';
    
    // Determine receiver ID
    if (currentUserId == chatRoom!.doctorId) {
      receiverId = chatRoom!.patientId ?? '';
    } else {
      receiverId = chatRoom!.doctorId ?? '';
    }
    
    // Update presence to Online
    _updatePresence(true);
    
    // Listen to other participant's presence
    _listenToParticipantPresence();
    
    loadMessages();
    markMessagesAsRead();
  }

  void loadMessages() {
    if (chatRoom == null) return;
    try {
      // print('ChatRoomViewModel: Loading messages for room: ${chatRoom!.id}');
      
      _chatService.getMessages(chatRoom!.id!).listen((messageList) {
        messages.value = messageList;
        isLoading.value = false;
        // print('ChatRoomViewModel: Loaded ${messageList.length} messages');
        
        // Auto scroll to bottom on new message
        if (scrollController.hasClients) {
          Future.delayed(const Duration(milliseconds: 100), () {
            scrollController.animateTo(
              0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          });
        }
      }, onError: (error) {
        // print('ChatRoomViewModel: Error loading messages: $error');
        isLoading.value = false;
        Get.snackbar(
          'Error',
          'Failed to load messages',
          snackPosition: SnackPosition.BOTTOM,
        );
      });
    } catch (e) {
      // print('ChatRoomViewModel: Error in loadMessages: $e');
      isLoading.value = false;
    }
  }

  void sendMessage() async {
    if (messageController.text.trim().isEmpty || chatRoom == null) {
      return;
    }

    try {
      isSending.value = true;
      String messageContent = messageController.text.trim();
      String senderName = _auth.currentUser?.displayName ?? 'User';

      // print('ChatRoomViewModel: Sending message: $messageContent');

      await _chatService.sendMessage(
        roomId: chatRoom!.id!,
        senderId: currentUserId,
        senderName: senderName,
        content: messageContent,
        receiverId: receiverId,
      );

      messageController.clear();
      isSending.value = false;
      
      // print('ChatRoomViewModel: Message sent successfully');
    } catch (e) {
      // print('ChatRoomViewModel: Error sending message: $e');
      isSending.value = false;
      Get.snackbar(
        'Error',
        'Failed to send message',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void markMessagesAsRead() async {
    if (chatRoom == null) return;
    try {
      await _chatService.markMessagesAsRead(chatRoom!.id!, currentUserId);
      // print('ChatRoomViewModel: Messages marked as read');
    } catch (e) {
      // print('ChatRoomViewModel: Error marking messages as read: $e');
    }
  }

  String getOtherParticipantName() {
    return chatRoom?.getOtherParticipantName(currentUserId) ?? 'Chat';
  }

  String? getOtherParticipantImage() {
    return chatRoom?.getOtherParticipantImage(currentUserId);
  }

  // --- PRESENCE LOGIC ---
  void _updatePresence(bool isOnline) {
    if (currentUserId.isNotEmpty) {
      _chatService.updateUserStatus(currentUserId, isOnline);
    }
  }

  void _listenToParticipantPresence() {
    if (receiverId.isNotEmpty) {
      _chatService.getUserPresence(receiverId).listen((data) {
        if (data != null) {
          isOtherUserOnline.value = data['isOnline'] ?? false;
          if (data['lastSeen'] != null) {
            lastSeenTime.value = (data['lastSeen'] as Timestamp).toDate();
          }
        }
      });
    }
  }

  // --- MESSAGE ACTIONS ---
  Future<void> deleteMessage(String messageId) async {
    if (chatRoom == null) return;
    try {
      await _chatService.deleteMessage(chatRoom!.id!, messageId);
      Get.snackbar('Success', 'Message deleted', snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      // print('ChatRoomViewModel: Error deleting message: $e');
      Get.snackbar('Error', 'Failed to delete message', snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> editMessage(String messageId, String newContent) async {
    if (chatRoom == null || newContent.trim().isEmpty) return;
    try {
      await _chatService.editMessage(chatRoom!.id!, messageId, newContent);
      Get.snackbar('Success', 'Message edited', snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      // print('ChatRoomViewModel: Error editing message: $e');
      Get.snackbar('Error', 'Failed to edit message', snackPosition: SnackPosition.BOTTOM);
    }
  }

  /// Initiate audio call to the other participant
  void initiateCall() {
    if (receiverId.isEmpty) {
      Get.snackbar(
        'Error',
        'Unable to initiate call. Receiver information missing.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      final CallService callService = CallService();
      final String receiverName = getOtherParticipantName();
      
      print('📞 [ChatRoomViewModel] Initiating call to: $receiverName ($receiverId)');
      
      callService.sendCallInvitation(receiverId, receiverName);
      
      Get.snackbar(
        'Calling',
        'Calling $receiverName...',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      print('❌ [ChatRoomViewModel] Error initiating call: $e');
      Get.snackbar(
        'Error',
        'Failed to initiate call. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Initiate VIDEO call to the other participant
  void initiateVideoCall() {
    if (receiverId.isEmpty) {
      Get.snackbar(
        'Error',
        'Unable to initiate video call. Receiver information missing.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      final CallService callService = CallService();
      final String receiverName = getOtherParticipantName();
      
      print('📹 [ChatRoomViewModel] Initiating video call to: $receiverName ($receiverId)');
      
      callService.sendVideoCallInvitation(receiverId, receiverName);
      
      Get.snackbar(
        'Video Calling',
        'Video calling $receiverName...',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      print('❌ [ChatRoomViewModel] Error initiating video call: $e');
      Get.snackbar(
        'Error',
        'Failed to initiate video call. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  void onClose() {
    // Update presence to Offline
    _updatePresence(false);
    
    messageController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}
