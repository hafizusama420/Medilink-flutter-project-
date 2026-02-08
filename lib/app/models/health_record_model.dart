// lib/app/models/health_record_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

enum HealthRecordType {
  bmi,
  bloodPressure,
  sugarLevel,
  bodyTemperature,
  oxygenSaturation,
  hemoglobin,
  weight,
}

class HealthRecord {
  final String? id;
  final String userId;
  final String? recordedBy;
  final String? recordedByName;
  final HealthRecordType type;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  final String? notes;

  HealthRecord({
    this.id,
    required this.userId,
    this.recordedBy,
    this.recordedByName,
    required this.type,
    required this.data,
    required this.timestamp,
    this.notes,
  });

  factory HealthRecord.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return HealthRecord(
      id: doc.id,
      userId: data['userId'] ?? '',
      recordedBy: data['recordedBy'],
      recordedByName: data['recordedByName'],
      type: HealthRecordType.values.firstWhere(
        (e) => e.toString().split('.').last == data['type'],
        orElse: () => HealthRecordType.weight,
      ),
      data: data['data'] ?? {},
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      notes: data['notes'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'recordedBy': recordedBy,
      'recordedByName': recordedByName,
      'type': type.toString().split('.').last,
      'data': data,
      'timestamp': Timestamp.fromDate(timestamp),
      'notes': notes,
    };
  }

  // Helper getters for specific types
  double? get bmiValue => type == HealthRecordType.bmi ? data['bmi']?.toDouble() : null;
  String? get bmiCategory => type == HealthRecordType.bmi ? data['category'] : null;
  
  String? get bpSystolic => type == HealthRecordType.bloodPressure ? data['systolic'].toString() : null;
  String? get bpDiastolic => type == HealthRecordType.bloodPressure ? data['diastolic'].toString() : null;
  
  double? get sugarValue => type == HealthRecordType.sugarLevel ? data['value']?.toDouble() : null;
  String? get sugarContext => type == HealthRecordType.sugarLevel ? data['context'] : null;
  
  double? get temperature => type == HealthRecordType.bodyTemperature ? data['value']?.toDouble() : null;
  double? get oxygen => type == HealthRecordType.oxygenSaturation ? data['value']?.toDouble() : null;
  double? get hemoglobin => type == HealthRecordType.hemoglobin ? data['value']?.toDouble() : null;
  double? get weight => type == HealthRecordType.weight || type == HealthRecordType.bmi ? data['weight']?.toDouble() : null;
}
