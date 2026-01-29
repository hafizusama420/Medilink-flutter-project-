// lib/app/models/review_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  String? id;
  String? appointmentId;
  String? doctorId;
  String? patientId;
  String? patientName;
  int? rating; // 1-5 stars
  String? comment;
  DateTime? createdAt;
  DateTime? updatedAt;

  ReviewModel({
    this.id,
    this.appointmentId,
    this.doctorId,
    this.patientId,
    this.patientName,
    this.rating,
    this.comment,
    this.createdAt,
    this.updatedAt,
  });

  factory ReviewModel.fromMap(Map<String, dynamic> map, String documentId) {
    return ReviewModel(
      id: documentId,
      appointmentId: map['appointmentId'],
      doctorId: map['doctorId'],
      patientId: map['patientId'],
      patientName: map['patientName'],
      rating: map['rating'],
      comment: map['comment'],
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : null,
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'appointmentId': appointmentId,
      'doctorId': doctorId,
      'patientId': patientId,
      'patientName': patientName,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'updatedAt': updatedAt != null
          ? Timestamp.fromDate(updatedAt!)
          : FieldValue.serverTimestamp(),
    };
  }

  ReviewModel copyWith({
    String? id,
    String? appointmentId,
    String? doctorId,
    String? patientId,
    String? patientName,
    int? rating,
    String? comment,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ReviewModel(
      id: id ?? this.id,
      appointmentId: appointmentId ?? this.appointmentId,
      doctorId: doctorId ?? this.doctorId,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
