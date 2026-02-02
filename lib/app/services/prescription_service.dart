// lib/app/services/prescription_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/prescription_model.dart';
import '../models/medication_model.dart';

class PrescriptionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection reference
  CollectionReference get _prescriptionsCollection =>
      _firestore.collection('prescriptions');

  /// Create a new prescription
  Future<String> createPrescription(PrescriptionModel prescription) async {
    try {
      // Generate ID
      final docRef = _prescriptionsCollection.doc();
      prescription.id = docRef.id;
      prescription.createdAt = DateTime.now();
      prescription.updatedAt = DateTime.now();
      prescription.status = 'active';

      // Save to Firestore
      await docRef.set(prescription.toJson());

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create prescription: $e');
    }
  }

  /// Get prescription by ID
  Future<PrescriptionModel?> getPrescriptionById(String prescriptionId) async {
    try {
      final doc = await _prescriptionsCollection.doc(prescriptionId).get();
      if (doc.exists) {
        return PrescriptionModel.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get prescription: $e');
    }
  }

  /// Get prescription by ID as stream (real-time updates)
  Stream<PrescriptionModel?> getPrescriptionStream(String prescriptionId) {
    return _prescriptionsCollection
        .doc(prescriptionId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists) {
        return PrescriptionModel.fromJson(snapshot.data() as Map<String, dynamic>);
      }
      return null;
    });
  }

  /// Get all prescriptions for a patient
  Stream<List<PrescriptionModel>> getPatientPrescriptions(String patientId) {
    return _prescriptionsCollection
        .where('patientId', isEqualTo: patientId)
        .orderBy('prescribedDate', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => PrescriptionModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  /// Get all prescriptions created by a doctor
  Stream<List<PrescriptionModel>> getDoctorPrescriptions(String doctorId) {
    return _prescriptionsCollection
        .where('doctorId', isEqualTo: doctorId)
        .orderBy('prescribedDate', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => PrescriptionModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  /// Get prescriptions for a specific appointment
  Future<List<PrescriptionModel>> getAppointmentPrescriptions(String appointmentId) async {
    try {
      final snapshot = await _prescriptionsCollection
          .where('appointmentId', isEqualTo: appointmentId)
          .get();

      return snapshot.docs
          .map((doc) => PrescriptionModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get appointment prescriptions: $e');
    }
  }

  /// Get active prescriptions for a patient
  Stream<List<PrescriptionModel>> getActivePrescriptions(String patientId) {
    return _prescriptionsCollection
        .where('patientId', isEqualTo: patientId)
        .where('status', isEqualTo: 'active')
        .orderBy('prescribedDate', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => PrescriptionModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  /// Get expired prescriptions for a patient
  Stream<List<PrescriptionModel>> getExpiredPrescriptions(String patientId) {
    return _prescriptionsCollection
        .where('patientId', isEqualTo: patientId)
        .where('status', isEqualTo: 'expired')
        .orderBy('prescribedDate', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => PrescriptionModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  /// Update prescription
  Future<void> updatePrescription(PrescriptionModel prescription) async {
    try {
      if (prescription.id == null) {
        throw Exception('Prescription ID is required for update');
      }

      prescription.updatedAt = DateTime.now();

      await _prescriptionsCollection
          .doc(prescription.id)
          .update(prescription.toJson());
    } catch (e) {
      throw Exception('Failed to update prescription: $e');
    }
  }

  /// Update prescription status
  Future<void> updatePrescriptionStatus(String prescriptionId, String status) async {
    try {
      await _prescriptionsCollection.doc(prescriptionId).update({
        'status': status,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Failed to update prescription status: $e');
    }
  }

  /// Delete prescription
  Future<void> deletePrescription(String prescriptionId) async {
    try {
      await _prescriptionsCollection.doc(prescriptionId).delete();
    } catch (e) {
      throw Exception('Failed to delete prescription: $e');
    }
  }

  /// Add medication to prescription
  Future<void> addMedication(String prescriptionId, MedicationModel medication) async {
    try {
      final prescription = await getPrescriptionById(prescriptionId);
      if (prescription == null) {
        throw Exception('Prescription not found');
      }

      prescription.medications ??= [];
      medication.id = DateTime.now().millisecondsSinceEpoch.toString();
      prescription.medications!.add(medication);
      prescription.updatedAt = DateTime.now();

      await _prescriptionsCollection
          .doc(prescriptionId)
          .update(prescription.toJson());
    } catch (e) {
      throw Exception('Failed to add medication: $e');
    }
  }

  /// Remove medication from prescription
  Future<void> removeMedication(String prescriptionId, String medicationId) async {
    try {
      final prescription = await getPrescriptionById(prescriptionId);
      if (prescription == null) {
        throw Exception('Prescription not found');
      }

      prescription.medications?.removeWhere((med) => med.id == medicationId);
      prescription.updatedAt = DateTime.now();

      await _prescriptionsCollection
          .doc(prescriptionId)
          .update(prescription.toJson());
    } catch (e) {
      throw Exception('Failed to remove medication: $e');
    }
  }

  /// Auto-expire prescriptions (call this periodically)
  Future<void> autoExpirePrescriptions() async {
    try {
      final now = DateTime.now();
      final snapshot = await _prescriptionsCollection
          .where('status', isEqualTo: 'active')
          .get();

      for (var doc in snapshot.docs) {
        final prescription = PrescriptionModel.fromJson(doc.data() as Map<String, dynamic>);
        if (prescription.expiryDate != null && now.isAfter(prescription.expiryDate!)) {
          await updatePrescriptionStatus(prescription.id!, 'expired');
        }
      }
    } catch (e) {
      throw Exception('Failed to auto-expire prescriptions: $e');
    }
  }

  /// Search prescriptions by medication name
  Future<List<PrescriptionModel>> searchPrescriptionsByMedication(
    String patientId,
    String medicationName,
  ) async {
    try {
      final snapshot = await _prescriptionsCollection
          .where('patientId', isEqualTo: patientId)
          .get();

      final prescriptions = snapshot.docs
          .map((doc) => PrescriptionModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      // Filter by medication name
      return prescriptions.where((prescription) {
        return prescription.medications?.any((med) =>
                med.name?.toLowerCase().contains(medicationName.toLowerCase()) ?? false) ??
            false;
      }).toList();
    } catch (e) {
      throw Exception('Failed to search prescriptions: $e');
    }
  }
}
