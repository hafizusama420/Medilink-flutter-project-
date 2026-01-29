// lib/app/data/services/doctor_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:semesterprojectgetx/app/models/user_model.dart';

class DoctorService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'users'; // Changed from 'doctors' to 'users'

  // Get all doctors (users with role="Doctor")
  Future<List<UserModel>> getAllDoctors() async {
    try {
      // print('DoctorService: Fetching all doctors from users collection...');
      QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .where('role', isEqualTo: 'Doctor')
          .get();
      
      List<UserModel> doctors = snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
      
      // print('DoctorService: Fetched ${doctors.length} doctors');
      return doctors;
    } catch (e) {
      // print('DoctorService: Error fetching doctors: $e');
      rethrow;
    }
  }

  // Get doctor by ID (user ID)
  Future<UserModel?> getDoctorById(String doctorId) async {
    try {
      // print('DoctorService: Fetching doctor with ID: $doctorId');
      DocumentSnapshot doc = await _firestore.collection(_collection).doc(doctorId).get();
      
      if (doc.exists) {
        UserModel user = UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        // Verify it's a doctor
        if (user.role == 'Doctor') {
          return user;
        }
      }
      return null;
    } catch (e) {
      // print('DoctorService: Error fetching doctor: $e');
      rethrow;
    }
  }

  // Get doctors by specialty
  Future<List<UserModel>> getDoctorsBySpecialty(String specialty) async {
    try {
      // print('DoctorService: Fetching doctors with specialty: $specialty');
      QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .where('role', isEqualTo: 'Doctor')
          .where('specialty', isEqualTo: specialty)
          .get();
      
      List<UserModel> doctors = snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
      
      // print('DoctorService: Fetched ${doctors.length} doctors for specialty: $specialty');
      return doctors;
    } catch (e) {
      // print('DoctorService: Error fetching doctors by specialty: $e');
      rethrow;
    }
  }

  // Search doctors by name
  Future<List<UserModel>> searchDoctors(String query) async {
    try {
      // print('DoctorService: Searching doctors with query: $query');
      QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .where('role', isEqualTo: 'Doctor')
          .get();
      
      List<UserModel> doctors = snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .where((doctor) =>
              doctor.fullName?.toLowerCase().contains(query.toLowerCase()) ?? false)
          .toList();
      
      // print('DoctorService: Found ${doctors.length} doctors matching query');
      return doctors;
    } catch (e) {
      // print('DoctorService: Error searching doctors: $e');
      rethrow;
    }
  }

  // Get unique specialties from all doctors
  Future<List<String>> getSpecialties() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .where('role', isEqualTo: 'Doctor')
          .get();
      
      Set<String> specialties = {};
      
      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        if (data['specialty'] != null) {
          specialties.add(data['specialty']);
        }
      }
      
      return specialties.toList()..sort();
    } catch (e) {
      // print('DoctorService: Error fetching specialties: $e');
      rethrow;
    }
  }
}
