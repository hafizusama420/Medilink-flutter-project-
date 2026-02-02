// lib/app/modules/prescription/viewmodels/create_prescription_viewmodel.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/user_service.dart';
import '../../../models/prescription_model.dart';
import '../../../models/medication_model.dart';
import '../../../models/appointment_model.dart';
import '../../../services/prescription_service.dart';

class CreatePrescriptionViewModel extends GetxController {
  final PrescriptionService _prescriptionService = PrescriptionService();
  final UserService _userService = UserService();
  final AuthService _authService = Get.find<AuthService>();

  // Form controllers
  final diagnosisController = TextEditingController();
  final symptomsController = TextEditingController();
  final generalInstructionsController = TextEditingController();
  final additionalNotesController = TextEditingController();

  // Observable variables
  final isLoading = false.obs;
  final followUpRequired = false.obs;
  final followUpDate = Rx<DateTime?>(null);
  final followUpType = 'in-person'.obs;
  final medications = <MedicationModel>[].obs;

  // Appointment/Edit data
  String mode = 'create'; // 'create' or 'edit'
  PrescriptionModel? existingPrescription;
  AppointmentModel? appointment;
  String? patientId;
  String? patientName;
  int? patientAge;

  @override
  void onInit() {
    super.onInit();
    // Get data from arguments
    if (Get.arguments != null) {
      mode = Get.arguments['mode'] ?? 'create';
      existingPrescription = Get.arguments['prescription'] as PrescriptionModel?;
      
      if (mode == 'edit' && existingPrescription != null) {
        _prefillForm();
      } else {
        appointment = Get.arguments['appointment'] as AppointmentModel?;
        patientId = Get.arguments['patientId'] as String?;
        patientName = Get.arguments['patientName'] as String?;
        patientAge = Get.arguments['patientAge'] as int?;
      }
    }
  }

  /// Pre-fill form with existing prescription data
  void _prefillForm() {
    if (existingPrescription == null) return;

    diagnosisController.text = existingPrescription!.diagnosis ?? '';
    symptomsController.text = existingPrescription!.symptoms ?? '';
    generalInstructionsController.text = existingPrescription!.generalInstructions ?? '';
    additionalNotesController.text = existingPrescription!.additionalNotes ?? '';

    medications.assignAll(existingPrescription!.medications ?? []);
    
    followUpRequired.value = existingPrescription!.followUpRequired ?? false;
    followUpDate.value = existingPrescription!.followUpDate;
    followUpType.value = existingPrescription!.followUpType ?? 'in-person';
    
    patientId = existingPrescription!.patientId;
    patientName = existingPrescription!.patientName;
    patientAge = existingPrescription!.patientAge;
  }

  @override
  void onClose() {
    diagnosisController.dispose();
    symptomsController.dispose();
    generalInstructionsController.dispose();
    additionalNotesController.dispose();
    super.onClose();
  }

  /// Add a new medication to the list
  void addMedication(MedicationModel medication) {
    medication.id = DateTime.now().millisecondsSinceEpoch.toString();
    medications.add(medication);
  }

  /// Remove medication from the list
  void removeMedication(String medicationId) {
    medications.removeWhere((med) => med.id == medicationId);
  }

  /// Update medication in the list
  void updateMedication(int index, MedicationModel medication) {
    if (index >= 0 && index < medications.length) {
      medications[index] = medication;
      medications.refresh();
    }
  }

  /// Toggle follow-up requirement
  void toggleFollowUp(bool value) {
    followUpRequired.value = value;
    if (!value) {
      followUpDate.value = null;
    }
  }

  /// Set follow-up date
  void setFollowUpDate(DateTime date) {
    followUpDate.value = date;
  }

  /// Set follow-up type
  void setFollowUpType(String type) {
    followUpType.value = type;
  }

  /// Validate prescription data
  bool validatePrescription() {
    if (diagnosisController.text.trim().isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Please enter diagnosis',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    if (medications.isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Please add at least one medication',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    if (followUpRequired.value && followUpDate.value == null) {
      Get.snackbar(
        'Validation Error',
        'Please select follow-up date',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    return true;
  }

  /// Save prescription (create or update)
  Future<void> savePrescription() async {
    if (mode == 'edit') {
      await _updatePrescription();
    } else {
      await createPrescription();
    }
  }

  /// Create and save prescription
  Future<void> createPrescription() async {
    if (!validatePrescription()) return;

    try {
      isLoading.value = true;

      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Fetch doctor's full profile from Firestore
      final doctorProfile = await _userService.getUserProfile(currentUser.uid);
      if (doctorProfile == null) {
        throw Exception('Doctor profile not found');
      }

      // Calculate expiry date (longest medication duration + 7 days buffer)
      DateTime expiryDate = DateTime.now().add(const Duration(days: 7));
      for (var med in medications) {
        if (med.duration != null) {
          final days = _parseDurationToDays(med.duration!);
          final medExpiry = DateTime.now().add(Duration(days: days + 7));
          if (medExpiry.isAfter(expiryDate)) {
            expiryDate = medExpiry;
          }
        }
      }

      final prescription = PrescriptionModel(
        appointmentId: appointment?.id,
        doctorId: doctorProfile.uid,
        doctorName: doctorProfile.fullName,
        doctorSpecialty: doctorProfile.specialty,
        doctorLicense: doctorProfile.qualifications, // Using qualifications as license
        patientId: patientId ?? appointment?.userId,
        patientName: patientName ?? appointment?.patientName,
        patientAge: patientAge,
        prescribedDate: DateTime.now(),
        expiryDate: expiryDate,
        diagnosis: diagnosisController.text.trim(),
        symptoms: symptomsController.text.trim(),
        medications: medications.toList(),
        generalInstructions: generalInstructionsController.text.trim(),
        additionalNotes: additionalNotesController.text.trim(),
        followUpRequired: followUpRequired.value,
        followUpDate: followUpDate.value,
        followUpType: followUpType.value,
        status: 'active',
      );

      await _prescriptionService.createPrescription(prescription);

      Get.snackbar(
        'Success',
        'Prescription created successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Go back to previous screen
      Get.back(result: true);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to create prescription: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Update existing prescription
  Future<void> _updatePrescription() async {
    if (!validatePrescription()) return;
    if (existingPrescription == null) return;

    try {
      isLoading.value = true;

      // Update basic info
      existingPrescription!.diagnosis = diagnosisController.text.trim();
      existingPrescription!.symptoms = symptomsController.text.trim();
      existingPrescription!.medications = medications.toList();
      existingPrescription!.generalInstructions = generalInstructionsController.text.trim();
      existingPrescription!.additionalNotes = additionalNotesController.text.trim();
      existingPrescription!.followUpRequired = followUpRequired.value;
      existingPrescription!.followUpDate = followUpDate.value;
      existingPrescription!.followUpType = followUpType.value;
      existingPrescription!.updatedAt = DateTime.now();

      // Recalculate expiry if medications changed
      DateTime expiryDate = DateTime.now().add(const Duration(days: 7));
      for (var med in medications) {
        if (med.duration != null) {
          final days = _parseDurationToDays(med.duration!);
          final medExpiry = DateTime.now().add(Duration(days: days + 7));
          if (medExpiry.isAfter(expiryDate)) {
            expiryDate = medExpiry;
          }
        }
      }
      existingPrescription!.expiryDate = expiryDate;

      await _prescriptionService.updatePrescription(existingPrescription!);

      Get.snackbar(
        'Success',
        'Prescription updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Go back
      Get.back(result: true);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update prescription: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Parse duration string to days (e.g., "5 days" -> 5, "2 weeks" -> 14)
  int _parseDurationToDays(String duration) {
    final lowerDuration = duration.toLowerCase();
    final numbers = RegExp(r'\d+').allMatches(lowerDuration);
    
    if (numbers.isEmpty) return 7; // Default 7 days

    final number = int.parse(numbers.first.group(0)!);

    if (lowerDuration.contains('week')) {
      return number * 7;
    } else if (lowerDuration.contains('month')) {
      return number * 30;
    } else {
      return number; // Assume days
    }
  }

  /// Show add medication dialog
  void showAddMedicationDialog() {
    Get.dialog(
      AddMedicationDialog(
        onAdd: (medication) {
          addMedication(medication);
        },
      ),
    );
  }

  /// Show edit medication dialog
  void showEditMedicationDialog(int index) {
    Get.dialog(
      AddMedicationDialog(
        medication: medications[index],
        onAdd: (medication) {
          updateMedication(index, medication);
        },
      ),
    );
  }
}

/// Add Medication Dialog Widget
class AddMedicationDialog extends StatefulWidget {
  final MedicationModel? medication;
  final Function(MedicationModel) onAdd;

  const AddMedicationDialog({
    super.key,
    this.medication,
    required this.onAdd,
  });

  @override
  State<AddMedicationDialog> createState() => _AddMedicationDialogState();
}

class _AddMedicationDialogState extends State<AddMedicationDialog> {
  late TextEditingController nameController;
  late TextEditingController strengthController;
  late TextEditingController dosageController;
  late TextEditingController frequencyController;
  late TextEditingController durationController;
  late TextEditingController instructionsController;
  late TextEditingController quantityController;

  String selectedForm = 'Tablet';
  String selectedTiming = 'After meals';
  bool beforeMeal = false;
  bool afterMeal = true;

  final List<String> medicationForms = [
    'Tablet',
    'Capsule',
    'Syrup',
    'Injection',
    'Drops',
    'Ointment',
    'Cream',
    'Inhaler',
  ];

  final List<String> timingOptions = [
    'After meals',
    'Before meals',
    'At night',
    'Morning',
    'Anytime',
  ];

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.medication?.name);
    strengthController = TextEditingController(text: widget.medication?.strength);
    dosageController = TextEditingController(text: widget.medication?.dosage);
    frequencyController = TextEditingController(text: widget.medication?.frequency);
    durationController = TextEditingController(text: widget.medication?.duration);
    instructionsController = TextEditingController(text: widget.medication?.instructions);
    quantityController = TextEditingController(
      text: widget.medication?.quantity?.toString(),
    );

    if (widget.medication != null) {
      selectedForm = widget.medication!.form ?? 'Tablet';
      selectedTiming = widget.medication!.timing ?? 'After meals';
      beforeMeal = widget.medication!.beforeMeal ?? false;
      afterMeal = widget.medication!.afterMeal ?? true;
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    strengthController.dispose();
    dosageController.dispose();
    frequencyController.dispose();
    durationController.dispose();
    instructionsController.dispose();
    quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.medication == null ? 'Add Medication' : 'Edit Medication'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Medicine Name *',
                hintText: 'e.g., Paracetamol',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: strengthController,
              decoration: const InputDecoration(
                labelText: 'Strength *',
                hintText: 'e.g., 500mg',
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: selectedForm,
              decoration: const InputDecoration(labelText: 'Form'),
              items: medicationForms.map((form) {
                return DropdownMenuItem(value: form, child: Text(form));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedForm = value!;
                });
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: dosageController,
              decoration: const InputDecoration(
                labelText: 'Dosage *',
                hintText: 'e.g., 1 tablet, 10ml',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: frequencyController,
              decoration: const InputDecoration(
                labelText: 'Frequency *',
                hintText: 'e.g., 3 times daily, Once daily',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: durationController,
              decoration: const InputDecoration(
                labelText: 'Duration *',
                hintText: 'e.g., 5 days, 2 weeks',
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: selectedTiming,
              decoration: const InputDecoration(labelText: 'Timing'),
              items: timingOptions.map((timing) {
                return DropdownMenuItem(value: timing, child: Text(timing));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedTiming = value!;
                });
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Quantity *',
                hintText: 'Total quantity',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: instructionsController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Special Instructions',
                hintText: 'e.g., Take with plenty of water',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (nameController.text.trim().isEmpty ||
                strengthController.text.trim().isEmpty ||
                dosageController.text.trim().isEmpty ||
                frequencyController.text.trim().isEmpty ||
                durationController.text.trim().isEmpty ||
                quantityController.text.trim().isEmpty) {
              Get.snackbar(
                'Validation Error',
                'Please fill all required fields',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.red,
                colorText: Colors.white,
              );
              return;
            }

            final medication = MedicationModel(
              id: widget.medication?.id,
              name: nameController.text.trim(),
              strength: strengthController.text.trim(),
              form: selectedForm,
              dosage: dosageController.text.trim(),
              frequency: frequencyController.text.trim(),
              duration: durationController.text.trim(),
              timing: selectedTiming,
              instructions: instructionsController.text.trim(),
              quantity: int.tryParse(quantityController.text.trim()),
              beforeMeal: beforeMeal,
              afterMeal: afterMeal,
            );

            widget.onAdd(medication);
            Get.back();
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
