// lib/app/modules/appointment/views/edit_appointment_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../viewmodels/edit_appointment_viewmodel.dart';

class EditAppointmentView extends GetView<EditAppointmentViewModel> {
  const EditAppointmentView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryGreen,
              AppTheme.deepGreen,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Enhanced Header
              _buildHeader(context),

              // Form Content
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(top: 20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                  ),
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.primaryGreen,
                        ),
                      );
                    }

                    if (controller.errorMessage.value.isNotEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: AppTheme.errorRed.withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              controller.errorMessage.value,
                              style: const TextStyle(color: AppTheme.textLight),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }

                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Doctor Name Field
                          _buildAnimatedField(
                            delay: 100,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('Doctor Name', Icons.person),
                                const SizedBox(height: 12),
                                Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8F9FA),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: const Color(0xFFE9ECEF),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: TextField(
                                    controller: controller.doctorNameController,
                                    style: const TextStyle(
                                      color: Color(0xFF1F2937),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Enter doctor\'s name',
                                      hintStyle: TextStyle(
                                        color: Colors.grey.shade400,
                                      ),
                                      prefixIcon: Icon(
                                        Icons.person_outline,
                                        color: AppTheme.primaryGreen,
                                      ),
                                      border: InputBorder.none,
                                      contentPadding: const EdgeInsets.all(16),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Specialty & Status Row
                          _buildAnimatedField(
                            delay: 200,
                            child: Row(
                              children: [
                                // Specialty
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildLabel('Specialty', Icons.medical_services),
                                      const SizedBox(height: 12),
                                      Obx(() => Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF8F9FA),
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(
                                            color: const Color(0xFFE9ECEF),
                                            width: 1.5,
                                          ),
                                        ),
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton<String>(
                                            value: controller.selectedSpecialty.value.isEmpty
                                                ? null
                                                : controller.selectedSpecialty.value,
                                            hint: Text(
                                              'Select',
                                              style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                                            ),
                                            isExpanded: true,
                                            icon: const Icon(Icons.arrow_drop_down, color: AppTheme.primaryGreen),
                                            style: const TextStyle(
                                              color: Color(0xFF1F2937),
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            items: controller.specialties.map((specialty) {
                                              return DropdownMenuItem(
                                                value: specialty,
                                                child: Text(
                                                  specialty,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              );
                                            }).toList(),
                                            onChanged: (value) {
                                              if (value != null) {
                                                controller.setSpecialty(value);
                                              }
                                            },
                                          ),
                                        ),
                                      )),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Status
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildLabel('Status', Icons.check_circle_outline),
                                      const SizedBox(height: 12),
                                      Obx(() => Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF8F9FA),
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(
                                            color: const Color(0xFFE9ECEF),
                                            width: 1.5,
                                          ),
                                        ),
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton<String>(
                                            value: controller.selectedStatus.value.isEmpty
                                                ? null
                                                : controller.selectedStatus.value,
                                            hint: Text('Status', style: TextStyle(color: Colors.grey.shade400)),
                                            isExpanded: true,
                                            icon: const Icon(Icons.arrow_drop_down, color: AppTheme.primaryGreen),
                                            style: const TextStyle(
                                              color: Color(0xFF1F2937),
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            items: controller.statuses.map((status) {
                                              return DropdownMenuItem(
                                                value: status,
                                                child: Text(status.capitalize!),
                                              );
                                            }).toList(),
                                            onChanged: (value) {
                                              if (value != null) {
                                                controller.setStatus(value);
                                              }
                                            },
                                          ),
                                        ),
                                      )),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Date & Time Row
                          _buildAnimatedField(
                            delay: 300,
                            child: Row(
                              children: [
                                // Date Picker
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildLabel('Date', Icons.calendar_today),
                                      const SizedBox(height: 12),
                                      Obx(() => InkWell(
                                        onTap: () => controller.pickDate(context),
                                        borderRadius: BorderRadius.circular(16),
                                        child: Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                AppTheme.primaryGreen.withValues(alpha: 0.1),
                                                AppTheme.deepGreen.withValues(alpha: 0.1),
                                              ],
                                            ),
                                            borderRadius: BorderRadius.circular(16),
                                            border: Border.all(
                                                color: AppTheme.primaryGreen.withValues(alpha: 0.3),
                                              width: 1.5,
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Icon(
                                                Icons.calendar_today_outlined,
                                                  color: AppTheme.primaryGreen,
                                                size: 20,
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                controller.selectedDate.value != null
                                                    ? DateFormat('MMM d').format(controller.selectedDate.value!)
                                                    : 'Select',
                                                style: TextStyle(
                                                  color: controller.selectedDate.value != null
                                                      ? const Color(0xFF1F2937)
                                                      : Colors.grey.shade400,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Time Picker
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildLabel('Time', Icons.access_time),
                                      const SizedBox(height: 12),
                                      Obx(() => InkWell(
                                        onTap: () => controller.pickTime(context),
                                        borderRadius: BorderRadius.circular(16),
                                        child: Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                AppTheme.deepGreen.withValues(alpha: 0.1),
                                                AppTheme.primaryGreen.withValues(alpha: 0.1),
                                              ],
                                            ),
                                            borderRadius: BorderRadius.circular(16),
                                            border: Border.all(
                                                color: AppTheme.deepGreen.withValues(alpha: 0.3),
                                              width: 1.5,
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Icon(
                                                Icons.access_time,
                                                  color: AppTheme.deepGreen,
                                                size: 20,
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                controller.selectedTime.value != null
                                                    ? controller.selectedTime.value!.format(context)
                                                    : 'Select',
                                                style: TextStyle(
                                                  color: controller.selectedTime.value != null
                                                      ? const Color(0xFF1F2937)
                                                      : Colors.grey.shade400,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Reason Field
                          _buildAnimatedField(
                            delay: 400,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('Reason for Visit', Icons.notes),
                                const SizedBox(height: 12),
                                Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8F9FA),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: const Color(0xFFE9ECEF),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: TextField(
                                    controller: controller.reasonController,
                                    maxLines: 4,
                                    style: const TextStyle(
                                      color: Color(0xFF1F2937),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Describe your symptoms or reason...',
                                      hintStyle: TextStyle(color: Colors.grey.shade400),
                                      border: InputBorder.none,
                                      contentPadding: const EdgeInsets.all(16),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Submit Button
                          _buildAnimatedField(
                            delay: 500,
                            child: Container(
                              width: double.infinity,
                              height: 56,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [AppTheme.primaryGreen, AppTheme.deepGreen],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.primaryGreen.withValues(alpha: 0.4),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Obx(() => ElevatedButton(
                                onPressed: controller.isSaving.value
                                    ? null
                                    : controller.updateAppointment,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: controller.isSaving.value
                                    ? const SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2.5,
                                        ),
                                      )
                                    : const Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.save_outlined, color: Colors.white),
                                          SizedBox(width: 12),
                                          Text(
                                            'Update Appointment',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ],
                                      ),
                              )),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 500),
      builder: (context, double value, child) {
        return Opacity(
          opacity: value,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                InkWell(
                  onTap: () => Get.back(),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Edit Appointment',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Modify booking details',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLabel(String text, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.primaryGreen),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedField({required int delay, required Widget child}) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 400 + delay),
      builder: (context, double value, _) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
    );
  }
}
