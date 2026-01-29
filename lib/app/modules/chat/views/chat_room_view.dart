// lib/app/modules/chat/views/chat_room_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:semesterprojectgetx/app/core/theme/app_theme.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:semesterprojectgetx/app/modules/chat/viewmodels/chat_room_viewmodel.dart';
import 'package:semesterprojectgetx/app/models/message_model.dart';

class ChatRoomView extends StatelessWidget {
  const ChatRoomView({super.key});

  @override
  Widget build(BuildContext context) {
    final ChatRoomViewModel viewModel = Get.put(ChatRoomViewModel());

    return Scaffold(
      backgroundColor: AppTheme.lightGreen,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppTheme.primaryGreen,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white,
              backgroundImage: viewModel.getOtherParticipantImage() != null
                  ? CachedNetworkImageProvider(
                      viewModel.getOtherParticipantImage()!)
                  : null,
              child: viewModel.getOtherParticipantImage() == null
                  ? Text(
                      viewModel.getOtherParticipantName().isNotEmpty
                          ? viewModel.getOtherParticipantName()[0].toUpperCase()
                          : "U",
                      style: TextStyle(
                        color: AppTheme.primaryGreen,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    viewModel.getOtherParticipantName(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Obx(() => Text(
                        viewModel.isOtherUserOnline.value
                            ? 'Online'
                            : (viewModel.lastSeenTime.value != null
                                ? 'Last seen ${DateFormat('h:mm a').format(viewModel.lastSeenTime.value!)}'
                                : 'Offline'),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      )),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam, color: Colors.white),
            onPressed: () {
              viewModel.initiateVideoCall();
            },
          ),
          IconButton(
            icon: const Icon(Icons.call, color: Colors.white),
            onPressed: () {
              viewModel.initiateCall();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: Obx(() {
              if (viewModel.isLoading.value) {
                return Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.primaryGreen,
                  ),
                );
              }

              if (viewModel.messages.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 60,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No messages yet',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Start the conversation!',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                controller: viewModel.scrollController,
                reverse: true,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 16,
                ),
                itemCount: viewModel.messages.length,
                itemBuilder: (context, index) {
                  MessageModel message = viewModel.messages[index];
                  bool isSentByMe = message.senderId == viewModel.currentUserId;

                  return GestureDetector(
                    onLongPress: isSentByMe ? () => _showMessageActions(context, viewModel, message) : null,
                    child: _buildMessageBubble(
                      message: message,
                      isSentByMe: isSentByMe,
                    ),
                  );
                },
              );
            }),
          ),

          // Message Input
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  // Emoji/Attachment button
                  IconButton(
                    icon: Icon(
                      Icons.add_circle_outline,
                      color: AppTheme.primaryGreen,
                    ),
                    onPressed: () {
                      // Future: Attachment feature
                      Get.snackbar(
                        'Coming Soon',
                        'Attachment feature will be available soon',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
                  ),

                  // Text Input
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: viewModel.messageController,
                        decoration: const InputDecoration(
                          hintText: 'Type a message...',
                          border: InputBorder.none,
                          hintStyle: TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 14,
                          ),
                        ),
                        maxLines: null,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Send Button
                  Obx(() => Container(
                        decoration: const BoxDecoration(
                          color: AppTheme.primaryGreen,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: viewModel.isSending.value
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(
                                  Icons.send,
                                  color: Colors.white,
                                  size: 20,
                                ),
                          onPressed: viewModel.isSending.value
                              ? null
                              : viewModel.sendMessage,
                        ),
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble({
    required MessageModel message,
    required bool isSentByMe,
  }) {
    return Align(
      alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: isSentByMe
              ? AppTheme.primaryGreen
              : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isSentByMe
                ? const Radius.circular(16)
                : const Radius.circular(4),
            bottomRight: isSentByMe
                ? const Radius.circular(4)
                : const Radius.circular(16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.content ?? '',
              style: TextStyle(
                color: isSentByMe ? Colors.white : const Color(0xFF1A1A2E),
                fontSize: 15,
              ),
            ),
            if (message.isEdited ?? false)
              const Text(
                'Edited',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                  fontStyle: FontStyle.italic,
                ),
              ),
            const SizedBox(height: 4),
            Text(
              message.isEdited ?? false
                  ? 'Edited ${message.editedAt != null ? DateFormat('h:mm a').format(message.editedAt!) : ''}'
                  : (message.timestamp != null
                      ? DateFormat('h:mm a').format(message.timestamp!)
                      : ''),
              style: TextStyle(
                color: isSentByMe ? Colors.white70 : const Color(0xFF6B7280),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMessageActions(BuildContext context, ChatRoomViewModel viewModel, MessageModel message) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.edit, color: AppTheme.primaryGreen),
              title: const Text('Edit Message'),
              onTap: () {
                Get.back();
                _showEditDialog(context, viewModel, message);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete, color: AppTheme.errorRed),
              title: const Text('Delete Message'),
              onTap: () {
                Get.back();
                Get.dialog(
                  AlertDialog(
                    title: const Text('Delete Message'),
                    content: const Text('Are you sure you want to delete this message?'),
                    actions: [
                      TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
                      TextButton(
                        onPressed: () {
                          viewModel.deleteMessage(message.id!);
                          Get.back();
                        },
                        child: Text('Delete', style: TextStyle(color: AppTheme.errorRed)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, ChatRoomViewModel viewModel, MessageModel message) {
    final TextEditingController editController = TextEditingController(text: message.content);
    Get.dialog(
      AlertDialog(
        title: const Text('Edit Message'),
        content: TextField(
          controller: editController,
          decoration: const InputDecoration(hintText: 'Enter new message...'),
          autofocus: true,
          maxLines: null,
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              viewModel.editMessage(message.id!, editController.text);
              Get.back();
            },
            child: Text('Save', style: TextStyle(color: AppTheme.primaryGreen)),
          ),
        ],
      ),
    );
  }
}
