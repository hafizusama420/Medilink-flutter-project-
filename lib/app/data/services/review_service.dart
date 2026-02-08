// lib/app/data/services/review_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/review_model.dart';

class ReviewService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _reviewsCollection = 'reviews';
  final String _usersCollection = 'users';

  /// Add a new review and update doctor's rating
  Future<void> addReview(ReviewModel review) async {
    try {
      // Add review to Firestore
      await _firestore.collection(_reviewsCollection).add(review.toMap());

      // Update doctor's rating
      await _updateDoctorRating(review.doctorId!);


    } catch (e) {

      throw Exception('Failed to add review: $e');
    }
  }

  /// Get all reviews for a specific doctor
  Stream<List<ReviewModel>> getReviewsForDoctor(String doctorId) {
    return _firestore
        .collection(_reviewsCollection)
        .where('doctorId', isEqualTo: doctorId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ReviewModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  /// Check if a user has already reviewed a specific appointment
  Future<bool> hasUserReviewedAppointment(
      String appointmentId, String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_reviewsCollection)
          .where('appointmentId', isEqualTo: appointmentId)
          .where('patientId', isEqualTo: userId)
          .limit(1)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {

      return false;
    }
  }

  /// Update doctor's average rating and total review count
  Future<void> _updateDoctorRating(String doctorId) async {
    try {
      // Get all reviews for this doctor
      final snapshot = await _firestore
          .collection(_reviewsCollection)
          .where('doctorId', isEqualTo: doctorId)
          .get();

      if (snapshot.docs.isEmpty) {
        // No reviews yet, set defaults
        await _firestore.collection(_usersCollection).doc(doctorId).update({
          'rating': 0.0,
          'totalReviews': 0,
        });
        return;
      }

      // Calculate average rating
      int totalRating = 0;
      for (var doc in snapshot.docs) {
        totalRating += (doc.data()['rating'] as int? ?? 0);
      }

      double averageRating = totalRating / snapshot.docs.length;
      int totalReviews = snapshot.docs.length;

      // Update doctor's profile
      await _firestore.collection(_usersCollection).doc(doctorId).update({
        'rating': double.parse(averageRating.toStringAsFixed(1)),
        'totalReviews': totalReviews,
      });


    } catch (e) {

      throw Exception('Failed to update doctor rating: $e');
    }
  }

  /// Get review statistics for a doctor
  Future<Map<String, dynamic>> getDoctorReviewStats(String doctorId) async {
    try {
      final snapshot = await _firestore
          .collection(_reviewsCollection)
          .where('doctorId', isEqualTo: doctorId)
          .get();

      if (snapshot.docs.isEmpty) {
        return {
          'averageRating': 0.0,
          'totalReviews': 0,
          'ratingDistribution': {5: 0, 4: 0, 3: 0, 2: 0, 1: 0},
        };
      }

      int totalRating = 0;
      Map<int, int> distribution = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};

      for (var doc in snapshot.docs) {
        int rating = doc.data()['rating'] as int? ?? 0;
        totalRating += rating;
        distribution[rating] = (distribution[rating] ?? 0) + 1;
      }

      double averageRating = totalRating / snapshot.docs.length;

      return {
        'averageRating': double.parse(averageRating.toStringAsFixed(1)),
        'totalReviews': snapshot.docs.length,
        'ratingDistribution': distribution,
      };
    } catch (e) {

      return {
        'averageRating': 0.0,
        'totalReviews': 0,
        'ratingDistribution': {5: 0, 4: 0, 3: 0, 2: 0, 1: 0},
      };
    }
  }

  /// Delete a review (optional - for admin or user)
  Future<void> deleteReview(String reviewId, String doctorId) async {
    try {
      await _firestore.collection(_reviewsCollection).doc(reviewId).delete();
      await _updateDoctorRating(doctorId);

    } catch (e) {

      throw Exception('Failed to delete review: $e');
    }
  }
}
