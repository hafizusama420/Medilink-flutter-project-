import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String? uid;
  String? email;
  String? role;
  String? fullName;
  String? gender;
  String? phoneNumber;
  String? profileImageUrl;
  
  // Doctor-specific fields (only used when role == "Doctor")
  String? specialty;
  String? qualifications;
  String? experience;
  double? consultationFee;
  List<String>? availableDays;
  String? availableTime;
  String? about;
  double? rating;
  int? totalReviews;
  bool? isOnline;
  DateTime? lastSeen;

  UserModel({
    this.uid,
    this.email,
    this.role,
    this.fullName,
    this.gender,
    this.phoneNumber,
    this.profileImageUrl,
    this.specialty,
    this.qualifications,
    this.experience,
    this.consultationFee,
    this.availableDays,
    this.availableTime,
    this.about,
    this.rating,
    this.totalReviews,
    this.isOnline,
    this.lastSeen,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, [String? documentId]) {
    return UserModel(
      uid: documentId ?? map['uid'],
      email: map['email'],
      role: map['role'],
      fullName: map['fullName'],
      gender: map['gender'],
      phoneNumber: map['phoneNumber'],
      profileImageUrl: map['profileImageUrl'],
      specialty: map['specialty'],
      qualifications: map['qualifications'],
      experience: map['experience'],
      consultationFee: map['consultationFee']?.toDouble(),
      availableDays: map['availableDays'] != null
          ? List<String>.from(map['availableDays'])
          : null,
      availableTime: map['availableTime'],
      about: map['about'],
      rating: map['rating']?.toDouble(),
      totalReviews: map['totalReviews'],
      isOnline: map['isOnline'],
      lastSeen: map['lastSeen'] != null
          ? (map['lastSeen'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'role': role,
      'fullName': fullName,
      'gender': gender,
      'phoneNumber': phoneNumber,
      'profileImageUrl': profileImageUrl,
      'specialty': specialty,
      'qualifications': qualifications,
      'experience': experience,
      'consultationFee': consultationFee,
      'availableDays': availableDays,
      'availableTime': availableTime,
      'about': about,
      'rating': rating ?? 0.0,
      'totalReviews': totalReviews ?? 0,
      'isOnline': isOnline,
      'lastSeen': lastSeen != null ? Timestamp.fromDate(lastSeen!) : null,
    };
  }
}
