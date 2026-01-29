// lib/app/modules/reviews/viewmodels/reviews_list_viewmodel.dart
import 'package:get/get.dart';
import '../../../data/services/review_service.dart';
import '../../../models/review_model.dart';

class ReviewsListViewModel extends GetxController {
  final ReviewService _reviewService = ReviewService();

  // Observable state
  var reviews = <ReviewModel>[].obs;
  var isLoading = true.obs;
  var averageRating = 0.0.obs;
  var totalReviews = 0.obs;
  var ratingDistribution = <int, int>{}.obs;

  // Doctor ID passed from previous screen
  String? doctorId;
  String? doctorName;

  @override
  void onInit() {
    super.onInit();
    // Get arguments
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      doctorId = args['doctorId'];
      doctorName = args['doctorName'];
    }

    if (doctorId != null) {
      loadReviews();
      loadReviewStats();
    }
  }

  /// Load reviews for the doctor
  void loadReviews() {
    try {
      isLoading.value = true;
      _reviewService.getReviewsForDoctor(doctorId!).listen((reviewsList) {
        reviews.value = reviewsList;
        isLoading.value = false;
      }, onError: (error) {
        print('ReviewsListViewModel: Error loading reviews: $error');
        isLoading.value = false;
        Get.snackbar(
          'Error',
          'Failed to load reviews',
          snackPosition: SnackPosition.BOTTOM,
        );
      });
    } catch (e) {
      print('ReviewsListViewModel: Error in loadReviews: $e');
      isLoading.value = false;
    }
  }

  /// Load review statistics
  Future<void> loadReviewStats() async {
    try {
      final stats = await _reviewService.getDoctorReviewStats(doctorId!);
      averageRating.value = stats['averageRating'];
      totalReviews.value = stats['totalReviews'];
      ratingDistribution.value = Map<int, int>.from(stats['ratingDistribution']);
    } catch (e) {
      print('ReviewsListViewModel: Error loading stats: $e');
    }
  }

  /// Get percentage for a specific star rating
  double getRatingPercentage(int stars) {
    if (totalReviews.value == 0) return 0.0;
    final count = ratingDistribution[stars] ?? 0;
    return (count / totalReviews.value) * 100;
  }
}
