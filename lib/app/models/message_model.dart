// lib/app/models/message_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  String? id;
  String? senderId;
  String? senderName;
  String? content;
  DateTime? timestamp;
  bool? isRead;
  String? messageType; // 'text', 'image' (for future expansion)
  bool? isEdited;
  DateTime? editedAt;

  MessageModel({
    this.id,
    this.senderId,
    this.senderName,
    this.content,
    this.timestamp,
    this.isRead,
    this.messageType,
    this.isEdited,
    this.editedAt,
  });

  factory MessageModel.fromMap(Map<String, dynamic> map, String documentId) {
    return MessageModel(
      id: documentId,
      senderId: map['senderId'],
      senderName: map['senderName'],
      content: map['content'],
      timestamp: map['timestamp'] != null
          ? (map['timestamp'] as Timestamp).toDate()
          : null,
      isRead: map['isRead'] ?? false,
      messageType: map['messageType'] ?? 'text',
      isEdited: map['isEdited'] ?? false,
      editedAt: map['editedAt'] != null
          ? (map['editedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderName': senderName,
      'content': content,
      'timestamp': timestamp != null
          ? Timestamp.fromDate(timestamp!)
          : FieldValue.serverTimestamp(),
      'isRead': isRead ?? false,
      'messageType': messageType ?? 'text',
      'isEdited': isEdited ?? false,
      'editedAt': editedAt != null ? Timestamp.fromDate(editedAt!) : null,
    };
  }

  MessageModel copyWith({
    String? id,
    String? senderId,
    String? senderName,
    String? content,
    DateTime? timestamp,
    bool? isRead,
    String? messageType,
    bool? isEdited,
    DateTime? editedAt,
  }) {
    return MessageModel(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      messageType: messageType ?? this.messageType,
      isEdited: isEdited ?? this.isEdited,
      editedAt: editedAt ?? this.editedAt,
    );
  }
}
