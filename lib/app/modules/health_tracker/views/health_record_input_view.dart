// lib/app/modules/health_tracker/views/health_record_input_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/health_record_model.dart';
import '../viewmodels/health_tracker_viewmodel.dart';

class HealthRecordInputView extends StatefulWidget {
  final HealthRecordType type;
  const HealthRecordInputView({super.key, required this.type});

  @override
  State<HealthRecordInputView> createState() => _HealthRecordInputViewState();
}

class _HealthRecordInputViewState extends State<HealthRecordInputView> {
  final HealthTrackerViewModel controller = Get.find<HealthTrackerViewModel>();
  
  // Controllers for various inputs
  final TextEditingController weightController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController systolicController = TextEditingController();
  final TextEditingController diastolicController = TextEditingController();
  final TextEditingController valueController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  
  String selectedGender = 'Male';
  String selectedSugarContext = 'Fasting';
  double? calculatedBMI;
  String? bmiCategory;

  @override
  void initState() {
    super.initState();
    // Pre-fill if we have latest values
    final latest = controller.latestRecords[widget.type];
    if (latest != null) {
      if (widget.type == HealthRecordType.weight) {
        weightController.text = latest.weight?.toString() ?? '';
      } else if (widget.type == HealthRecordType.bmi) {
        weightController.text = latest.data['weight']?.toString() ?? '';
        heightController.text = latest.data['height']?.toString() ?? '';
        ageController.text = latest.data['age']?.toString() ?? '';
        selectedGender = latest.data['gender'] ?? 'Male';
      }
    }
  }

  @override
  void dispose() {
    weightController.dispose();
    heightController.dispose();
    ageController.dispose();
    systolicController.dispose();
    diastolicController.dispose();
    valueController.dispose();
    notesController.dispose();
    super.dispose();
  }

  void _onSave() {
    Map<String, dynamic> data = {};
    
    switch (widget.type) {
      case HealthRecordType.bmi:
        double weight = double.tryParse(weightController.text) ?? 0;
        double height = double.tryParse(heightController.text) ?? 0;
        double bmi = controller.calculateBMI(weight, height);
        String cat = controller.getBMICategory(bmi);
        data = {
          'weight': weight,
          'height': height,
          'age': int.tryParse(ageController.text) ?? 0,
          'gender': selectedGender,
          'bmi': bmi,
          'category': cat,
        };
        break;
      case HealthRecordType.bloodPressure:
        data = {
          'systolic': int.tryParse(systolicController.text) ?? 0,
          'diastolic': int.tryParse(diastolicController.text) ?? 0,
        };
        break;
      case HealthRecordType.sugarLevel:
        data = {
          'value': double.tryParse(valueController.text) ?? 0,
          'context': selectedSugarContext,
        };
        break;
      default:
        data = {
          'value': double.tryParse(valueController.text) ?? 0,
        };
    }

    controller.saveRecord(
      type: widget.type,
      data: data,
      notes: notesController.text.isNotEmpty ? notesController.text : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    String title = widget.type.toString().split('.').last.replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(1)}').capitalizeFirst!;
    if (widget.type == HealthRecordType.bmi) title = 'BMI Calculator';

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildInputForm(),
            const SizedBox(height: 32),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildInputForm() {
    switch (widget.type) {
      case HealthRecordType.bmi:
        return _buildBMIForm();
      case HealthRecordType.bloodPressure:
        return _buildBPForm();
      case HealthRecordType.sugarLevel:
        return _buildSugarForm();
      default:
        return _buildSimpleForm();
    }
  }

  Widget _buildBMIForm() {
    return Column(
      children: [
        _buildGenderSelector(),
        const SizedBox(height: 20),
        _buildTextField('Age', ageController, Icons.calendar_today, 'years'),
        const SizedBox(height: 20),
        _buildTextField('Height', heightController, Icons.height, 'cm'),
        const SizedBox(height: 20),
        _buildTextField('Weight', weightController, Icons.monitor_weight_outlined, 'kg'),
        const SizedBox(height: 30),
        _buildBMICalculatorOutput(),
      ],
    );
  }

  Widget _buildGenderSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gender',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildGenderOption('Male', Icons.male_rounded, Colors.blue),
            const SizedBox(width: 16),
            _buildGenderOption('Female', Icons.female_rounded, Colors.pink),
          ],
        ),
      ],
    );
  }

  Widget _buildGenderOption(String gender, IconData icon, Color color) {
    bool isSelected = selectedGender == gender;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedGender = gender),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.1) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? color : Colors.grey.shade200,
              width: 2,
            ),
            boxShadow: isSelected ? [
              BoxShadow(
                color: color.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ] : [],
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? color : Colors.grey.shade400,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                gender,
                style: GoogleFonts.inter(
                  color: isSelected ? color : Colors.grey.shade600,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBMICalculatorOutput() {
    double w = double.tryParse(weightController.text) ?? 0;
    double h = double.tryParse(heightController.text) ?? 0;
    if (w > 0 && h > 0) {
      double bmi = controller.calculateBMI(w, h);
      String cat = controller.getBMICategory(bmi);
      Color color = controller.getBMIColor(cat);
      
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withOpacity(0.2), width: 1.5),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your BMI',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textLight,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    bmi.toStringAsFixed(1),
                    style: GoogleFonts.poppins(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                cat,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildBPForm() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildTextField('Systolic', systolicController, Icons.arrow_upward, 'mmHg')),
            const SizedBox(width: 16),
            Expanded(child: _buildTextField('Diastolic', diastolicController, Icons.arrow_downward, 'mmHg')),
          ],
        ),
        const SizedBox(height: 20),
        _buildTextField('Notes (Optional)', notesController, Icons.notes, ''),
      ],
    );
  }

  Widget _buildSugarForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField('Sugar Level', valueController, Icons.water_drop_outlined, 'mg/dL'),
        const SizedBox(height: 20),
        const Text('Context', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          children: ['Fasting', 'Fasting (8h+)', 'Random', 'Post-meal (1h)', 'Post-meal (2h)'].map((ctx) {
            bool isSelected = selectedSugarContext == ctx;
            return ChoiceChip(
              label: Text(ctx),
              selected: isSelected,
              onSelected: (val) {
                if (val) setState(() => selectedSugarContext = ctx);
              },
              selectedColor: AppTheme.primaryBlue.withOpacity(0.2),
              backgroundColor: Colors.white,
              labelStyle: TextStyle(color: isSelected ? AppTheme.primaryBlue : Colors.grey),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSimpleForm() {
    String unit = '';
    IconData icon = Icons.edit;
    
    switch (widget.type) {
      case HealthRecordType.bodyTemperature:
        unit = '°C'; icon = Icons.thermostat_outlined; break;
      case HealthRecordType.oxygenSaturation:
        unit = '%'; icon = Icons.air_outlined; break;
      case HealthRecordType.hemoglobin:
        unit = 'g/dL'; icon = Icons.bloodtype_outlined; break;
      case HealthRecordType.weight:
        unit = 'kg'; icon = Icons.monitor_weight_outlined; break;
      default: break;
    }

    return Column(
      children: [
        _buildTextField('Enter Value', valueController, icon, unit),
        const SizedBox(height: 20),
        _buildTextField('Notes (Optional)', notesController, Icons.notes, ''),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController textCtrl, IconData icon, String suffix) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: textCtrl,
          keyboardType: TextInputType.number,
          onChanged: (v) => setState(() {}),
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppTheme.textDark,
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppTheme.primaryGreen, size: 20),
            suffixText: suffix,
            suffixStyle: GoogleFonts.inter(color: AppTheme.textLight, fontWeight: FontWeight.bold),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.all(18),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppTheme.primaryGreen, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return Obx(() => Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryGreen.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: controller.isLoading.value ? null : _onSave,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryGreen,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          elevation: 0,
        ),
        child: controller.isLoading.value
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
              )
            : Text(
                'Save Health Record',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    ));
  }
}
