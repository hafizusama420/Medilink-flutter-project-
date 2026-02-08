// lib/app/routes/app_routes.dart
class AppRoutes {
  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const signup = '/signup';
  static const login = '/login';
  static const forgotPassword = '/forgot-password';
  static const emailVerification = '/email-verification';
  static const profileSetup = '/profile-setup';
  static const home = '/home';
  
  // Profile routes
  static const profile = '/profile';
  static const editProfile = '/edit-profile';
  
  // Appointment routes
  static const appointments = '/appointments';
  static const createAppointment = '/create-appointment';
  static const appointmentDetails = '/appointments/details';
  static const editAppointment = '/appointments/edit';
  
  // Chat routes
  static const chatList = '/chat-list';
  static const chatRoom = '/chat-room';
  
  // Doctor routes
  static const doctors = '/doctors';
  
  // Review routes
  static const addReview = '/add-review';
  static const reviewsList = '/reviews-list';
  
  // Prescription routes
  static const prescriptions = '/prescriptions';
  static const createPrescription = '/create-prescription';
  static const prescriptionDetails = '/prescription-details';
  
  // Assignment routes
  static const assignments = _Paths.assignments;
  static const assignmentDetail = _Paths.assignmentDetail;
  static const createAssignment = _Paths.createAssignment;
  static const healthTracker = _Paths.healthTracker;
}

abstract class _Paths {
  static const assignments = '/assignments';
  static const assignmentDetail = '/assignment-detail';
  static const createAssignment = '/create-assignment';
  static const healthTracker = '/health-tracker';
}
