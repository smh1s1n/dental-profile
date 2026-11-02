class PrescribedMedicine {
  final String name;
  final String dosage; // e.g. 1 + 0 + 1
  final String instruction; // e.g. ভরা পেটে ৫ দিন (After food for 5 days)

  const PrescribedMedicine({
    required this.name,
    required this.dosage,
    required this.instruction,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'dosage': dosage,
        'instruction': instruction,
      };

  factory PrescribedMedicine.fromJson(Map<String, dynamic> json) =>
      PrescribedMedicine(
        name: json['name'] as String,
        dosage: json['dosage'] as String,
        instruction: json['instruction'] as String,
      );
}

class DentalPrescriptionModel {
  final String id;
  final String appointmentId;
  final String patientName;
  final int patientAge;
  final String patientGender;
  final String date;
  final String chamberName;
  final String diagnosis;
  final List<PrescribedMedicine> medicines;
  final List<String> advice;
  final String? nextVisitDate;

  const DentalPrescriptionModel({
    required this.id,
    required this.appointmentId,
    required this.patientName,
    required this.patientAge,
    required this.patientGender,
    required this.date,
    required this.chamberName,
    required this.diagnosis,
    required this.medicines,
    required this.advice,
    this.nextVisitDate,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'appointmentId': appointmentId,
        'patientName': patientName,
        'patientAge': patientAge,
        'patientGender': patientGender,
        'date': date,
        'chamberName': chamberName,
        'diagnosis': diagnosis,
        'medicines': medicines.map((m) => m.toJson()).toList(),
        'advice': advice,
        'nextVisitDate': nextVisitDate,
      };

  factory DentalPrescriptionModel.fromJson(Map<String, dynamic> json) =>
      DentalPrescriptionModel(
        id: json['id'] as String,
        appointmentId: json['appointmentId'] as String,
        patientName: json['patientName'] as String,
        patientAge: json['patientAge'] as int,
        patientGender: json['patientGender'] as String,
        date: json['date'] as String,
        chamberName: json['chamberName'] as String,
        diagnosis: json['diagnosis'] as String,
        medicines: (json['medicines'] as List)
            .map((m) => PrescribedMedicine.fromJson(m as Map<String, dynamic>))
            .toList(),
        advice: List<String>.from(json['advice'] as List),
        nextVisitDate: json['nextVisitDate'] as String?,
      );
}
