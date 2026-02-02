// lib/app/services/assignment_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/assignment_model.dart';

class AssignmentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'assignments';

  /// Create a new assignment
  Future<String> createAssignment(AssignmentModel assignment) async {
    try {
      final docRef = _firestore.collection(_collection).doc();
      final newAssignment = assignment.copyWith(
        id: docRef.id,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        status: assignment.status ?? 'Pending',
      );
      
      await docRef.set(newAssignment.toJson());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create assignment: $e');
    }
  }

  /// Get assignment by ID
  Future<AssignmentModel?> getAssignmentById(String assignmentId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(assignmentId).get();
      if (doc.exists) {
        return AssignmentModel.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get assignment: $e');
    }
  }

  /// Get assignment by ID as stream (real-time updates)
  Stream<AssignmentModel?> getAssignmentStream(String assignmentId) {
    return _firestore
        .collection(_collection)
        .doc(assignmentId)
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        return AssignmentModel.fromJson(doc.data()!);
      }
      return null;
    });
  }

  /// Get all assignments for a patient
  Stream<List<AssignmentModel>> getPatientAssignments(String patientId) {
    return _firestore
        .collection(_collection)
        .where('patientId', isEqualTo: patientId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => AssignmentModel.fromJson(doc.data()))
          .toList();
    });
  }

  /// Get all assignments created by a doctor
  Stream<List<AssignmentModel>> getDoctorAssignments(String doctorId) {
    return _firestore
        .collection(_collection)
        .where('doctorId', isEqualTo: doctorId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => AssignmentModel.fromJson(doc.data()))
          .toList();
    });
  }

  /// Get assignments by status for a patient
  Stream<List<AssignmentModel>> getAssignmentsByStatus(
    String patientId,
    String status,
  ) {
    return _firestore
        .collection(_collection)
        .where('patientId', isEqualTo: patientId)
        .where('status', isEqualTo: status)
        .orderBy('dueDate', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => AssignmentModel.fromJson(doc.data()))
          .toList();
    });
  }

  /// Get overdue assignments for a patient
  Future<List<AssignmentModel>> getOverdueAssignments(String patientId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('patientId', isEqualTo: patientId)
          .where('status', whereIn: ['Pending', 'In Progress'])
          .where('dueDate', isLessThan: Timestamp.now())
          .get();

      return snapshot.docs
          .map((doc) => AssignmentModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get overdue assignments: $e');
    }
  }

  /// Update assignment
  Future<void> updateAssignment(AssignmentModel assignment) async {
    try {
      if (assignment.id == null) {
        throw Exception('Assignment ID is required for update');
      }

      final updatedAssignment = assignment.copyWith(
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection(_collection)
          .doc(assignment.id)
          .update(updatedAssignment.toJson());
    } catch (e) {
      throw Exception('Failed to update assignment: $e');
    }
  }

  /// Mark assignment as complete
  Future<void> markAsComplete(String assignmentId, {String? notes}) async {
    try {
      final updateData = {
        'status': 'Completed',
        'completedDate': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      };

      if (notes != null) {
        updateData['notes'] = notes;
      }

      await _firestore
          .collection(_collection)
          .doc(assignmentId)
          .update(updateData);
    } catch (e) {
      throw Exception('Failed to mark assignment as complete: $e');
    }
  }

  /// Update assignment status
  Future<void> updateAssignmentStatus(String assignmentId, String status) async {
    try {
      await _firestore.collection(_collection).doc(assignmentId).update({
        'status': status,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Failed to update assignment status: $e');
    }
  }

  /// Delete assignment
  Future<void> deleteAssignment(String assignmentId) async {
    try {
      await _firestore.collection(_collection).doc(assignmentId).delete();
    } catch (e) {
      throw Exception('Failed to delete assignment: $e');
    }
  }

  /// Get assignments by category
  Stream<List<AssignmentModel>> getAssignmentsByCategory(
    String patientId,
    String category,
  ) {
    return _firestore
        .collection(_collection)
        .where('patientId', isEqualTo: patientId)
        .where('category', isEqualTo: category)
        .orderBy('dueDate', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => AssignmentModel.fromJson(doc.data()))
          .toList();
    });
  }

  /// Search assignments by title
  Future<List<AssignmentModel>> searchAssignments(
    String patientId,
    String query,
  ) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('patientId', isEqualTo: patientId)
          .get();

      return snapshot.docs
          .map((doc) => AssignmentModel.fromJson(doc.data()))
          .where((assignment) =>
              assignment.title?.toLowerCase().contains(query.toLowerCase()) ??
              false)
          .toList();
    } catch (e) {
      throw Exception('Failed to search assignments: $e');
    }
  }
}
