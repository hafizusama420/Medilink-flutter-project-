import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';
import '../../modules/home/viewmodels/home_viewmodel.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the HomeViewModel which contains user data
    final HomeViewModel vm = Get.find<HomeViewModel>();

    return Drawer(
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          _buildHeader(context, vm),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [
                  Obx(() => _buildDrawerItem(
                    context,
                    icon: Icons.calendar_today_rounded,
                    title: vm.isDoctor ? 'Manage Appointments' : 'My Appointments',
                    onTap: () {
                      Get.back();
                      if (vm.isDoctor) {
                        vm.changeTab(2);
                      } else {
                        Get.toNamed('/appointments');
                      }
                    },
                  )),
                  Obx(() => vm.isDoctor 
                    ? const SizedBox.shrink() 
                    : _buildDrawerItem(
                        context,
                        icon: Icons.local_hospital_rounded,
                        title: 'Find Doctors',
                        onTap: () {
                          Get.back();
                          Get.toNamed('/doctors');
                        },
                      )
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.message_rounded,
                    title: 'Messages',
                    onTap: () {
                      Get.back();
                      if (vm.isDoctor) {
                        vm.changeTab(1);
                      } else {
                        Get.toNamed('/chat-list');
                      }
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.person_rounded,
                    title: 'Profile Settings',
                    onTap: () {
                      Get.back();
                      if (vm.isDoctor) {
                        vm.changeTab(3);
                      } else {
                        Get.toNamed('/profile');
                      }
                    },
                  ),
                  const Divider(indent: 20, endIndent: 20, height: 40),
                  _buildDrawerItem(
                    context,
                    icon: Icons.help_outline_rounded,
                    title: 'Help & Support',
                    onTap: () {
                      Get.back();
                    },
                  ),
                ],
              ),
            ),
          ),
          _buildFooter(vm),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, HomeViewModel vm) {
    return Obx(() {
      final user = vm.currentUser.value;
      return Container(
        padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(24),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                image: user?.profileImageUrl != null && user!.profileImageUrl!.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(user.profileImageUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
                color: Colors.white.withValues(alpha: 0.2),
              ),
              child: user?.profileImageUrl == null || user!.profileImageUrl!.isEmpty
                  ? const Icon(Icons.person, color: Colors.white, size: 35)
                  : null,
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user?.fullName ?? 'User Name',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    user?.email ?? 'user@email.com',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 13,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.primaryGreen.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppTheme.primaryGreen, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppTheme.textDark,
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  Widget _buildFooter(HomeViewModel vm) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Divider(),
          TextButton.icon(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Get.offAllNamed('/login');
              Get.snackbar(
                'Logged Out', 
                'You have been logged out successfully', 
                snackPosition: SnackPosition.BOTTOM, 
                backgroundColor: AppTheme.successGreen, 
                colorText: Colors.white
              );
            },
            icon: const Icon(Icons.logout_rounded, color: AppTheme.errorRed),
            label: const Text(
              'Sign out',
              style: TextStyle(
                color: AppTheme.errorRed,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
