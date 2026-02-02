// lib/app/modules/prescription/views/prescription_detail_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../viewmodels/prescription_detail_viewmodel.dart';

class PrescriptionDetailView extends GetView<PrescriptionDetailViewModel> {
  const PrescriptionDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prescription Details'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        actions: [
          // Show edit and delete only for doctors
          Obx(() {
            if (controller.isDoctor) {
              return Row(
                children: [
                  IconButton(
                    onPressed: controller.editPrescription,
                    icon: const Icon(Icons.edit),
                    tooltip: 'Edit Prescription',
                  ),
                  IconButton(
                    onPressed: controller.confirmDelete,
                    icon: const Icon(Icons.delete),
                    tooltip: 'Delete Prescription',
                    color: Colors.red.shade100,
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          }),
          IconButton(
            onPressed: controller.downloadPDF,
            icon: const Icon(Icons.download),
            tooltip: 'Download PDF',
          ),
          IconButton(
            onPressed: controller.sharePrescription,
            icon: const Icon(Icons.share),
            tooltip: 'Share',
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return _buildErrorState();
        }

        if (controller.prescription.value == null) {
          return const Center(child: Text('Prescription not found'));
        }

        final prescription = controller.prescription.value!;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(prescription),
              const SizedBox(height: 20),
              _buildDiagnosisSection(prescription),
              const SizedBox(height: 20),
              _buildMedicationsSection(prescription),
              const SizedBox(height: 20),
              if (prescription.generalInstructions != null &&
                  prescription.generalInstructions!.isNotEmpty)
                _buildInstructionsSection(prescription),
              const SizedBox(height: 20),
              if (prescription.followUpRequired == true)
                _buildFollowUpSection(prescription),
              const SizedBox(height: 20),
              if (prescription.additionalNotes != null &&
                  prescription.additionalNotes!.isNotEmpty)
                _buildNotesSection(prescription),
              const SizedBox(height: 40),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildHeader(prescription) {
    final dateFormat = DateFormat('MMM d, yyyy, h:mm a');
    final isActive = prescription.isActive;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryGreen,
            AppTheme.deepGreen,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryGreen.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.medical_services,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      controller.isDoctor
                          ? (prescription.patientName ?? 'Unknown Patient')
                          : (prescription.doctorName ?? 'Unknown Doctor'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      controller.isDoctor
                          ? 'Patient'
                          : (prescription.doctorSpecialty ?? 'Specialist'),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isActive
                      ? Colors.white.withValues(alpha: 0.2)
                      : Colors.red.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  isActive ? 'ACTIVE' : 'EXPIRED',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 1,
            color: Colors.white.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildHeaderInfo(
                  Icons.calendar_today,
                  'Prescribed',
                  prescription.prescribedDate != null
                      ? dateFormat.format(prescription.prescribedDate!)
                      : 'N/A',
                ),
              ),
            ],
          ),
          if (prescription.expiryDate != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildHeaderInfo(
                    Icons.access_time,
                    'Valid Until',
                    dateFormat.format(prescription.expiryDate!),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHeaderInfo(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 16),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 11,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDiagnosisSection(prescription) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.medical_information, color: AppTheme.primaryGreen, size: 20),
              SizedBox(width: 8),
              Text(
                'Diagnosis',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            prescription.diagnosis ?? 'No diagnosis provided',
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textDark,
            ),
          ),
          if (prescription.symptoms != null && prescription.symptoms!.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Text(
              'Symptoms:',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.textLight,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              prescription.symptoms!,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textDark,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMedicationsSection(prescription) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.medication, color: AppTheme.primaryGreen, size: 20),
            const SizedBox(width: 8),
            Text(
              'Medications (${prescription.medicationCount})',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: prescription.medications?.length ?? 0,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final medication = prescription.medications![index];
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.primaryGreen.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              color: AppTheme.primaryGreen,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${medication.name} ${medication.strength}',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textDark,
                              ),
                            ),
                            Text(
                              medication.form ?? '',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.textLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!controller.isDoctor)
                        IconButton(
                          onPressed: () => controller.setMedicationReminder(medication.id!),
                          icon: const Icon(Icons.alarm_add, size: 20),
                          color: AppTheme.primaryGreen,
                          tooltip: 'Set Reminder',
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildMedicationDetail('Dosage', medication.dosage ?? '-'),
                  _buildMedicationDetail('Frequency', medication.frequency ?? '-'),
                  _buildMedicationDetail('Duration', medication.duration ?? '-'),
                  _buildMedicationDetail('Timing', medication.timing ?? '-'),
                  _buildMedicationDetail('Quantity', '${medication.quantity ?? 0}'),
                  if (medication.instructions != null && medication.instructions!.isNotEmpty)
                    _buildMedicationDetail('Instructions', medication.instructions!),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildMedicationDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.textLight,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionsSection(prescription) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryBlue.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.list_alt, color: AppTheme.primaryBlue, size: 20),
              SizedBox(width: 8),
              Text(
                'General Instructions',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            prescription.generalInstructions!,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFollowUpSection(prescription) {
    final dateFormat = DateFormat('MMM d, yyyy');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.accentGreen.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.accentGreen.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.event_repeat, color: AppTheme.accentGreen, size: 20),
              SizedBox(width: 8),
              Text(
                'Follow-up Required',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (prescription.followUpDate != null)
            Text(
              'Date: ${dateFormat.format(prescription.followUpDate!)}',
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textDark,
              ),
            ),
          if (prescription.followUpType != null)
            Text(
              'Type: ${prescription.followUpType!.isNotEmpty ? prescription.followUpType![0].toUpperCase() + prescription.followUpType!.substring(1) : ""}',
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textDark,
              ),
            ),
          if (!controller.isDoctor) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: controller.bookFollowUpAppointment,
                icon: const Icon(Icons.calendar_month, size: 18),
                label: const Text('Book Follow-up Appointment'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNotesSection(prescription) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.warning_amber, color: Colors.amber, size: 20),
              SizedBox(width: 8),
              Text(
                'Important Notes',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            prescription.additionalNotes!,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              controller.errorMessage.value,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: controller.loadPrescription,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
