// lib/app/data/services/chat_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:semesterprojectgetx/app/models/chat_room_model.dart';
import 'package:semesterprojectgetx/app/models/message_model.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _chatRoomsCollection = 'chatRooms';
  final String _messagesCollection = 'messages';

  // Get or create chat room between doctor and patient
  Future<ChatRoomModel> getOrCreateChatRoom({
    required String doctorId,
    required String patientId,
    required String doctorName,
    required String patientName,
    String? doctorProfileImage,
    String? patientProfileImage,
  }) async {
    try {
      // print('ChatService: Getting or creating chat room...');
      // print('Doctor ID: $doctorId, Patient ID: $patientId');

      // Check if chat room already exists
      QuerySnapshot existingRooms = await _firestore
          .collection(_chatRoomsCollection)
          .where('doctorId', isEqualTo: doctorId)
          .where('patientId', isEqualTo: patientId)
          .get();

      if (existingRooms.docs.isNotEmpty) {
        // print('ChatService: Chat room already exists');
        return ChatRoomModel.fromMap(
          existingRooms.docs.first.data() as Map<String, dynamic>,
          existingRooms.docs.first.id,
        );
      }

      // Create new chat room
      ChatRoomModel newRoom = ChatRoomModel(
        doctorId: doctorId,
        patientId: patientId,
        doctorName: doctorName,
        patientName: patientName,
        doctorProfileImage: doctorProfileImage,
        patientProfileImage: patientProfileImage,
        lastMessage: '',
        lastMessageTime: DateTime.now(),
        unreadCountDoctor: 0,
        unreadCountPatient: 0,
        createdAt: DateTime.now(),
      );

      DocumentReference docRef = await _firestore
          .collection(_chatRoomsCollection)
          .add(newRoom.toMap());

      // print('ChatService: Created new chat room with ID: ${docRef.id}');
      
      return newRoom.copyWith(id: docRef.id);
    } catch (e) {
      // print('ChatService: Error getting/creating chat room: $e');
      rethrow;
    }
  }

  // Get chat rooms for a user (stream for real-time updates)
  Stream<List<ChatRoomModel>> getChatRooms(String userId) {
    // print('ChatService: Getting chat rooms for user: $userId');
    
    return _firestore
        .collection(_chatRoomsCollection)
        .where(Filter.or(
          Filter('doctorId', isEqualTo: userId),
          Filter('patientId', isEqualTo: userId),
        ))
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) {
          // print('ChatService: Received ${snapshot.docs.length} chat rooms');
          return snapshot.docs
              .map((doc) => ChatRoomModel.fromMap(
                    doc.data(),
                    doc.id,
                  ))
              .toList();
        });
  }

  // Send a message
  Future<void> sendMessage({
    required String roomId,
    required String senderId,
    required String senderName,
    required String content,
    required String receiverId,
  }) async {
    try {
      // print('ChatService: Sending message in room: $roomId');
      
      MessageModel message = MessageModel(
        senderId: senderId,
        senderName: senderName,
        content: content,
        timestamp: DateTime.now(),
        isRead: false,
        messageType: 'text',
      );

      // Add message to subcollection
      await _firestore
          .collection(_chatRoomsCollection)
          .doc(roomId)
          .collection(_messagesCollection)
          .add(message.toMap());

      // Update chat room with last message
      await updateLastMessage(
        roomId: roomId,
        lastMessage: content,
        senderId: senderId,
        receiverId: receiverId,
      );

      // print('ChatService: Message sent successfully');
    } catch (e) {
      // print('ChatService: Error sending message: $e');
      rethrow;
    }
  }

  // Get messages in a chat room (stream for real-time updates)
  Stream<List<MessageModel>> getMessages(String roomId) {
    // print('ChatService: Getting messages for room: $roomId');
    
    return _firestore
        .collection(_chatRoomsCollection)
        .doc(roomId)
        .collection(_messagesCollection)
        .orderBy('timestamp', descending: true)
        .limit(50) // Limit to last 50 messages
        .snapshots()
        .map((snapshot) {
          // print('ChatService: Received ${snapshot.docs.length} messages');
          return snapshot.docs
              .map((doc) => MessageModel.fromMap(
                    doc.data(),
                    doc.id,
                  ))
              .toList();
        });
  }

  // Update last message in chat room
  Future<void> updateLastMessage({
    required String roomId,
    required String lastMessage,
    required String senderId,
    required String receiverId,
  }) async {
    try {
      // print('ChatService: Updating last message for room: $roomId');
      
      // Get current chat room to determine who is doctor and who is patient
      DocumentSnapshot roomDoc = await _firestore
          .collection(_chatRoomsCollection)
          .doc(roomId)
          .get();
      
      if (!roomDoc.exists) {
        // print('ChatService: Chat room not found');
        return;
      }

      ChatRoomModel room = ChatRoomModel.fromMap(
        roomDoc.data() as Map<String, dynamic>,
        roomDoc.id,
      );

      // Increment unread count for receiver
      int newUnreadCountDoctor = room.unreadCountDoctor ?? 0;
      int newUnreadCountPatient = room.unreadCountPatient ?? 0;

      if (receiverId == room.doctorId) {
        newUnreadCountDoctor++;
      } else if (receiverId == room.patientId) {
        newUnreadCountPatient++;
      }

      await _firestore.collection(_chatRoomsCollection).doc(roomId).update({
        'lastMessage': lastMessage,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'lastSenderId': senderId,
        'unreadCountDoctor': newUnreadCountDoctor,
        'unreadCountPatient': newUnreadCountPatient,
      });

      // print('ChatService: Last message updated');
    } catch (e) {
      // print('ChatService: Error updating last message: $e');
      rethrow;
    }
  }

  // Mark messages as read
  Future<void> markMessagesAsRead(String roomId, String userId) async {
    try {
      // print('ChatService: Marking messages as read for room: $roomId, user: $userId');
      
      // Get current chat room
      DocumentSnapshot roomDoc = await _firestore
          .collection(_chatRoomsCollection)
          .doc(roomId)
          .get();
      
      if (!roomDoc.exists) {
        // print('ChatService: Chat room not found');
        return;
      }

      ChatRoomModel room = ChatRoomModel.fromMap(
        roomDoc.data() as Map<String, dynamic>,
        roomDoc.id,
      );

      // Reset unread count for current user
      Map<String, dynamic> updateData = {};
      
      if (userId == room.doctorId) {
        updateData['unreadCountDoctor'] = 0;
      } else if (userId == room.patientId) {
        updateData['unreadCountPatient'] = 0;
      }

      if (updateData.isNotEmpty) {
        await _firestore
            .collection(_chatRoomsCollection)
            .doc(roomId)
            .update(updateData);
        
        // print('ChatService: Messages marked as read');
      }
    } catch (e) {
      // print('ChatService: Error marking messages as read: $e');
      rethrow;
    }
  }

  // Get total unread count for a user
  Future<int> getTotalUnreadCount(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_chatRoomsCollection)
          .where(Filter.or(
            Filter('doctorId', isEqualTo: userId),
            Filter('patientId', isEqualTo: userId),
          ))
          .get();

      int totalUnread = 0;
      for (var doc in snapshot.docs) {
        ChatRoomModel room = ChatRoomModel.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
        totalUnread += room.getUnreadCount(userId);
      }

      return totalUnread;
    } catch (e) {
      // print('ChatService: Error getting total unread count: $e');
      return 0;
    }
  }

  // UPDATE USER PRESENCE
  Future<void> updateUserStatus(String userId, bool isOnline) async {
    try {
      // print('ChatService: Updating user $userId status to $isOnline');
      await _firestore.collection('users').doc(userId).update({
        'isOnline': isOnline,
        'lastSeen': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // print('ChatService: Error updating user status: $e');
    }
  }

  // GET USER PRESENCE (Stream)
  Stream<Map<String, dynamic>?> getUserPresence(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((doc) => doc.data());
  }

  // DELETE MESSAGE
  Future<void> deleteMessage(String roomId, String messageId) async {
    try {
      // print('ChatService: Deleting message $messageId in room $roomId');
      await _firestore
          .collection(_chatRoomsCollection)
          .doc(roomId)
          .collection(_messagesCollection)
          .doc(messageId)
          .delete();
    } catch (e) {
      // print('ChatService: Error deleting message: $e');
      rethrow;
    }
  }

  // EDIT MESSAGE
  Future<void> editMessage(String roomId, String messageId, String newContent) async {
    try {
      // print('ChatService: Editing message $messageId in room $roomId');
      await _firestore
          .collection(_chatRoomsCollection)
          .doc(roomId)
          .collection(_messagesCollection)
          .doc(messageId)
          .update({
        'content': newContent,
        'isEdited': true, // We might need to add this field to MessageModel later
        'editedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // print('ChatService: Error editing message: $e');
      rethrow;
    }
  }
}
