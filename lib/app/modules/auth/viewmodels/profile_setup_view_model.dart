// lib/app/modules/auth/viewmodels/profile_setup_view_model.dart
// ViewModel for initial user profile setup after signup
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/services/user_service.dart';
import '../../../data/services/cloudinary_service.dart';
import '../../../models/user_model.dart';

/// ProfileSetupViewModel manages the initial profile setup process
/// Collects user information and profile picture after signup
class ProfileSetupViewModel extends GetxController {
  // Service instances for data operations
  final UserService _userService = UserService();
  final CloudinaryService _cloudinaryService = CloudinaryService();
  final ImagePicker _imagePicker = ImagePicker();
  
  // Text controllers for form inputs
  var fullNameController = TextEditingController();
  var phoneController = TextEditingController();
  
  // Doctor-specific controllers
  var specialtyController = TextEditingController();
  var qualificationsController = TextEditingController();
  var experienceController = TextEditingController();
  var consultationFeeController = TextEditingController();
  var aboutController = TextEditingController();
  
  // Observable state variables
  var isLoading = false.obs;                    // Loading state for save operation
  var selectedGender = ''.obs;                  // Currently selected gender
  var phoneNumber = ''.obs;                     // Full phone number with country code
  var selectedRole = 'Patient'.obs;             // User's role (default: Patient)
  var selectedCountryCode = '+92'.obs;          // Phone country code (default: Pakistan)
  
  // Image-related observables - using XFile for cross-platform compatibility
  var selectedImage = Rx<XFile?>(null);         // Selected profile image file
  var profileImageUrl = ''.obs;                 // Uploaded image URL from Cloudinary
  var isUploadingImage = false.obs;             // Image upload progress indicator
  
  // Dropdown options for gender selection
  final List<String> genderOptions = [
    'Male',
    'Female',
    'Other',
    'Prefer not to say',
  ];

  // Dropdown options for user role
  final List<String> roleOptions = [
    'Patient',
    'Doctor',
    'Admin',
  ];

  // Available country codes for phone numbers
  final List<String> countryCodes = [
    '+92',  // Pakistan
    '+1',   // USA/Canada
    '+44',  // UK
    '+91',  // India
    '+971', // UAE
    '+966', // Saudi Arabia
    '+61',  // Australia
    '+81',  // Japan
    '+86',  // China
    '+49',  // Germany
  ];

  /// Updates the selected gender
  void setGender(String gender) {
    selectedGender.value = gender;
  }

  /// Updates the country code and refreshes full phone number
  void setCountryCode(String code) {
    selectedCountryCode.value = code;
    updatePhoneNumber();  // Rebuild full phone number
  }

  /// Combines country code and phone number into complete phone string
  void updatePhoneNumber() {
    if (phoneController.text.isNotEmpty) {
      phoneNumber.value = '${selectedCountryCode.value} ${phoneController.text}';
    } else {
      phoneNumber.value = '';
    }
  }

  /// Updates the selected user role
  void setRole(String role) {
    selectedRole.value = role;
  }

  /// Opens image picker to select profile picture from gallery
  Future<void> pickImageFromGallery() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (pickedFile != null) {
        selectedImage.value = pickedFile;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick image: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Uploads selected image to Cloudinary cloud storage
  Future<String?> uploadImageToCloudinary() async {
    if (selectedImage.value == null) {
      return null;
    }
    
    try {
      isUploadingImage.value = true;
      final imageUrl = await _cloudinaryService.uploadImage(selectedImage.value!);
      profileImageUrl.value = imageUrl;
      return imageUrl;
    } catch (e) {
      Get.snackbar(
        'Upload Error',
        'Failed to upload image: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
      return null;
    } finally {
      isUploadingImage.value = false;
    }
  }

  /// Validates all form inputs and saves the complete profile to Firestore
  Future<void> completeProfile() async {
    try {
      if (fullNameController.text.trim().isEmpty) {
        Get.snackbar(
          'Validation Error',
          'Please enter your full name',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }

      if (selectedGender.value.isEmpty) {
        Get.snackbar(
          'Validation Error',
          'Please select your gender',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }

      if (phoneNumber.value.isEmpty) {
        Get.snackbar(
          'Validation Error',
          'Please enter your phone number',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }

      isLoading.value = true;

      String? uploadedImageUrl;
      if (selectedImage.value != null) {
        uploadedImageUrl = await uploadImageToCloudinary();
      }

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('No user is currently signed in');
      }

      final userModel = UserModel(
        uid: user.uid,
        email: user.email,
        fullName: fullNameController.text.trim(),
        role: selectedRole.value,
        gender: selectedGender.value,
        phoneNumber: phoneNumber.value,
        profileImageUrl: uploadedImageUrl,
        specialty: selectedRole.value == 'Doctor' ? specialtyController.text.trim() : null,
        qualifications: selectedRole.value == 'Doctor' ? qualificationsController.text.trim() : null,
        experience: selectedRole.value == 'Doctor' ? experienceController.text.trim() : null,
        consultationFee: selectedRole.value == 'Doctor' && consultationFeeController.text.isNotEmpty
            ? double.tryParse(consultationFeeController.text)
            : null,
        about: selectedRole.value == 'Doctor' ? aboutController.text.trim() : null,
        rating: selectedRole.value == 'Doctor' ? 0.0 : null,
        totalReviews: selectedRole.value == 'Doctor' ? 0 : null,
      );

      await _userService.saveUserProfile(userModel);

      Get.snackbar(
        'Success',
        'Profile saved successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

      await Future.delayed(const Duration(milliseconds: 500));
      Get.offAllNamed('/home');
      
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save profile: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    fullNameController.dispose();
    phoneController.dispose();
    specialtyController.dispose();
    qualificationsController.dispose();
    experienceController.dispose();
    consultationFeeController.dispose();
    aboutController.dispose();
    super.onClose();
  }
}
