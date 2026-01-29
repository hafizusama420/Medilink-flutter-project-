import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../viewmodels/profile_viewmodel.dart';
import '../../../core/theme/app_theme.dart';

class ProfileView extends StatelessWidget {
  ProfileView({super.key});
  
  final ProfileViewModel vm = Get.put(ProfileViewModel());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Get.currentRoute == '/home' // Simplified check for Home
            ? null 
            : IconButton(
                icon: const Icon(Icons.arrow_back, color: AppTheme.primaryGreen),
                onPressed: () => Get.back(),
              ),
        automaticallyImplyLeading: false,
        actions: [
          Obx(() => vm.userProfile.value != null
              ? IconButton(
                  icon: const Icon(Icons.edit, color: AppTheme.primaryGreen),
                  onPressed: vm.navigateToEditProfile,
                )
              : const SizedBox()),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Obx(() {
            if (vm.isLoading.value) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (vm.errorMessage.value.isNotEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: AppTheme.errorRed,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        vm.errorMessage.value,
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: vm.navigateToProfileSetup,
                        child: const Text('Complete Profile Setup'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final profile = vm.userProfile.value;
            if (profile == null) {
              return const Center(child: Text('No profile data'));
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Profile Header
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Profile Image
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppTheme.primaryGreen,
                              width: 4,
                            ),
                            image: profile.profileImageUrl != null &&
                                    profile.profileImageUrl!.isNotEmpty
                                ? DecorationImage(
                                    image: NetworkImage(profile.profileImageUrl!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                            color: AppTheme.lightGreen,
                          ),
                          child: profile.profileImageUrl == null ||
                                  profile.profileImageUrl!.isEmpty
                              ? const Icon(
                                  Icons.person,
                                  size: 60,
                                  color: AppTheme.primaryGreen,
                                )
                              : null,
                        ),
                        const SizedBox(height: 16),
                        
                        // Name
                        Text(
                          profile.fullName ?? 'No Name',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        
                        // Role Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            profile.role ?? 'User',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Profile Details
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Profile Information',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        _buildInfoRow(
                          context,
                          icon: Icons.email_outlined,
                          label: 'Email',
                          value: profile.email ?? 'No email',
                        ),
                        const Divider(height: 32),
                        
                        _buildInfoRow(
                          context,
                          icon: Icons.phone_outlined,
                          label: 'Phone',
                          value: profile.phoneNumber ?? 'No phone',
                        ),
                        const Divider(height: 32),
                        
                        _buildInfoRow(
                          context,
                          icon: Icons.wc_outlined,
                          label: 'Gender',
                          value: profile.gender ?? 'Not specified',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Doctor Professional Details Section
                  if (profile.role == 'Doctor') ...[
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Professional Information',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),
                          
                          _buildInfoRow(
                            context,
                            icon: Icons.medical_services_outlined,
                            label: 'Specialty',
                            value: profile.specialty ?? 'Not specified',
                          ),
                          const Divider(height: 32),
                          
                          _buildInfoRow(
                            context,
                            icon: Icons.school_outlined,
                            label: 'Qualifications',
                            value: profile.qualifications ?? 'Not specified',
                          ),
                          const Divider(height: 32),
                          
                          _buildInfoRow(
                            context,
                            icon: Icons.work_history_outlined,
                            label: 'Experience',
                            value: profile.experience ?? 'Not specified',
                          ),
                          const Divider(height: 32),
                          
                          _buildInfoRow(
                            context,
                            icon: Icons.attach_money_rounded,
                            label: 'Consultation Fee',
                            value: profile.consultationFee != null ? 'Rs. ${profile.consultationFee!.toInt()}' : 'Not specified',
                          ),
                          const Divider(height: 32),
                          
                          _buildInfoRow(
                            context,
                            icon: Icons.info_outline_rounded,
                            label: 'About / Bio',
                            value: profile.about ?? 'No bio provided',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Edit Button
                  Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryGreen.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: vm.navigateToEditProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: const Icon(Icons.edit),
                      label: const Text(
                        'Edit Profile',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.primaryGreen.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: AppTheme.primaryGreen,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textLight,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
