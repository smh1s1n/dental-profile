class PatientModel {
  final String name;
  final int age;
  final String gender; // 'Male', 'Female', 'Other'
  final String phone; // e.g. 01712345678
  final String? email;
  final String addressArea; // e.g. Dhanmondi, Dhaka
  final List<String> medicalConditions; // Diabetes, Hypertension, Bleeding tendency, Allergy etc.
  final String chiefComplaint; // e.g. Severe tooth pain lower right jaw
  final int painScale; // 1 to 10

  const PatientModel({
    required this.name,
    required this.age,
    required this.gender,
    required this.phone,
    this.email,
    required this.addressArea,
    required this.medicalConditions,
    required this.chiefComplaint,
    this.painScale = 5,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'age': age,
      'gender': gender,
      'phone': phone,
      'email': email,
      'addressArea': addressArea,
      'medicalConditions': medicalConditions,
      'chiefComplaint': chiefComplaint,
      'painScale': painScale,
    };
  }

  factory PatientModel.fromJson(Map<String, dynamic> json) {
    return PatientModel(
      name: json['name'] as String,
      age: json['age'] as int,
      gender: json['gender'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String?,
      addressArea: json['addressArea'] as String,
      medicalConditions: List<String>.from(json['medicalConditions'] as List),
      chiefComplaint: json['chiefComplaint'] as String,
      painScale: json['painScale'] as int? ?? 5,
    );
  }
}
