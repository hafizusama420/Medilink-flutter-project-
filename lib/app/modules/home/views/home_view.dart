import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_drawer.dart';
import '../../../models/appointment_model.dart';
import '../viewmodels/home_viewmodel.dart';
import 'package:google_fonts/google_fonts.dart';

// Import sub-views for persistent navigation
import '../../chat/views/chat_list_view.dart';
import '../../appointment/views/appointments_list_view.dart';
import '../../profile/views/profile_view.dart';


class HomeView extends GetView<HomeViewModel> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CustomDrawer(),
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.isDoctor) {
            return IndexedStack(
              index: controller.selectedTabIndex.value,
              children: [
                _buildDoctorHome(context),
                const ChatListView(),
                const AppointmentsListView(),
                ProfileView(),
              ],
            );
          }

          return _buildPatientHome(context);
        }),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  /// Patient Dashboard (Existing Redesign)
  Widget _buildPatientHome(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildModernHeader(context),
          const SizedBox(height: 24),
          _buildDoctorsSection(context),
          const SizedBox(height: 24),
          _buildQuickActionsSection(context),
          const SizedBox(height: 32),
          _buildPartnersLabsSection(context),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  /// Doctor Dashboard (New Requirements)
  Widget _buildDoctorHome(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDoctorHeader(context),
          _buildCancellationBanner(context),
          const SizedBox(height: 12),
          _buildDoctorAnalytics(context),
          const SizedBox(height: 20),
          _buildTodayOverviewCard(context),
          const SizedBox(height: 24),
          _buildNextAppointmentCard(context),
          const SizedBox(height: 24),
          _buildDoctorTodayAppointments(context),
          const SizedBox(height: 24),
          _buildDoctorQuickActions(context),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  /// 1. Modern Header with Welcome Text and Notifications
  Widget _buildModernHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Builder(
                builder: (context) => IconButton(
                  onPressed: () => Scaffold.of(context).openDrawer(),
                  icon: const Icon(Icons.menu, size: 30, color: AppTheme.textDark),
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontSize: 26,
                          color: AppTheme.textDark,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    controller.displayName,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textLight,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 2. Doctors Section with Horizontal Scroll
  Widget _buildDoctorsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _buildSectionHeader(
            context,
            title: 'Doctors',
            onViewAll: () => Get.toNamed('/doctors'),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 290,
          child: Obx(() {
            if (controller.isDoctorsLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }
            
            if (controller.topDoctors.isEmpty) {
              return const Center(child: Text('No doctors found'));
            }

            return ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemCount: controller.topDoctors.length,
              separatorBuilder: (context, index) => const SizedBox(width: 16),
              itemBuilder: (context, index) => _buildDoctorCard(context, controller.topDoctors[index]),
            );
          }),
        ),
      ],
    );
  }

  /// Single Doctor Card Widget
  Widget _buildDoctorCard(BuildContext context, dynamic doctor) {
    return Container(
      width: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Doctor Image + Status
          Stack(
            children: [
              Container(
                height: 150,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  image: DecorationImage(
                    image: NetworkImage(doctor.profileImageUrl ?? 'https://i.pravatar.cc/300?img=12'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Color(0xFF00B864),
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Color(0x3300B864), blurRadius: 4, spreadRadius: 2)],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Available till 07:20 PM',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF00B864),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        doctor.fullName ?? 'Dr. Unknown',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 2),
                    const Text('4.7', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  ],
                ),
                Text(
                  doctor.specialty ?? 'Medical Specialist',
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Rs.500',
                      style: TextStyle(color: Color(0xFF00B864), fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    GestureDetector(
                      onTap: () => Get.toNamed('/create-appointment', arguments: {
                        'uid': doctor.uid,
                        'fullName': doctor.fullName,
                        'specialty': doctor.specialty,
                      }),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00B864),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Book Now',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 3. Quick Actions Section
  Widget _buildQuickActionsSection(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _buildActionTile(context, icon: Icons.description_outlined, label: 'E-prescription', onTap: () {}),
          const SizedBox(width: 16),
          _buildActionTile(context, icon: Icons.assignment_outlined, label: 'Medical Records', onTap: () {}),
          const SizedBox(width: 16),
          _buildActionTile(context, icon: Icons.how_to_reg_outlined, label: 'Assignments', onTap: () {}),
        ],
      ),
    );
  }

  Widget _buildActionTile(BuildContext context, {required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FBFF),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE8F1FF), width: 1),
            ),
            child: Icon(icon, color: AppTheme.primaryBlue, size: 32),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13, color: AppTheme.textDark),
          ),
        ],
      ),
    );
  }

  /// 4. Partners Labs Section
  Widget _buildPartnersLabsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Discount with partners labs',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 160,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: controller.partnerLabs.length,
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final lab = controller.partnerLabs[index];
              return _buildLabBanner(context, lab);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLabBanner(BuildContext context, Map<String, String> lab) {
    return Stack(
      children: [
        Container(
          width: 320,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.primaryGreen.withValues(alpha: 0.8),
                AppTheme.deepGreen,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryGreen.withValues(alpha: 0.2),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Abstract Background Icon for texture
              Positioned(
                right: -30,
                bottom: -30,
                child: Icon(
                  Icons.biotech_rounded,
                  size: 180,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
              // Main Visual Icon in center
              Center(
                child: Icon(
                  Icons.science_rounded,
                  color: Colors.white.withValues(alpha: 0.7),
                  size: 60,
                ),
              ),
              // Content Overlay for text readability
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.5),
                    ],
                  ),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lab['name']!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Discount Badge
        Positioned(
          top: 15,
          right: 15,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.amber,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Text(
              lab['discount']!,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Color(0xFF1F2937),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Helper: Section Header
  Widget _buildSectionHeader(BuildContext context, {required String title, required VoidCallback onViewAll}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        TextButton(
          onPressed: onViewAll,
          child: const Text('View all', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        ),
      ],
    );
  }

  /// 5. Bottom Navigation Bar
  Widget _buildBottomNavBar() {
    return Container(
      height: 85,
      padding: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: Obx(() {
        final bool isDoctor = controller.isDoctor;
        final int selected = controller.selectedTabIndex.value;
        
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(Icons.grid_view_rounded, isDoctor ? 'Home' : 'For You', selected == 0, () => controller.changeTab(0)),
            if (!isDoctor) ...[
              _buildNavItem(Icons.biotech_rounded, 'Labs', selected == 1, () => controller.changeTab(1)),
              _buildNavItem(Icons.favorite_rounded, 'Health', selected == 2, () => controller.changeTab(2)),
              _buildNavItem(Icons.support_agent_rounded, 'Support', selected == 3, () => controller.changeTab(3)),
            ] else ...[
              _buildNavItem(Icons.chat_bubble_rounded, 'Messages', selected == 1, () => controller.changeTab(1)),
              _buildNavItem(Icons.calendar_today_rounded, 'Schedule', selected == 2, () => controller.changeTab(2)),
              _buildNavItem(Icons.person_rounded, 'Profile', selected == 3, () => controller.changeTab(3)),
            ],
          ],
        );
      }),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.primaryGreen.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon, 
              color: isActive ? AppTheme.primaryGreen : Colors.grey.shade400, 
              size: 22, // Smaller, more elegant size
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                color: isActive ? AppTheme.primaryGreen : Colors.grey.shade500,
                fontSize: 11,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// --- DOCTOR SPECIFIC WIDGETS ---

  Widget _buildDoctorAnalytics(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            _buildAnalyticItem(
              context,
              icon: Icons.payments_outlined,
              color: const Color(0xFF00B864),
              label: "Today's Earnings",
              value: "Rs. ${controller.todayEarnings.value.toInt()}",
            ),
            Container(height: 50, width: 1, color: Colors.grey.shade100),
            _buildAnalyticItem(
              context,
              icon: Icons.person_add_alt_1_outlined,
              color: AppTheme.primaryBlue,
              label: "Weekly Patients",
              value: "${controller.weeklyPatients.value}",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticItem(BuildContext context, {required IconData icon, required Color color, required String label, required String value}) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppTheme.textLight, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Builder(
                builder: (context) => IconButton(
                  onPressed: () => Scaffold.of(context).openDrawer(),
                  icon: const Icon(Icons.menu, size: 28, color: AppTheme.textDark),
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dr. ${controller.displayName}',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                  ),
                  Text(
                    controller.specialization,
                    style: const TextStyle(fontSize: 14, color: AppTheme.textLight, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ],
          ),
          Obx(() => Switch(
                value: controller.isOnline.value,
                onChanged: (v) => controller.toggleOnlineStatus(v),
                activeThumbColor: AppTheme.primaryGreen,
              )),
        ],
      ),
    );
  }

  Widget _buildCancellationBanner(BuildContext context) {
    // This could check for recent cancellations in the stream
    return Container(); // Placeholder or real banner if data exists
  }

  Widget _buildTodayOverviewCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryGreen.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Today's Overview",
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                _formatDate(DateTime.now()),
                style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem("Total", "${controller.todayAppointments.length}"),
              _buildVerticalDivider(),
              _buildStatItem("Pending", "${controller.pendingCount.value}"),
              _buildVerticalDivider(),
              _buildStatItem("Completed", "${controller.completedCount.value}"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(height: 40, width: 1, color: Colors.white.withValues(alpha: 0.3));
  }

  Widget _buildNextAppointmentCard(BuildContext context) {
    return Obx(() {
      final next = controller.nextAppointment.value;
      if (next == null) return const SizedBox.shrink();

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Next Upcoming",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 5))],
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: const BoxDecoration(color: Color(0xFFE8F1FF), shape: BoxShape.circle),
                    child: const Icon(Icons.person, color: AppTheme.primaryBlue),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          next.patientName ?? "Patient Name",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          _formatTime(next.appointmentDate),
                          style: const TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  _buildPulseIndicator(),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildPulseIndicator() {
    return Container(
      width: 10,
      height: 10,
      decoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
    );
  }

  Widget _buildDoctorTodayAppointments(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Today's Schedule",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark),
              ),
              Text(
                "${controller.todayAppointments.length} Appts",
                style: const TextStyle(color: AppTheme.textLight, fontSize: 14),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Obx(() {
          if (controller.todayAppointments.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text("No appointments scheduled for today"),
              ),
            );
          }

          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: controller.todayAppointments.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final appt = controller.todayAppointments[index];
              return _buildAppointmentListItem(context, appt);
            },
          );
        }),
      ],
    );
  }

  Widget _buildAppointmentListItem(BuildContext context, AppointmentModel appt) {
    bool isUrgent = appt.reason?.toLowerCase().contains("urgent") ?? false;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isUrgent ? Colors.red.withValues(alpha: 0.3) : Colors.grey.shade100),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Text(
                    _formatTime(appt.appointmentDate),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textDark),
                  ),
                  const SizedBox(height: 4),
                  if (appt.status?.toLowerCase() == 'completed')
                    const Icon(Icons.check_circle, color: AppTheme.primaryGreen, size: 20)
                  else if (appt.status?.toLowerCase() == 'cancelled')
                    const Icon(Icons.cancel, color: Colors.red, size: 20)
                  else
                    const Icon(Icons.access_time_rounded, color: Colors.grey, size: 20)
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appt.patientName ?? "Patient Name",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      appt.reason ?? "Short reason / symptoms",
                      style: const TextStyle(color: AppTheme.textLight, fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (isUrgent)
                const Icon(Icons.warning_rounded, color: Colors.red, size: 20),
            ],
          ),
          if (appt.effectiveStatus == 'completed') ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.successGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.successGreen.withOpacity(0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle_outline, color: AppTheme.successGreen, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Appointment Completed",
                      style: TextStyle(color: AppTheme.successGreen, fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ] else if (appt.effectiveStatus == 'cancelled') ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.red, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Cancelled: ${appt.cancellationReason ?? 'No reason provided'}",
                      style: const TextStyle(color: Colors.red, fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (appt.effectiveStatus != 'completed' && appt.effectiveStatus != 'cancelled') ...[
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => controller.confirmCancelAppointment(appt.id!),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    child: const Text("Cancel"),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => controller.updateAppointmentStatus(appt.id!, 'Completed'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      backgroundColor: AppTheme.primaryGreen,
                    ),
                    child: const Text("Complete", style: TextStyle(fontSize: 12)),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDoctorQuickActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Quick Actions",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildDoctorActionTile(Icons.calendar_month_outlined, "Calendar View", () => controller.navigateToCalendar()),
              const SizedBox(width: 12),
              _buildDoctorActionTile(Icons.add_task_rounded, "Add Slot", () => controller.showAddSlotDialog()),
              const SizedBox(width: 12),
              _buildDoctorActionTile(Icons.block, "Block Slot", () => controller.showBlockSlotDialog()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorActionTile(IconData icon, String label, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Column(
            children: [
              Icon(icon, color: AppTheme.primaryGreen, size: 24),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textDark),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime? date) {
    if (date == null) return "--:--";
    final hour = date.hour > 12 ? date.hour - 12 : date.hour;
    final ampm = date.hour >= 12 ? "PM" : "AM";
    final minute = date.minute.toString().padLeft(2, '0');
    return "${hour.toString().padLeft(2, '0')}:$minute $ampm";
  }

  String _formatDate(DateTime date) {
    final months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    return "${date.day} ${months[date.month - 1]}, ${date.year}";
  }
}

