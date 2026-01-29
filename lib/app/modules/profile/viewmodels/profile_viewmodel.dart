import 'dart:async';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../data/services/user_service.dart';
import '../../../models/user_model.dart';

/// ProfileViewModel manages the state and logic for the Profile View screen
/// Handles loading user profile data from Firestore and navigation
class ProfileViewModel extends GetxController {
  // Service for Firestore user profile operations
  final UserService _userService = UserService();
  
  // Observable state variables
  var isLoading = true.obs;                    // Loading state indicator
  var userProfile = Rx<UserModel?>(null);      // Current user's profile data
  var errorMessage = ''.obs;                   // Error message to display
  
  // Stream subscription for real-time updates
  StreamSubscription<UserModel?>? _profileSubscription;

  /// Called when the controller is initialized
  /// Automatically loads the user's profile data
  @override
  void onInit() {
    super.onInit();
    _subscribeToProfile();
  }

  @override
  void onClose() {
    _profileSubscription?.cancel();
    super.onClose();
  }

  /// Subscribes to the user profile stream for real-time updates
  void _subscribeToProfile() {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        errorMessage.value = 'No user signed in';
        isLoading.value = false;
        return;
      }

      // Listen to real-time updates from UserService
      _profileSubscription = _userService.getUserStream(user.uid).listen(
        (profile) {
          if (profile != null) {
            userProfile.value = profile;
            errorMessage.value = '';
          } else {
            errorMessage.value = 'Profile not found. Please complete your profile setup.';
          }
          isLoading.value = false;
        },
        onError: (error) {
          errorMessage.value = 'Failed to load profile: ${error.toString()}';
          isLoading.value = false;
        },
      );
    } catch (e) {
      errorMessage.value = 'Error: ${e.toString()}';
      isLoading.value = false;
    }
  }

  /// Manually reloads profile data (kept for compatibility, though stream handles it)
  Future<void> loadUserProfile() async {
    // No-op as stream handles updates
    // print('ProfileViewModel: Stream is active, manual reload not required');
  }

  /// Navigates to the Edit Profile screen
  /// Allows user to modify their profile information
  Future<void> navigateToEditProfile() async {
    await Get.toNamed('/edit-profile');
    // Result check not needed anymore as stream updates UI immediately
  }

  /// Navigates to the Profile Setup screen
  /// Used when user hasn't completed initial profile setup
  void navigateToProfileSetup() {
    Get.toNamed('/profile-setup');
  }
}
