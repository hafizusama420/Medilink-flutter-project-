// lib/app/modules/health_tracker/views/health_tracker_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../viewmodels/health_tracker_viewmodel.dart';
import '../../../models/health_record_model.dart';
import 'health_record_input_view.dart';

class HealthTrackerView extends GetView<HealthTrackerViewModel> {
  const HealthTrackerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Health Tracker', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.refreshRecords(),
        color: AppTheme.primaryGreen,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Obx(() {
                if (controller.targetPatientName.value != null) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 24),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.person, color: AppTheme.primaryBlue),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Recording Vitals for:', style: TextStyle(fontSize: 12, color: AppTheme.textLight)),
                              Text(
                                controller.targetPatientName.value!,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),
              _buildTrackerCard(
                context,
                type: HealthRecordType.bmi,
                title: 'BMI',
                description: 'Calculate Your BMI Quick and Easy!',
                icon: Icons.monitor_weight_outlined,
                color: Colors.orange,
              ),
              const SizedBox(height: 16),
              _buildTrackerCard(
                context,
                type: HealthRecordType.bloodPressure,
                title: 'Blood Pressure',
                description: 'Track Your Blood Pressure',
                icon: Icons.favorite_outline,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              _buildTrackerCard(
                context,
                type: HealthRecordType.sugarLevel,
                title: 'Sugar level',
                description: 'Track Your Sugar Level',
                icon: Icons.water_drop_outlined,
                color: Colors.blue,
              ),
              const SizedBox(height: 16),
              _buildTrackerCard(
                context,
                type: HealthRecordType.bodyTemperature,
                title: 'Body Temperature',
                description: 'Track Your Body Temperature',
                icon: Icons.thermostat_outlined,
                color: Colors.orangeAccent,
              ),
              const SizedBox(height: 16),
              _buildTrackerCard(
                context,
                type: HealthRecordType.oxygenSaturation,
                title: 'Blood Oxygen Saturation',
                description: 'Track Your Blood Oxygen Saturation',
                icon: Icons.air_outlined,
                color: Colors.blueAccent,
              ),
              const SizedBox(height: 16),
              _buildTrackerCard(
                context,
                type: HealthRecordType.hemoglobin,
                title: 'Hemoglobin',
                description: 'Track Your Hemoglobin',
                icon: Icons.bloodtype_outlined,
                color: Colors.redAccent,
              ),
              const SizedBox(height: 16),
              _buildTrackerCard(
                context,
                type: HealthRecordType.weight,
                title: 'Weight',
                description: 'Track Your Weight',
                icon: Icons.speed_outlined,
                color: Colors.green,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrackerCard(
    BuildContext context, {
    required HealthRecordType type,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () => Get.to(() => HealthRecordInputView(type: type)),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(color: color.withOpacity(0.1), width: 1.5),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Highlight Bar
                Container(
                  width: 6,
                  color: color,
                ),
                // Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppTheme.textLight,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Obx(() {
                            final displayValue = controller.getDisplayValue(type);
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.history, size: 14, color: color),
                                const SizedBox(width: 6),
                                Text(
                                  displayValue,
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: color,
                                  ),
                                ),
                              ],
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ),
                // Icon Section
                Container(
                  width: 100,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.05),
                  ),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: color.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(icon, color: color, size: 28),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
