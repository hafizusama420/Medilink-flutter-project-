// lib/app/services/health_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/health_record_model.dart';


class HealthService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collection = 'health_records';

  // Add a new health record
  Future<void> addHealthRecord(HealthRecord record) async {
    try {
      Map<String, dynamic> data = record.toFirestore();
      data['timestamp'] = FieldValue.serverTimestamp(); // Use server-side timestamp for accuracy
      await _firestore.collection(collection).add(data);
    } catch (e) {
      throw Exception('Failed to add health record: $e');
    }
  }

  // Get latest record of each type for a user
  Stream<List<HealthRecord>> getLatestHealthRecords(String userId) {
    return _firestore
        .collection(collection)
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      // Create a map to keep only the latest of each type
      Map<HealthRecordType, HealthRecord> latest = {};
      for (var doc in snapshot.docs) {
        final record = HealthRecord.fromFirestore(doc);
        if (!latest.containsKey(record.type)) {
          latest[record.type] = record;
        }
      }
      return latest.values.toList();
    });
  }

  // Get history for a specific metric
  Stream<List<HealthRecord>> getHistory(String userId, HealthRecordType type) {
    return _firestore
        .collection(collection)
        .where('userId', isEqualTo: userId)
        .where('type', isEqualTo: type.toString().split('.').last)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => HealthRecord.fromFirestore(doc)).toList());
  }

  // Delete a record
  Future<void> deleteRecord(String id) async {
    try {
      await _firestore.collection(collection).doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete health record: $e');
    }
  }
}
