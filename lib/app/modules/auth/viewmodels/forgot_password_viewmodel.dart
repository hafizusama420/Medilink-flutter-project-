// lib/app/modules/auth/viewmodels/forgot_password_viewmodel.dart
import 'package:get/get.dart';
import '../../../data/services/auth_service.dart';

class ForgotPasswordViewModel extends GetxController {
  final AuthService _authService = AuthService();
  var email = ''.obs;
  var isLoading = false.obs;

  Future<void> sendResetEmail() async {
    try {
      isLoading.value = true;
      await _authService.resetPassword(email.value);
      Get.snackbar('Success', 'Password reset email sent!',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', e.toString(),
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }
}
