// lib/app/models/assignment_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class AssignmentModel {
  String? id;
  String? patientId;
  String? patientName;
  String? doctorId;
  String? doctorName;
  String? appointmentId; // Optional link to appointment
  String? title;
  String? description;
  String? category; // Exercise, Medication, Lifestyle, Monitoring, Follow-up
  String? priority; // Low, Medium, High
  String? frequency; // Daily, Weekly, As Needed, One-time
  DateTime? startDate;
  DateTime? dueDate;
  String? status; // Pending, In Progress, Completed, Overdue
  DateTime? completedDate;
  String? notes; // Patient notes
  DateTime? createdAt;
  DateTime? updatedAt;

  AssignmentModel({
    this.id,
    this.patientId,
    this.patientName,
    this.doctorId,
    this.doctorName,
    this.appointmentId,
    this.title,
    this.description,
    this.category,
    this.priority,
    this.frequency,
    this.startDate,
    this.dueDate,
    this.status,
    this.completedDate,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  // From JSON
  factory AssignmentModel.fromJson(Map<String, dynamic> json) {
    return AssignmentModel(
      id: json['id'] as String?,
      patientId: json['patientId'] as String?,
      patientName: json['patientName'] as String?,
      doctorId: json['doctorId'] as String?,
      doctorName: json['doctorName'] as String?,
      appointmentId: json['appointmentId'] as String?,
      title: json['title'] as String?,
      description: json['description'] as String?,
      category: json['category'] as String?,
      priority: json['priority'] as String?,
      frequency: json['frequency'] as String?,
      startDate: json['startDate'] != null
          ? (json['startDate'] as Timestamp).toDate()
          : null,
      dueDate: json['dueDate'] != null
          ? (json['dueDate'] as Timestamp).toDate()
          : null,
      status: json['status'] as String?,
      completedDate: json['completedDate'] != null
          ? (json['completedDate'] as Timestamp).toDate()
          : null,
      notes: json['notes'] as String?,
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
      'patientId': patientId,
      'patientName': patientName,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'appointmentId': appointmentId,
      'title': title,
      'description': description,
      'category': category,
      'priority': priority,
      'frequency': frequency,
      'startDate': startDate != null ? Timestamp.fromDate(startDate!) : null,
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
      'status': status,
      'completedDate': completedDate != null ? Timestamp.fromDate(completedDate!) : null,
      'notes': notes,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  // Copy with
  AssignmentModel copyWith({
    String? id,
    String? patientId,
    String? patientName,
    String? doctorId,
    String? doctorName,
    String? appointmentId,
    String? title,
    String? description,
    String? category,
    String? priority,
    String? frequency,
    DateTime? startDate,
    DateTime? dueDate,
    String? status,
    DateTime? completedDate,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AssignmentModel(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      doctorId: doctorId ?? this.doctorId,
      doctorName: doctorName ?? this.doctorName,
      appointmentId: appointmentId ?? this.appointmentId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      frequency: frequency ?? this.frequency,
      startDate: startDate ?? this.startDate,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      completedDate: completedDate ?? this.completedDate,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper: Check if assignment is overdue
  bool get isOverdue {
    if (dueDate == null || status == 'Completed') return false;
    return DateTime.now().isAfter(dueDate!);
  }

  // Helper: Check if assignment is completed
  bool get isCompleted => status == 'Completed';

  // Helper: Check if assignment is pending
  bool get isPending => status == 'Pending' || status == 'In Progress';

  // Helper: Get days until due
  int? get daysUntilDue {
    if (dueDate == null) return null;
    return dueDate!.difference(DateTime.now()).inDays;
  }

  // Helper: Get effective status (auto-update to overdue if needed)
  String get effectiveStatus {
    if (isOverdue && status != 'Completed') return 'Overdue';
    return status ?? 'Pending';
  }
}
