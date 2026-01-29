// lib/app/models/appointment_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentModel {
  String? id;
  String? userId;
  String? patientName; // Added for doctor-side view
  String? doctorUid; // Added UID for doctor-side filtering
  String? doctorName;
  String? doctorSpecialty;
  DateTime? appointmentDate;
  String? reason;
  String? status; // pending, confirmed, completed, cancelled
  DateTime? createdAt;
  String? fcmToken; // FCM token for sending scheduled notifications
  bool? notificationScheduled; // Track if Cloud Function sent notification
  String? cancellationReason; // Why the appointment was cancelled
  String? cancelledBy; // 'Doctor' or 'Patient'

  AppointmentModel({
    this.id,
    this.userId,
    this.patientName,
    this.doctorUid,
    this.doctorName,
    this.doctorSpecialty,
    this.appointmentDate,
    this.reason,
    this.status,
    this.createdAt,
    this.fcmToken,
    this.notificationScheduled,
    this.cancellationReason,
    this.cancelledBy,
  });

  factory AppointmentModel.fromMap(Map<String, dynamic> map, String documentId) {
    return AppointmentModel(
      id: documentId,
      userId: map['userId'],
      patientName: map['patientName'],
      doctorUid: map['doctorUid'],
      doctorName: map['doctorName'],
      doctorSpecialty: map['doctorSpecialty'],
      appointmentDate: map['appointmentDate'] != null
          ? (map['appointmentDate'] as Timestamp).toDate()
          : null,
      reason: map['reason'],
      status: map['status'],
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : null,
      fcmToken: map['fcmToken'],
      notificationScheduled: map['notificationScheduled'] ?? false,
      cancellationReason: map['cancellationReason'],
      cancelledBy: map['cancelledBy'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'patientName': patientName,
      'doctorUid': doctorUid,
      'doctorName': doctorName,
      'doctorSpecialty': doctorSpecialty,
      'appointmentDate': appointmentDate != null
          ? Timestamp.fromDate(appointmentDate!)
          : null,
      'reason': reason,
      'status': status,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'fcmToken': fcmToken,
      'notificationScheduled': notificationScheduled ?? false,
      'cancellationReason': cancellationReason,
      'cancelledBy': cancelledBy,
    };
  }

  AppointmentModel copyWith({
    String? id,
    String? userId,
    String? patientName,
    String? doctorUid,
    String? doctorName,
    String? doctorSpecialty,
    DateTime? appointmentDate,
    String? reason,
    String? status,
    DateTime? createdAt,
    String? fcmToken,
    bool? notificationScheduled,
    String? cancellationReason,
    String? cancelledBy,
  }) {
    return AppointmentModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      patientName: patientName ?? this.patientName,
      doctorUid: doctorUid ?? this.doctorUid,
      doctorName: doctorName ?? this.doctorName,
      doctorSpecialty: doctorSpecialty ?? this.doctorSpecialty,
      appointmentDate: appointmentDate ?? this.appointmentDate,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      fcmToken: fcmToken ?? this.fcmToken,
      notificationScheduled: notificationScheduled ?? this.notificationScheduled,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      cancelledBy: cancelledBy ?? this.cancelledBy,
    );
  }

  /// Helper to check if appointment is logically completed or cancelled
  bool get isFinalized {
    final s = status?.toLowerCase();
    return s == 'completed' || s == 'cancelled';
  }

  /// Helper to check if an appointment is past its scheduled time
  /// We now use a tight 1-minute grace period to ensure the UI feels responsive
  bool isPastDue([DateTime? relativeTo]) {
    if (appointmentDate == null || isFinalized) return false;
    final now = relativeTo ?? DateTime.now();
    // Grace period of 1 minute (allows for minor sync drifts)
    return now.isAfter(appointmentDate!.add(const Duration(minutes: 1)));
  }

  /// Helper for background auto-completion in the database
  /// Sync with DB also happens after 1 minute for a consistent experience
  bool isStaleForAutoCompletion([DateTime? relativeTo]) {
    if (appointmentDate == null || isFinalized) return false;
    final now = relativeTo ?? DateTime.now();
    return now.isAfter(appointmentDate!.add(const Duration(minutes: 1)));
  }

  /// The effective status to show in UI
  String get effectiveStatus {
    if (status?.toLowerCase() == 'completed' || isPastDue()) return 'completed';
    return (status ?? 'pending').toLowerCase();
  }
}
