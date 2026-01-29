// lib/app/data/services/appointment_service.dart
// Service class for managing appointment data in Firestore
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/appointment_model.dart';

/// AppointmentService handles all Firestore operations for appointments
/// Provides CRUD operations and real-time streaming of appointment data
class AppointmentService {
  // Firestore instance for database operations
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Collection name where appointments are stored
  final String _collectionName = 'appointments';

  /// Creates a new appointment in Firestore
  /// 
  /// Parameters:
  ///   - appointment: AppointmentModel containing all appointment details
  /// 
  /// Returns:
  ///   - String: Document ID of the created appointment
  /// 
  /// Throws:
  ///   - Exception if creation fails
  Future<String> createAppointment(AppointmentModel appointment) async {
    try {
      // Add appointment document to Firestore collection


      final docRef = await _firestore
          .collection(_collectionName)
          .add(appointment.toMap());



      // Return the auto-generated document ID
      return docRef.id;
    } on FirebaseException catch (e) {
      // Handle Firestore-specific errors
      throw Exception('Failed to create appointment: ${e.message}');
    } catch (e) {
      // Handle any other unexpected errors
      throw Exception('An unexpected error occurred while creating appointment: $e');
    }
  }

  /// Gets all appointments for a user as a real-time stream
  Stream<List<AppointmentModel>> getAppointmentsStream(String userId) {
    return _firestore
        .collection(_collectionName)
        .where('userId', isEqualTo: userId)  // Filter by user ID
        .snapshots()                          // Listen for real-time updates
        .map((snapshot) {
          // Convert Firestore documents to AppointmentModel objects
          final appointments = snapshot.docs
              .map((doc) => AppointmentModel.fromMap(doc.data(), doc.id))
              .toList();
          
          return appointments;
        });
  }

  /// Gets all appointments for a doctor as a real-time stream
  Stream<List<AppointmentModel>> getDoctorAppointmentsStream(String doctorId) {
    return _firestore
        .collection(_collectionName)
        .where('doctorUid', isEqualTo: doctorId)
        .snapshots()
        .map((snapshot) {
          final appointments = snapshot.docs
              .map((doc) => AppointmentModel.fromMap(doc.data(), doc.id))
              .toList();
          
          return appointments;
        });
  }

  /// Gets all appointments for a user (one-time fetch)
  /// 
  /// Parameters:
  ///   - userId: Firebase Auth user ID
  /// 
  /// Returns:
  ///   - List of AppointmentModel objects sorted by date
  /// 
  /// Throws:
  ///   - Exception if fetch fails
  Future<List<AppointmentModel>> getAppointments(String userId) async {
    try {
      // Query appointments for specific user
      final snapshot = await _firestore
          .collection(_collectionName)
          .where('userId', isEqualTo: userId)
          .get();
      
      // Convert Firestore documents to AppointmentModel objects
      final appointments = snapshot.docs
          .map((doc) => AppointmentModel.fromMap(doc.data(), doc.id))
          .toList();
      
      // Sort by appointment date (ascending)
      appointments.sort((a, b) {
        if (a.appointmentDate == null && b.appointmentDate == null) return 0;
        if (a.appointmentDate == null) return 1;
        if (b.appointmentDate == null) return -1;
        return a.appointmentDate!.compareTo(b.appointmentDate!);
      });
      
      return appointments;
    } on FirebaseException catch (e) {
      // Handle Firestore-specific errors
      throw Exception('Failed to get appointments: ${e.message}');
    } catch (e) {
      // Handle any other unexpected errors
      throw Exception('An unexpected error occurred while fetching appointments: $e');
    }
  }

  /// Gets a single appointment by its document ID
  /// 
  /// Parameters:
  ///   - appointmentId: Firestore document ID
  /// 
  /// Returns:
  ///   - AppointmentModel if found
  ///   - null if not found
  /// 
  /// Throws:
  ///   - Exception if fetch fails
  Future<AppointmentModel?> getAppointmentById(String appointmentId) async {
    try {
      // Fetch specific appointment document
      final doc = await _firestore
          .collection(_collectionName)
          .doc(appointmentId)
          .get();
      
      // Check if document exists and has data
      if (doc.exists && doc.data() != null) {
        return AppointmentModel.fromMap(doc.data()!, doc.id);
      }
      
      return null;
    } on FirebaseException catch (e) {
      // Handle Firestore-specific errors
      throw Exception('Failed to get appointment: ${e.message}');
    } catch (e) {
      // Handle any other unexpected errors
      throw Exception('An unexpected error occurred while fetching appointment: $e');
    }
  }

  /// Updates an existing appointment with new data
  /// 
  /// Parameters:
  ///   - appointmentId: Firestore document ID
  ///   - updates: Map of field names and new values
  /// 
  /// Throws:
  ///   - Exception if update fails
  Future<void> updateAppointment(String appointmentId, Map<String, dynamic> updates) async {
    try {
      // Convert DateTime to Firestore Timestamp if present
      if (updates.containsKey('appointmentDate') && updates['appointmentDate'] is DateTime) {
        updates['appointmentDate'] = Timestamp.fromDate(updates['appointmentDate']);
      }
      
      // Update appointment document in Firestore
      await _firestore
          .collection(_collectionName)
          .doc(appointmentId)
          .update(updates);
    } on FirebaseException catch (e) {
      // Handle Firestore-specific errors
      throw Exception('Failed to update appointment: ${e.message}');
    } catch (e) {
      // Handle any other unexpected errors
      throw Exception('An unexpected error occurred while updating appointment: $e');
    }
  }

  /// Deletes an appointment from Firestore
  /// 
  /// Parameters:
  ///   - appointmentId: Firestore document ID
  /// 
  /// Throws:
  ///   - Exception if deletion fails
  Future<void> deleteAppointment(String appointmentId) async {
    try {
      // Delete appointment document from Firestore
      await _firestore
          .collection(_collectionName)
          .doc(appointmentId)
          .delete();
    } on FirebaseException catch (e) {
      // Handle Firestore-specific errors
      throw Exception('Failed to delete appointment: ${e.message}');
    } catch (e) {
      // Handle any other unexpected errors
      throw Exception('An unexpected error occurred while deleting appointment: $e');
    }
  }
}
