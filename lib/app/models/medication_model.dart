// lib/app/models/medication_model.dart

class MedicationModel {
  String? id;
  String? name;
  String? strength; // e.g., "500mg", "10mg"
  String? form; // tablet, syrup, injection, capsule, etc.
  String? dosage; // e.g., "1 tablet", "10ml"
  String? frequency; // e.g., "3 times daily", "Once daily"
  String? duration; // e.g., "5 days", "2 weeks"
  String? timing; // e.g., "After meals", "Before meals", "At night"
  String? instructions; // Special instructions
  int? quantity; // Total quantity prescribed
  bool? beforeMeal;
  bool? afterMeal;

  MedicationModel({
    this.id,
    this.name,
    this.strength,
    this.form,
    this.dosage,
    this.frequency,
    this.duration,
    this.timing,
    this.instructions,
    this.quantity,
    this.beforeMeal,
    this.afterMeal,
  });

  // From JSON
  factory MedicationModel.fromJson(Map<String, dynamic> json) {
    return MedicationModel(
      id: json['id'] as String?,
      name: json['name'] as String?,
      strength: json['strength'] as String?,
      form: json['form'] as String?,
      dosage: json['dosage'] as String?,
      frequency: json['frequency'] as String?,
      duration: json['duration'] as String?,
      timing: json['timing'] as String?,
      instructions: json['instructions'] as String?,
      quantity: json['quantity'] as int?,
      beforeMeal: json['beforeMeal'] as bool?,
      afterMeal: json['afterMeal'] as bool?,
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'strength': strength,
      'form': form,
      'dosage': dosage,
      'frequency': frequency,
      'duration': duration,
      'timing': timing,
      'instructions': instructions,
      'quantity': quantity,
      'beforeMeal': beforeMeal,
      'afterMeal': afterMeal,
    };
  }

  // Copy with
  MedicationModel copyWith({
    String? id,
    String? name,
    String? strength,
    String? form,
    String? dosage,
    String? frequency,
    String? duration,
    String? timing,
    String? instructions,
    int? quantity,
    bool? beforeMeal,
    bool? afterMeal,
  }) {
    return MedicationModel(
      id: id ?? this.id,
      name: name ?? this.name,
      strength: strength ?? this.strength,
      form: form ?? this.form,
      dosage: dosage ?? this.dosage,
      frequency: frequency ?? this.frequency,
      duration: duration ?? this.duration,
      timing: timing ?? this.timing,
      instructions: instructions ?? this.instructions,
      quantity: quantity ?? this.quantity,
      beforeMeal: beforeMeal ?? this.beforeMeal,
      afterMeal: afterMeal ?? this.afterMeal,
    );
  }
}
