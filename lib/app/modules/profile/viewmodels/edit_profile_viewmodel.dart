// lib/app/modules/profile/viewmodels/edit_profile_viewmodel.dart
// ViewModel for editing user profile information
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/services/user_service.dart';
import '../../../data/services/cloudinary_service.dart';

/// EditProfileViewModel manages the state and logic for editing user profiles
/// Handles form inputs, image uploads, and saving changes to Firestore
class EditProfileViewModel extends GetxController {
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
  var selectedRole = 'Patient'.obs;             // User's role in the system
  var selectedCountryCode = '+92'.obs;          // Phone number country code
  
  // Image-related observables
  var selectedImage = Rx<XFile?>(null);         // Newly selected profile image
  var currentProfileImageUrl = ''.obs;          // Current profile image URL from Firestore
  var isUploadingImage = false.obs;             // Image upload progress indicator

  // Dropdown options for gender selection
  final List<String> genderOptions = [
    'Male',
    'Female',
    'Other',
    'Prefer not to say',
  ];

  // Dropdown options for user role selection
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

  /// Called when the controller is initialized
  /// Loads the current user's profile data into the form
  @override
  void onInit() {
    super.onInit();
    loadCurrentProfile();
  }

  /// Loads the current user's profile from Firestore and populates form fields
  /// 
  /// Process:
  /// 1. Gets current authenticated user
  /// 2. Fetches profile from Firestore
  /// 3. Populates all form fields with existing data
  Future<void> loadCurrentProfile() async {
    try {
      // Get currently authenticated user
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return;
      }
      
      // Fetch user profile from Firestore
      final profile = await _userService.getUserProfile(user.uid);
      
      if (profile != null) {
        // Populate form fields with existing profile data
        fullNameController.text = profile.fullName ?? '';
        selectedGender.value = profile.gender ?? '';
        selectedRole.value = profile.role ?? 'Patient';
        currentProfileImageUrl.value = profile.profileImageUrl ?? '';
        
        // Parse phone number into country code and number
        if (profile.phoneNumber != null && profile.phoneNumber!.isNotEmpty) {
          final parts = profile.phoneNumber!.split(' ');
          if (parts.length == 2) {
            selectedCountryCode.value = parts[0];  // Extract country code
            phoneController.text = parts[1];        // Extract phone number
            phoneNumber.value = profile.phoneNumber!;
          }
        }

        // Populate doctor-specific fields
        specialtyController.text = profile.specialty ?? '';
        qualificationsController.text = profile.qualifications ?? '';
        experienceController.text = profile.experience ?? '';
        consultationFeeController.text = profile.consultationFee?.toInt().toString() ?? '';
        aboutController.text = profile.about ?? '';
      }
    } catch (e) {
      // Silently handle errors - user can still edit profile
    }
  }

  /// Updates the selected gender
  void setGender(String gender) {
    selectedGender.value = gender;
  }

  /// Updates the country code and refreshes the full phone number
  void setCountryCode(String code) {
    selectedCountryCode.value = code;
    updatePhoneNumber();  // Rebuild full phone number with new code
  }

  /// Combines country code and phone number into full phone number string
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

  /// Opens image picker to select a new profile picture from gallery
  /// 
  /// Image constraints:
  /// - Max dimensions: 1024x1024 pixels
  /// - Quality: 85% compression
  Future<void> pickImageFromGallery() async {
    try {
      // Open image picker with size and quality constraints
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (pickedFile != null) {
        // Update selected image observable
        selectedImage.value = pickedFile;
      }
    } catch (e) {
      // Show error message to user
      Get.snackbar(
        'Error',
        'Failed to pick image: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Uploads the selected image to Cloudinary
  /// 
  /// Returns:
  /// - String: URL of uploaded image
  /// - null: If no image to upload or upload failed
  Future<String?> uploadImageToCloudinary() async {
    // If no new image selected, return current image URL
    if (selectedImage.value == null) {
      return currentProfileImageUrl.value.isEmpty ? null : currentProfileImageUrl.value;
    }
    
    try {
      // Set uploading state to show progress indicator
      isUploadingImage.value = true;
      
      // Upload image to Cloudinary
      final imageUrl = await _cloudinaryService.uploadImage(selectedImage.value!);
      
      // Update current image URL with newly uploaded image
      currentProfileImageUrl.value = imageUrl;
      
      return imageUrl;
    } catch (e) {
      // Show upload error but don't block profile save
      Get.snackbar(
        'Upload Error',
        'Failed to upload image: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
      // Return current image URL to keep existing image
      return currentProfileImageUrl.value.isEmpty ? null : currentProfileImageUrl.value;
    } finally {
      // Always reset uploading state
      isUploadingImage.value = false;
    }
  }

  /// Validates form inputs and saves the updated profile to Firestore
  /// 
  /// Validation checks:
  /// - Full name is not empty
  /// - Gender is selected
  /// - Phone number is provided
  /// 
  /// Process:
  /// 1. Validates all required fields
  /// 2. Uploads new profile image if selected
  /// 3. Updates Firestore with new data
  /// 4. Shows success message and navigates back
  Future<void> saveProfile() async {
    try {
      // Validate full name
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

      // Validate gender selection
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

      // Validate phone number
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

      // Set loading state to disable save button
      isLoading.value = true;

      // Upload new profile image if selected
      String? uploadedImageUrl = await uploadImageToCloudinary();

      // Get current authenticated user
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('No user is currently signed in');
      }

      // Prepare update data map
      final updates = {
        'fullName': fullNameController.text.trim(),
        'gender': selectedGender.value,
        'phoneNumber': phoneNumber.value,
        'role': selectedRole.value,
        // Only include image URL if a new one was uploaded
        if (uploadedImageUrl != null) 'profileImageUrl': uploadedImageUrl,
        
        // Doctor-specific fields (only if role is Doctor)
        if (selectedRole.value == 'Doctor') ...{
          'specialty': specialtyController.text.trim(),
          'qualifications': qualificationsController.text.trim(),
          'experience': experienceController.text.trim(),
          'consultationFee': double.tryParse(consultationFeeController.text.trim()) ?? 0.0,
          'about': aboutController.text.trim(),
        }
      };

      // Update user profile in Firestore
      await _userService.updateUserProfile(user.uid, updates);

      // Show success message
      Get.snackbar(
        'Success',
        'Profile updated successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

      // Wait briefly for user to see success message
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Navigate back to profile view with success result
      Get.back(result: true);
      
    } catch (e) {
      // Show error message if save failed
      Get.snackbar(
        'Error',
        'Failed to save profile: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    } finally {
      // Always reset loading state
      isLoading.value = false;
    }
  }

  /// Cleanup method called when controller is disposed
  /// Disposes text controllers to prevent memory leaks
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
