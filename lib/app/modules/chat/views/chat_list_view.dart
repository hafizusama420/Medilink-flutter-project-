// lib/app/modules/chat/views/chat_list_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:semesterprojectgetx/app/modules/chat/viewmodels/chat_list_viewmodel.dart';
import 'package:semesterprojectgetx/app/models/chat_room_model.dart';
import '../../../core/theme/app_theme.dart';

class ChatListView extends StatelessWidget {
  const ChatListView({super.key});

  @override
  Widget build(BuildContext context) {
    final ChatListViewModel viewModel = Get.put(ChatListViewModel());

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppTheme.primaryGreen,
        title: const Text(
          'Messages',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Obx(() => viewModel.totalUnreadCount.value > 0
              ? Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${viewModel.totalUnreadCount.value}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                )
              : const SizedBox()),
        ],
      ),
      body: Obx(() {
        if (viewModel.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppTheme.primaryGreen,
            ),
          );
        }

        if (viewModel.chatRooms.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  size: 80,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 16),
                Text(
                  'No conversations yet',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  viewModel.isDoctor ? 'Connect with your patients' : 'Start chatting with a doctor',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
                if (!viewModel.isDoctor) ...[
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => Get.toNamed('/doctors'),
                    icon: const Icon(Icons.add),
                    label: const Text('Find Doctors'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            viewModel.loadChatRooms();
            viewModel.loadUnreadCount();
          },
          color: AppTheme.primaryGreen,
          child: ListView.builder(
            itemCount: viewModel.chatRooms.length,
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemBuilder: (context, index) {
              ChatRoomModel chatRoom = viewModel.chatRooms[index];
              String currentUserId = viewModel.getCurrentUserId();
              String otherParticipantName =
                  chatRoom.getOtherParticipantName(currentUserId);
              String? otherParticipantImage =
                  chatRoom.getOtherParticipantImage(currentUserId);
              int unreadCount = chatRoom.getUnreadCount(currentUserId);

              return _buildChatTile(
                chatRoom: chatRoom,
                participantName: otherParticipantName,
                participantImage: otherParticipantImage,
                unreadCount: unreadCount,
                onTap: () => viewModel.navigateToChatRoom(chatRoom),
              );
            },
          ),
        );
      }),
      floatingActionButton: Obx(() => !viewModel.isDoctor
          ? FloatingActionButton(
              onPressed: () => Get.toNamed('/doctors'),
              backgroundColor: AppTheme.primaryGreen,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : const SizedBox.shrink()),
    );
  }

  Widget _buildChatTile({
    required ChatRoomModel chatRoom,
    required String participantName,
    String? participantImage,
    required int unreadCount,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        leading: CircleAvatar(
          radius: 28,
          backgroundColor: AppTheme.primaryGreen,
          backgroundImage: participantImage != null
              ? CachedNetworkImageProvider(participantImage)
              : null,
          child: participantImage == null
              ? Text(
                  participantName[0].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
        ),
        title: Text(
          participantName,
          style: TextStyle(
            fontSize: 16,
            fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.w600,
            color: const Color(0xFF1A1A2E),
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            chatRoom.lastMessage ?? 'No messages yet',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              color: unreadCount > 0
                  ? const Color(0xFF1A1A2E)
                  : const Color(0xFF6B7280),
              fontWeight: unreadCount > 0 ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              chatRoom.lastMessageTime != null
                  ? timeago.format(chatRoom.lastMessageTime!)
                  : '',
              style: TextStyle(
                fontSize: 12,
                color: unreadCount > 0
                    ? AppTheme.primaryGreen
                    : const Color(0xFF6B7280),
                fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (unreadCount > 0) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$unreadCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
