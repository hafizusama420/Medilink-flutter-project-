// lib/app/modules/reviews/bindings/review_binding.dart
import 'package:get/get.dart';
import '../viewmodels/add_review_viewmodel.dart';
import '../viewmodels/reviews_list_viewmodel.dart';

class ReviewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddReviewViewModel>(() => AddReviewViewModel());
    Get.lazyPut<ReviewsListViewModel>(() => ReviewsListViewModel());
  }
}
