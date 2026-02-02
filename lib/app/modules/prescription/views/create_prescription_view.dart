// lib/app/modules/prescription/views/create_prescription_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../viewmodels/create_prescription_viewmodel.dart';

class CreatePrescriptionView extends GetView<CreatePrescriptionViewModel> {
  const CreatePrescriptionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(controller.mode == 'edit' ? 'Edit Prescription' : 'Create Prescription'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPatientInfo(),
              const SizedBox(height: 24),
              _buildDiagnosisSection(),
              const SizedBox(height: 24),
              _buildMedicationsSection(),
              const SizedBox(height: 24),
              _buildInstructionsSection(),
              const SizedBox(height: 24),
              _buildFollowUpSection(),
              const SizedBox(height: 24),
              _buildAdditionalNotesSection(),
              const SizedBox(height: 32),
              _buildSaveButton(),
              const SizedBox(height: 40),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildPatientInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryGreen.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryGreen.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Patient Information',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.person, color: AppTheme.primaryGreen, size: 20),
              const SizedBox(width: 8),
              Text(
                controller.patientName ?? 'Unknown Patient',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          if (controller.patientAge != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.cake, color: AppTheme.primaryGreen, size: 20),
                const SizedBox(width: 8),
                Text(
                  '${controller.patientAge} years old',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDiagnosisSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Diagnosis & Symptoms',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: controller.diagnosisController,
          decoration: InputDecoration(
            labelText: 'Diagnosis *',
            hintText: 'e.g., Viral Upper Respiratory Tract Infection',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: const Icon(Icons.medical_services, color: AppTheme.primaryGreen),
          ),
          maxLines: 2,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: controller.symptomsController,
          decoration: InputDecoration(
            labelText: 'Symptoms',
            hintText: 'e.g., Fever, Cough, Body aches',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: const Icon(Icons.sick, color: AppTheme.primaryGreen),
          ),
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildMedicationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Medications',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
            ElevatedButton.icon(
              onPressed: controller.showAddMedicationDialog,
              icon: const Icon(Icons.add, size: 20),
              label: const Text('Add'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Obx(() {
          if (controller.medications.isEmpty) {
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const Center(
                child: Text(
                  'No medications added yet.\nTap "Add" to add medications.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            );
          }

          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.medications.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final medication = controller.medications[index];
              return _buildMedicationCard(medication, index);
            },
          );
        }),
      ],
    );
  }

  Widget _buildMedicationCard(medication, int index) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryGreen.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '${index + 1}. ${medication.name} ${medication.strength}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () => controller.showEditMedicationDialog(index),
                    icon: const Icon(Icons.edit, size: 20),
                    color: AppTheme.primaryBlue,
                  ),
                  IconButton(
                    onPressed: () => controller.removeMedication(medication.id!),
                    icon: const Icon(Icons.delete, size: 20),
                    color: Colors.red,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildMedicationDetail(Icons.medication, 'Form', medication.form ?? '-'),
          _buildMedicationDetail(Icons.local_hospital, 'Dosage', medication.dosage ?? '-'),
          _buildMedicationDetail(Icons.access_time, 'Frequency', medication.frequency ?? '-'),
          _buildMedicationDetail(Icons.calendar_today, 'Duration', medication.duration ?? '-'),
          _buildMedicationDetail(Icons.restaurant, 'Timing', medication.timing ?? '-'),
          _buildMedicationDetail(Icons.shopping_cart, 'Quantity', '${medication.quantity ?? 0}'),
          if (medication.instructions != null && medication.instructions!.isNotEmpty)
            _buildMedicationDetail(Icons.info_outline, 'Instructions', medication.instructions!),
        ],
      ),
    );
  }

  Widget _buildMedicationDetail(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppTheme.primaryGreen),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.textLight,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, color: AppTheme.textDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'General Instructions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: controller.generalInstructionsController,
          decoration: InputDecoration(
            labelText: 'Instructions for Patient',
            hintText: 'e.g., Get adequate rest, Drink plenty of fluids...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: const Icon(Icons.list_alt, color: AppTheme.primaryGreen),
          ),
          maxLines: 5,
        ),
      ],
    );
  }

  Widget _buildFollowUpSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Follow-up',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 12),
        Obx(() => SwitchListTile(
              title: const Text('Follow-up Required'),
              value: controller.followUpRequired.value,
              onChanged: controller.toggleFollowUp,
              activeColor: AppTheme.primaryGreen,
              contentPadding: EdgeInsets.zero,
            )),
        Obx(() {
          if (!controller.followUpRequired.value) {
            return const SizedBox.shrink();
          }

          return Column(
            children: [
              const SizedBox(height: 12),
              InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: Get.context!,
                    initialDate: DateTime.now().add(const Duration(days: 7)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    controller.setFollowUpDate(date);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, color: AppTheme.primaryGreen),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          controller.followUpDate.value != null
                              ? DateFormat('MMM d, yyyy').format(controller.followUpDate.value!)
                              : 'Select Follow-up Date',
                          style: TextStyle(
                            fontSize: 15,
                            color: controller.followUpDate.value != null
                                ? AppTheme.textDark
                                : Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Obx(() => DropdownButtonFormField<String>(
                    value: controller.followUpType.value,
                    decoration: InputDecoration(
                      labelText: 'Follow-up Type',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.video_call, color: AppTheme.primaryGreen),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'in-person', child: Text('In-person')),
                      DropdownMenuItem(value: 'video', child: Text('Video Call')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        controller.setFollowUpType(value);
                      }
                    },
                  )),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildAdditionalNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Additional Notes',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: controller.additionalNotesController,
          decoration: InputDecoration(
            labelText: 'Notes (Optional)',
            hintText: 'e.g., Patient allergies, special considerations...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: const Icon(Icons.note_alt, color: AppTheme.primaryGreen),
          ),
          maxLines: 4,
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: controller.savePrescription,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryGreen,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          controller.mode == 'edit' ? 'Update Prescription' : 'Create Prescription',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
