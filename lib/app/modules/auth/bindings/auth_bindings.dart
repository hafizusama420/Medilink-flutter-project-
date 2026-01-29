import 'package:get/get.dart';
import '../../../data/services/auth_service.dart';
import '../viewmodels/login_viewmodel.dart';
import '../viewmodels/signup_viewmodel.dart';
import '../viewmodels/forgot_password_viewmodel.dart';
import '../viewmodels/email_verification_viewmodel.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    // Services
    Get.lazyPut(() => AuthService());

    // ViewModels
    Get.lazyPut(() => LoginViewModel());
    Get.lazyPut(() => SignupViewModel());
    Get.lazyPut(() => ForgotPasswordViewModel());
    Get.lazyPut(() => EmailVerificationViewModel());
  }
}

