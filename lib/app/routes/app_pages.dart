// lib/app/routes/app_pages.dart
import 'package:get/get.dart';
import '../modules/auth/views/email_verification_view.dart';
import '../modules/auth/views/forgot_password_view.dart';
import '../modules/auth/views/login_view.dart';
import '../modules/auth/views/profile_setup_view.dart';
import '../modules/auth/views/signup_view.dart';
import '../modules/splash/views/splash_view.dart';
import '../modules/onboarding/views/onboarding_view.dart';
import '../modules/home/views/home_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/appointment/views/appointments_list_view.dart';
import '../modules/appointment/views/create_appointment_view.dart';
import '../modules/appointment/views/appointment_details_view.dart';
import '../modules/appointment/views/edit_appointment_view.dart';
import '../modules/appointment/bindings/appointment_binding.dart';
import '../modules/profile/views/profile_view.dart';
import '../modules/profile/views/edit_profile_view.dart';
import '../modules/chat/views/chat_list_view.dart';
import '../modules/chat/views/chat_room_view.dart';
import '../modules/chat/bindings/chat_binding.dart';
import '../modules/doctors/views/doctor_list_view.dart';
import '../modules/doctors/bindings/doctor_binding.dart';
import '../modules/reviews/views/add_review_view.dart';
import '../modules/reviews/views/reviews_list_view.dart';
import '../modules/reviews/bindings/review_binding.dart';
import '../modules/lab_tests/views/lab_tests_view.dart';
import '../modules/lab_tests/bindings/lab_tests_binding.dart';
import 'app_routes.dart';

class AppPages {
  static final pages = [
    GetPage(name: AppRoutes.splash, page: () => const SplashView()),
    GetPage(name: AppRoutes.onboarding, page: () => const OnboardingView()),
    GetPage(name: AppRoutes.signup, page: () => SignupView()),
    GetPage(name: AppRoutes.login, page: () => LoginView()),
    GetPage(name: AppRoutes.forgotPassword, page: () => ForgotPasswordView()),
    GetPage(
        name: AppRoutes.emailVerification,
        page: () => EmailVerificationView()),
    GetPage(
        name: AppRoutes.profileSetup,
        page: () => ProfileSetupView()),
    GetPage(name: AppRoutes.home, page: () => const HomeView(), binding: HomeBinding()),
    
    // Profile routes
    GetPage(name: AppRoutes.profile, page: () => ProfileView()),
    GetPage(name: AppRoutes.editProfile, page: () => EditProfileView()),
    
    // Appointment routes
    GetPage(
      name: AppRoutes.appointments,
      page: () => const AppointmentsListView(),
      binding: AppointmentBinding(),
    ),
    GetPage(
      name: AppRoutes.createAppointment,
      page: () => const CreateAppointmentView(),
      binding: AppointmentBinding(),
    ),
    GetPage(
      name: AppRoutes.appointmentDetails,
      page: () => const AppointmentDetailsView(),
      binding: AppointmentBinding(),
    ),
    GetPage(
      name: AppRoutes.editAppointment,
      page: () => const EditAppointmentView(),
      binding: AppointmentBinding(),
    ),
    
    // Chat routes
    GetPage(
      name: AppRoutes.chatList,
      page: () => const ChatListView(),
      binding: ChatBinding(),
    ),
    GetPage(
      name: AppRoutes.chatRoom,
      page: () => const ChatRoomView(),
      binding: ChatBinding(),
    ),
    
    // Doctor routes
    GetPage(
      name: AppRoutes.doctors,
      page: () => const DoctorListView(),
      binding: DoctorBinding(),
    ),
    
    // Review routes
    GetPage(
      name: AppRoutes.addReview,
      page: () => const AddReviewView(),
      binding: ReviewBinding(),
    ),
    GetPage(
      name: AppRoutes.reviewsList,
      page: () => const ReviewsListView(),
      binding: ReviewBinding(),
    ),
    
    // Lab Tests routes
    GetPage(
      name: AppRoutes.labTests,
      page: () => const LabTestsView(),
      binding: LabTestsBinding(),
    ),
  ];
}
