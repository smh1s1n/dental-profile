class PatientReviewModel {
  final String id;
  final String patientName;
  final String area;
  final String date;
  final double rating;
  final String treatmentTaken;
  final String comment;
  final bool isVerified;

  const PatientReviewModel({
    required this.id,
    required this.patientName,
    required this.area,
    required this.date,
    required this.rating,
    required this.treatmentTaken,
    required this.comment,
    this.isVerified = true,
  });
}
