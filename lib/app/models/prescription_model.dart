// lib/app/models/prescription_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'medication_model.dart';

class PrescriptionModel {
  String? id;
  String? appointmentId;
  String? doctorId;
  String? doctorName;
  String? doctorSpecialty;
  String? doctorLicense;
  String? patientId;
  String? patientName;
  int? patientAge;
  DateTime? prescribedDate;
  DateTime? expiryDate;
  String? diagnosis;
  String? symptoms;
  List<MedicationModel>? medications;
  String? generalInstructions;
  String? additionalNotes;
  bool? followUpRequired;
  DateTime? followUpDate;
  String? followUpType; // in-person, video
  String? status; // active, expired, completed
  DateTime? createdAt;
  DateTime? updatedAt;

  PrescriptionModel({
    this.id,
    this.appointmentId,
    this.doctorId,
    this.doctorName,
    this.doctorSpecialty,
    this.doctorLicense,
    this.patientId,
    this.patientName,
    this.patientAge,
    this.prescribedDate,
    this.expiryDate,
    this.diagnosis,
    this.symptoms,
    this.medications,
    this.generalInstructions,
    this.additionalNotes,
    this.followUpRequired,
    this.followUpDate,
    this.followUpType,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  // From JSON
  factory PrescriptionModel.fromJson(Map<String, dynamic> json) {
    return PrescriptionModel(
      id: json['id'] as String?,
      appointmentId: json['appointmentId'] as String?,
      doctorId: json['doctorId'] as String?,
      doctorName: json['doctorName'] as String?,
      doctorSpecialty: json['doctorSpecialty'] as String?,
      doctorLicense: json['doctorLicense'] as String?,
      patientId: json['patientId'] as String?,
      patientName: json['patientName'] as String?,
      patientAge: json['patientAge'] as int?,
      prescribedDate: json['prescribedDate'] != null
          ? (json['prescribedDate'] as Timestamp).toDate()
          : null,
      expiryDate: json['expiryDate'] != null
          ? (json['expiryDate'] as Timestamp).toDate()
          : null,
      diagnosis: json['diagnosis'] as String?,
      symptoms: json['symptoms'] as String?,
      medications: json['medications'] != null
          ? (json['medications'] as List)
              .map((med) => MedicationModel.fromJson(med as Map<String, dynamic>))
              .toList()
          : null,
      generalInstructions: json['generalInstructions'] as String?,
      additionalNotes: json['additionalNotes'] as String?,
      followUpRequired: json['followUpRequired'] as bool?,
      followUpDate: json['followUpDate'] != null
          ? (json['followUpDate'] as Timestamp).toDate()
          : null,
      followUpType: json['followUpType'] as String?,
      status: json['status'] as String?,
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] as Timestamp).toDate()
          : null,
      updatedAt: json['updatedAt'] != null
          ? (json['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'appointmentId': appointmentId,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'doctorSpecialty': doctorSpecialty,
      'doctorLicense': doctorLicense,
      'patientId': patientId,
      'patientName': patientName,
      'patientAge': patientAge,
      'prescribedDate': prescribedDate != null ? Timestamp.fromDate(prescribedDate!) : null,
      'expiryDate': expiryDate != null ? Timestamp.fromDate(expiryDate!) : null,
      'diagnosis': diagnosis,
      'symptoms': symptoms,
      'medications': medications?.map((med) => med.toJson()).toList(),
      'generalInstructions': generalInstructions,
      'additionalNotes': additionalNotes,
      'followUpRequired': followUpRequired,
      'followUpDate': followUpDate != null ? Timestamp.fromDate(followUpDate!) : null,
      'followUpType': followUpType,
      'status': status,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  // Copy with
  PrescriptionModel copyWith({
    String? id,
    String? appointmentId,
    String? doctorId,
    String? doctorName,
    String? doctorSpecialty,
    String? doctorLicense,
    String? patientId,
    String? patientName,
    int? patientAge,
    DateTime? prescribedDate,
    DateTime? expiryDate,
    String? diagnosis,
    String? symptoms,
    List<MedicationModel>? medications,
    String? generalInstructions,
    String? additionalNotes,
    bool? followUpRequired,
    DateTime? followUpDate,
    String? followUpType,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PrescriptionModel(
      id: id ?? this.id,
      appointmentId: appointmentId ?? this.appointmentId,
      doctorId: doctorId ?? this.doctorId,
      doctorName: doctorName ?? this.doctorName,
      doctorSpecialty: doctorSpecialty ?? this.doctorSpecialty,
      doctorLicense: doctorLicense ?? this.doctorLicense,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      patientAge: patientAge ?? this.patientAge,
      prescribedDate: prescribedDate ?? this.prescribedDate,
      expiryDate: expiryDate ?? this.expiryDate,
      diagnosis: diagnosis ?? this.diagnosis,
      symptoms: symptoms ?? this.symptoms,
      medications: medications ?? this.medications,
      generalInstructions: generalInstructions ?? this.generalInstructions,
      additionalNotes: additionalNotes ?? this.additionalNotes,
      followUpRequired: followUpRequired ?? this.followUpRequired,
      followUpDate: followUpDate ?? this.followUpDate,
      followUpType: followUpType ?? this.followUpType,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper: Check if prescription is active
  bool get isActive {
    if (expiryDate == null) return false;
    return DateTime.now().isBefore(expiryDate!) && status == 'active';
  }

  // Helper: Check if prescription is expired
  bool get isExpired {
    if (expiryDate == null) return false;
    return DateTime.now().isAfter(expiryDate!) || status == 'expired';
  }

  // Helper: Get medication count
  int get medicationCount => medications?.length ?? 0;
}
