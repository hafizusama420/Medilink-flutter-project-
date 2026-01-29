// lib/app/modules/doctors/viewmodels/doctor_list_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:semesterprojectgetx/app/data/services/doctor_service.dart';
import 'package:semesterprojectgetx/app/data/services/chat_service.dart';
import 'package:semesterprojectgetx/app/data/services/user_service.dart';
import 'package:semesterprojectgetx/app/models/user_model.dart';
import 'package:semesterprojectgetx/app/models/chat_room_model.dart';

class DoctorListViewModel extends GetxController {
  final DoctorService _doctorService = DoctorService();
  final ChatService _chatService = ChatService();
  final UserService _userService = UserService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  var doctors = <UserModel>[].obs;
  var filteredDoctors = <UserModel>[].obs;
  var specialties = <String>[].obs;
  var isLoading = true.obs;
  var selectedSpecialty = 'All'.obs;
  var searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadDoctors();
    loadSpecialties();
  }

  void loadDoctors() async {
    try {
      isLoading.value = true;
      // print('DoctorListViewModel: Loading doctors...');
      
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        // print('DoctorListViewModel: USER IS NOT LOGGED IN!');
      } else {
        // print('DoctorListViewModel: USER IS LOGGED IN: ${currentUser.uid}');
      }
      
      List<UserModel> doctorList = await _doctorService.getAllDoctors();
      doctors.value = doctorList;
      filteredDoctors.value = doctorList;
      isLoading.value = false;
      
      // print('DoctorListViewModel: Loaded ${doctorList.length} doctors');
    } catch (e) {
      // print('DoctorListViewModel: Error loading doctors: $e');
      isLoading.value = false;
      Get.snackbar(
        'Error',
        'Failed to load doctors',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void loadSpecialties() async {
    try {
      List<String> specialtyList = await _doctorService.getSpecialties();
      specialties.value = ['All', ...specialtyList];
    } catch (e) {
      // print('DoctorListViewModel: Error loading specialties: $e');
    }
  }

  void filterBySpecialty(String specialty) {
    selectedSpecialty.value = specialty;
    applyFilters();
  }

  void searchDoctors(String query) {
    searchQuery.value = query;
    applyFilters();
  }

  void applyFilters() {
    List<UserModel> result = doctors;

    // Filter by specialty
    if (selectedSpecialty.value != 'All') {
      result = result
          .where((doctor) => doctor.specialty == selectedSpecialty.value)
          .toList();
    }

    // Filter by search query
    if (searchQuery.value.isNotEmpty) {
      result = result
          .where((doctor) =>
              doctor.fullName
                  ?.toLowerCase()
                  .contains(searchQuery.value.toLowerCase()) ??
              false)
          .toList();
    }

    filteredDoctors.value = result;
  }

  void startChatWithDoctor(UserModel doctor) async {
    try {
      // print('DoctorListViewModel: Starting chat with doctor: ${doctor.fullName}');
      
      String? currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) {
        Get.snackbar(
          'Error',
          'Please login to chat with doctor',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // Get current user data
      UserModel? currentUser = await _userService.getUserById(currentUserId);
      if (currentUser == null) {
        Get.snackbar(
          'Error',
          'User data not found',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // Create or get chat room
      ChatRoomModel chatRoom = await _chatService.getOrCreateChatRoom(
        doctorId: doctor.uid!,
        patientId: currentUserId,
        doctorName: doctor.fullName ?? 'Doctor',
        patientName: currentUser.fullName ?? 'Patient',
        doctorProfileImage: doctor.profileImageUrl,
        patientProfileImage: currentUser.profileImageUrl,
      );

      // Navigate to chat room
      Get.toNamed('/chat-room', arguments: chatRoom);
      
      // print('DoctorListViewModel: Navigated to chat room');
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to start chat: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void navigateToReviews(UserModel doctor) {
    Get.toNamed('/reviews-list', arguments: {
      'doctorId': doctor.uid,
      'doctorName': doctor.fullName,
    });
  }
}
