// lib/app/models/doctor_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorModel {
  String? id;
  String? uid; // Firebase user ID if doctor has an account
  String? fullName;
  String? email;
  String? specialty;
  String? qualifications;
  String? experience; // e.g., "10 years"
  double? consultationFee;
  String? profileImageUrl;
  double? rating;
  int? totalReviews;
  String? phoneNumber;
  String? about;
  List<String>? availableDays; // ["Monday", "Tuesday", ...]
  String? availableTime; // e.g., "9:00 AM - 5:00 PM"
  bool? isAvailable;
  DateTime? createdAt;

  DoctorModel({
    this.id,
    this.uid,
    this.fullName,
    this.email,
    this.specialty,
    this.qualifications,
    this.experience,
    this.consultationFee,
    this.profileImageUrl,
    this.rating,
    this.totalReviews,
    this.phoneNumber,
    this.about,
    this.availableDays,
    this.availableTime,
    this.isAvailable,
    this.createdAt,
  });

  factory DoctorModel.fromMap(Map<String, dynamic> map, String documentId) {
    return DoctorModel(
      id: documentId,
      uid: map['uid'],
      fullName: map['fullName'],
      email: map['email'],
      specialty: map['specialty'],
      qualifications: map['qualifications'],
      experience: map['experience'],
      consultationFee: map['consultationFee']?.toDouble(),
      profileImageUrl: map['profileImageUrl'],
      rating: map['rating']?.toDouble(),
      totalReviews: map['totalReviews'],
      phoneNumber: map['phoneNumber'],
      about: map['about'],
      availableDays: map['availableDays'] != null
          ? List<String>.from(map['availableDays'])
          : null,
      availableTime: map['availableTime'],
      isAvailable: map['isAvailable'] ?? true,
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'specialty': specialty,
      'qualifications': qualifications,
      'experience': experience,
      'consultationFee': consultationFee,
      'profileImageUrl': profileImageUrl,
      'rating': rating,
      'totalReviews': totalReviews,
      'phoneNumber': phoneNumber,
      'about': about,
      'availableDays': availableDays,
      'availableTime': availableTime,
      'isAvailable': isAvailable,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }

  DoctorModel copyWith({
    String? id,
    String? uid,
    String? fullName,
    String? email,
    String? specialty,
    String? qualifications,
    String? experience,
    double? consultationFee,
    String? profileImageUrl,
    double? rating,
    int? totalReviews,
    String? phoneNumber,
    String? about,
    List<String>? availableDays,
    String? availableTime,
    bool? isAvailable,
    DateTime? createdAt,
  }) {
    return DoctorModel(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      specialty: specialty ?? this.specialty,
      qualifications: qualifications ?? this.qualifications,
      experience: experience ?? this.experience,
      consultationFee: consultationFee ?? this.consultationFee,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      rating: rating ?? this.rating,
      totalReviews: totalReviews ?? this.totalReviews,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      about: about ?? this.about,
      availableDays: availableDays ?? this.availableDays,
      availableTime: availableTime ?? this.availableTime,
      isAvailable: isAvailable ?? this.isAvailable,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
