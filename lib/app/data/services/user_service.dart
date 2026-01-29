// lib/app/data/services/user_service.dart
// Service class for managing user profile data in Firestore
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user_model.dart';

/// UserService handles all Firestore operations related to user profiles
/// This includes creating, reading, and updating user profile documents
class UserService {
  // Firestore instance for database operations
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Collection name where user profiles are stored
  final String _collectionName = 'users';

  /// Saves a complete user profile to Firestore
  /// 
  /// Parameters:
  ///   - user: UserModel object containing all user profile data
  /// 
  /// Throws:
  ///   - Exception if UID is null or empty
  ///   - Exception if Firestore operation fails or times out
  Future<void> saveUserProfile(UserModel user) async {
    try {
      // Validate that user has a valid UID before proceeding
      if (user.uid == null || user.uid!.isEmpty) {
        throw Exception('User UID is required');
      }

      // Save user data to Firestore with 10-second timeout
      // Document ID is set to the user's Firebase Auth UID for easy retrieval
      await _firestore
          .collection(_collectionName)
          .doc(user.uid)
          .set(user.toMap())
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception('Firestore operation timed out. Please check your internet connection and Firestore security rules.');
            },
          );
      
    } on FirebaseException catch (e) {
      // Handle Firestore-specific errors (permissions, network, etc.)
      throw Exception('Failed to save user profile: ${e.message}');
    } catch (e) {
      // Handle any other unexpected errors
      throw Exception('An unexpected error occurred while saving profile: $e');
    }
  }

  /// Retrieves a user profile from Firestore by UID
  /// 
  /// Parameters:
  ///   - uid: Firebase Auth user ID
  /// 
  /// Returns:
  ///   - UserModel if profile exists
  ///   - null if no profile found
  /// 
  /// Throws:
  ///   - Exception if user is offline
  ///   - Exception if Firestore operation fails
  Future<UserModel?> getUserProfile(String uid) async {
    try {
      // Fetch user document from Firestore with timeout protection
      final doc = await _firestore
          .collection(_collectionName)
          .doc(uid)
          .get()
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception('Request timed out. Please check your internet connection.');
            },
          );
      
      // Check if document exists and has data
      if (doc.exists && doc.data() != null) {
        // Convert Firestore document to UserModel object
        return UserModel.fromMap(doc.data()!, doc.id);
      }
      
      // Return null if no profile document found
      return null;
    } on FirebaseException catch (e) {
      // Provide user-friendly error message for offline scenarios
      if (e.code == 'unavailable' || e.message?.contains('offline') == true) {
        throw Exception('You appear to be offline. Please check your internet connection and try again.');
      }
      
      // Handle other Firebase exceptions
      throw Exception('Failed to get user profile: ${e.message}');
    } catch (e) {
      // Handle any unexpected errors
      throw Exception('An unexpected error occurred while fetching profile: $e');
    }
  }

  /// Alias for getUserProfile - retrieves a user by ID
  /// This method exists for consistency with other service naming conventions
  Future<UserModel?> getUserById(String uid) async {
    return getUserProfile(uid);
  }

  /// Updates specific fields in a user's profile
  /// 
  /// Parameters:
  ///   - uid: Firebase Auth user ID
  ///   - updates: Map of field names and their new values
  /// 
  /// Throws:
  ///   - Exception if update operation fails
  Future<void> updateUserProfile(String uid, Map<String, dynamic> updates) async {
    try {
      // Update only the specified fields in the user document
      await _firestore
          .collection(_collectionName)
          .doc(uid)
          .update(updates);
    } on FirebaseException catch (e) {
      // Handle Firestore-specific errors
      throw Exception('Failed to update user profile: ${e.message}');
    } catch (e) {
      // Handle any other unexpected errors
      throw Exception('An unexpected error occurred while updating profile');
    }
  }

  /// Returns a real-time stream of the user profile document
  /// 
  /// Parameters:
  ///   - uid: Firebase Auth user ID
  Stream<UserModel?> getUserStream(String uid) {
    return _firestore
        .collection(_collectionName)
        .doc(uid)
        .snapshots()
        .map((snapshot) {
          if (snapshot.exists && snapshot.data() != null) {
            return UserModel.fromMap(snapshot.data()!, snapshot.id);
          }
          return null;
        });
  }
}
