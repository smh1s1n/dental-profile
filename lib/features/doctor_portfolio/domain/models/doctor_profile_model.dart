class DoctorProfileModel {
  final String name;
  final String bnName;
  final String title;
  final String bmdcRegNo;
  final String degrees;
  final String bioEn;
  final String bioBn;
  final int yearsOfExperience;
  final int satisfiedPatients;
  final double rating;
  final int reviewCount;
  final List<String> specializations;
  final List<String> awards;
  final List<String> memberships;

  const DoctorProfileModel({
    required this.name,
    required this.bnName,
    required this.title,
    required this.bmdcRegNo,
    required this.degrees,
    required this.bioEn,
    required this.bioBn,
    required this.yearsOfExperience,
    required this.satisfiedPatients,
    required this.rating,
    required this.reviewCount,
    required this.specializations,
    required this.awards,
    required this.memberships,
  });
}
