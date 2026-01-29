// lib/app/models/chat_room_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRoomModel {
  String? id;
  String? doctorId;
  String? patientId;
  String? doctorName;
  String? patientName;
  String? doctorProfileImage;
  String? patientProfileImage;
  String? lastMessage;
  DateTime? lastMessageTime;
  int? unreadCountDoctor;
  int? unreadCountPatient;
  String? lastSenderId; // To know who sent the last message
  DateTime? createdAt;

  ChatRoomModel({
    this.id,
    this.doctorId,
    this.patientId,
    this.doctorName,
    this.patientName,
    this.doctorProfileImage,
    this.patientProfileImage,
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCountDoctor,
    this.unreadCountPatient,
    this.lastSenderId,
    this.createdAt,
  });

  factory ChatRoomModel.fromMap(Map<String, dynamic> map, String documentId) {
    return ChatRoomModel(
      id: documentId,
      doctorId: map['doctorId'],
      patientId: map['patientId'],
      doctorName: map['doctorName'],
      patientName: map['patientName'],
      doctorProfileImage: map['doctorProfileImage'],
      patientProfileImage: map['patientProfileImage'],
      lastMessage: map['lastMessage'],
      lastMessageTime: map['lastMessageTime'] != null
          ? (map['lastMessageTime'] as Timestamp).toDate()
          : null,
      unreadCountDoctor: map['unreadCountDoctor'] ?? 0,
      unreadCountPatient: map['unreadCountPatient'] ?? 0,
      lastSenderId: map['lastSenderId'],
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'doctorId': doctorId,
      'patientId': patientId,
      'doctorName': doctorName,
      'patientName': patientName,
      'doctorProfileImage': doctorProfileImage,
      'patientProfileImage': patientProfileImage,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime != null
          ? Timestamp.fromDate(lastMessageTime!)
          : null,
      'unreadCountDoctor': unreadCountDoctor ?? 0,
      'unreadCountPatient': unreadCountPatient ?? 0,
      'lastSenderId': lastSenderId,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }

  ChatRoomModel copyWith({
    String? id,
    String? doctorId,
    String? patientId,
    String? doctorName,
    String? patientName,
    String? doctorProfileImage,
    String? patientProfileImage,
    String? lastMessage,
    DateTime? lastMessageTime,
    int? unreadCountDoctor,
    int? unreadCountPatient,
    String? lastSenderId,
    DateTime? createdAt,
  }) {
    return ChatRoomModel(
      id: id ?? this.id,
      doctorId: doctorId ?? this.doctorId,
      patientId: patientId ?? this.patientId,
      doctorName: doctorName ?? this.doctorName,
      patientName: patientName ?? this.patientName,
      doctorProfileImage: doctorProfileImage ?? this.doctorProfileImage,
      patientProfileImage: patientProfileImage ?? this.patientProfileImage,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCountDoctor: unreadCountDoctor ?? this.unreadCountDoctor,
      unreadCountPatient: unreadCountPatient ?? this.unreadCountPatient,
      lastSenderId: lastSenderId ?? this.lastSenderId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Helper method to get unread count for a specific user
  int getUnreadCount(String userId) {
    if (userId == doctorId) {
      return unreadCountDoctor ?? 0;
    } else if (userId == patientId) {
      return unreadCountPatient ?? 0;
    }
    return 0;
  }

  // Helper method to get the other participant's name
  String getOtherParticipantName(String currentUserId) {
    if (currentUserId == doctorId) {
      return patientName ?? 'Patient';
    } else {
      return doctorName ?? 'Doctor';
    }
  }

  // Helper method to get the other participant's profile image
  String? getOtherParticipantImage(String currentUserId) {
    if (currentUserId == doctorId) {
      return patientProfileImage;
    } else {
      return doctorProfileImage;
    }
  }
}
