import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../viewmodels/profile_setup_view_model.dart';
import '../../../core/theme/app_theme.dart';

class ProfileSetupView extends StatelessWidget {
  ProfileSetupView({super.key});
  final ProfileSetupViewModel vm = Get.put(ProfileSetupViewModel());
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    // print('ProfileSetupView: Building view...');
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Profile Icon
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryGreen.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Title
                  Text(
                    'Setup Your Profile',
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tell us a bit about yourself',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 48),

                  // Profile Card
                  Container(
                    padding: const EdgeInsets.all(28),
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
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Avatar Placeholder with Image Picker
                          Center(
                            child: Stack(
                              children: [
                                Obx(() => Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    color: AppTheme.lightGreen,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppTheme.primaryGreen,
                                      width: 3,
                                    ),
                                    image: vm.selectedImage.value != null
                                        ? DecorationImage(
                                            image: NetworkImage(vm.selectedImage.value!.path),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                  ),
                                  child: vm.selectedImage.value == null
                                      ? const Icon(
                                          Icons.person,
                                          size: 50,
                                          color: AppTheme.primaryGreen,
                                        )
                                      : null,
                                )),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Obx(() => vm.isUploadingImage.value
                                      ? Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          ),
                                        )
                                      : GestureDetector(
                                          onTap: () {
                                            // Camera button tapped - pick image
                                            vm.pickImageFromGallery();
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              gradient: AppTheme.primaryGradient,
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: AppTheme.primaryGreen.withValues(alpha: 0.3),
                                                  blurRadius: 8,
                                                ),
                                              ],
                                            ),
                                            child: const Icon(
                                              Icons.camera_alt,
                                              size: 18,
                                              color: Colors.white,
                                            ),
                                          ),
                                        )),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Full Name Field
                          TextFormField(
                            controller: vm.fullNameController,
                            decoration: const InputDecoration(
                              labelText: 'Full Name',
                              hintText: 'Enter your full name',
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                            validator: (value) =>
                                value!.isEmpty ? 'Please enter your full name' : null,
                          ),
                          const SizedBox(height: 20),

                          // Gender Dropdown
                          Obx(() => DropdownButtonFormField<String>(
                            initialValue: vm.selectedGender.value.isEmpty ? null : vm.selectedGender.value,
                            decoration: const InputDecoration(
                              labelText: 'Gender',
                              hintText: 'Select your gender',
                              prefixIcon: Icon(Icons.wc),
                            ),
                            items: vm.genderOptions.map((String gender) {
                              return DropdownMenuItem<String>(
                                value: gender,
                                child: Text(gender),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                vm.setGender(newValue);
                              }
                            },
                            validator: (value) =>
                                value == null ? 'Please select your gender' : null,
                          )),
                          const SizedBox(height: 20),

                          // Phone Number Field
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Country Code Dropdown
                              Obx(() => SizedBox(
                                width: 95,
                                child: DropdownButtonFormField<String>(
                                  initialValue: vm.selectedCountryCode.value,
                                  decoration: const InputDecoration(
                                    labelText: 'Code',
                                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                                  ),
                                  items: vm.countryCodes.map((code) {
                                    return DropdownMenuItem<String>(
                                      value: code,
                                      child: Text(code),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    if (newValue != null) {
                                      vm.setCountryCode(newValue);
                                    }
                                  },
                                ),
                              )),
                              const SizedBox(width: 8),
                              // Phone Number Input
                              Expanded(
                                child: TextFormField(
                                  controller: vm.phoneController,
                                  decoration: const InputDecoration(
                                    labelText: 'Phone Number',
                                    hintText: '3001234567',
                                    prefixIcon: Icon(Icons.phone),
                                  ),
                                  keyboardType: TextInputType.phone,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  onChanged: (value) {
                                    vm.updatePhoneNumber();
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Required';
                                    }
                                    if (value.length < 7) {
                                      return 'Invalid number';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Role Dropdown
                          Obx(() => DropdownButtonFormField<String>(
                            initialValue: vm.selectedRole.value,
                            decoration: const InputDecoration(
                              labelText: 'Role',
                              hintText: 'Select your role',
                              prefixIcon: Icon(Icons.badge),
                            ),
                            items: vm.roleOptions.map((String role) {
                              return DropdownMenuItem<String>(
                                value: role,
                                child: Text(role),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                vm.setRole(newValue);
                              }
                            },
                          )),
                          const SizedBox(height: 20),

                          // Doctor-Specific Fields
                          Obx(() => vm.selectedRole.value == 'Doctor'
                              ? Column(
                                  children: [
                                    // Specialty
                                    TextFormField(
                                      controller: vm.specialtyController,
                                      decoration: const InputDecoration(
                                        labelText: 'Specialty',
                                        hintText: 'e.g. Cardiologist, Dermatologist',
                                        prefixIcon: Icon(Icons.medical_services_outlined),
                                      ),
                                      validator: (value) =>
                                          vm.selectedRole.value == 'Doctor' && (value == null || value.isEmpty)
                                              ? 'Specialty is required for doctors'
                                              : null,
                                    ),
                                    const SizedBox(height: 20),

                                    // Qualifications
                                    TextFormField(
                                      controller: vm.qualificationsController,
                                      decoration: const InputDecoration(
                                        labelText: 'Qualifications',
                                        hintText: 'e.g. MBBS, MD',
                                        prefixIcon: Icon(Icons.school_outlined),
                                      ),
                                      validator: (value) =>
                                          vm.selectedRole.value == 'Doctor' && (value == null || value.isEmpty)
                                              ? 'Qualifications are required'
                                              : null,
                                    ),
                                    const SizedBox(height: 20),

                                    // Experience
                                    TextFormField(
                                      controller: vm.experienceController,
                                      decoration: const InputDecoration(
                                        labelText: 'Experience',
                                        hintText: 'e.g. 10 years',
                                        prefixIcon: Icon(Icons.work_history_outlined),
                                      ),
                                      validator: (value) =>
                                          vm.selectedRole.value == 'Doctor' && (value == null || value.isEmpty)
                                              ? 'Experience is required'
                                              : null,
                                    ),
                                    const SizedBox(height: 20),

                                    // Consultation Fee
                                    TextFormField(
                                      controller: vm.consultationFeeController,
                                      decoration: const InputDecoration(
                                        labelText: 'Consultation Fee (Rs.)',
                                        hintText: 'e.g. 2000',
                                        prefixIcon: Icon(Icons.attach_money_rounded),
                                      ),
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                      validator: (value) =>
                                          vm.selectedRole.value == 'Doctor' && (value == null || value.isEmpty)
                                              ? 'Consultation fee is required'
                                              : null,
                                    ),
                                    const SizedBox(height: 20),

                                    // About
                                    TextFormField(
                                      controller: vm.aboutController,
                                      decoration: const InputDecoration(
                                        labelText: 'About / Bio',
                                        hintText: 'Briefly describe your expertise...',
                                        prefixIcon: Icon(Icons.info_outline_rounded),
                                      ),
                                      maxLines: 3,
                                      validator: (value) =>
                                          vm.selectedRole.value == 'Doctor' && (value == null || value.isEmpty)
                                              ? 'Please provide a brief bio'
                                              : null,
                                    ),
                                    const SizedBox(height: 20),
                                  ],
                                )
                              : const SizedBox.shrink()),

                          const SizedBox(height: 12),

                          // Save Button
                          Obx(() => vm.isLoading.value
                              ? const Center(
                                  child: CircularProgressIndicator(),
                                )
                              : Container(
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
                                  child: ElevatedButton(
                                    onPressed: () {
                                      if (_formKey.currentState!.validate()) {
                                        vm.completeProfile();
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    child: const Text(
                                      'Complete Profile',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                )),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
