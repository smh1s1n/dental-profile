import '../../domain/models/doctor_profile_model.dart';
import '../../domain/models/dental_service_model.dart';
import '../../domain/models/review_model.dart';
import '../../../../core/constants/mock_data.dart';

abstract class DoctorRepository {
  Future<DoctorProfileModel> getDoctorProfile();
  Future<List<DentalServiceModel>> getAllServices();
  Future<List<PatientReviewModel>> getPatientReviews();
}

class DoctorRepositoryImpl implements DoctorRepository {
  DoctorRepositoryImpl._internal();
  static final DoctorRepositoryImpl instance = DoctorRepositoryImpl._internal();

  @override
  Future<DoctorProfileModel> getDoctorProfile() async {
    return MockData.doctorProfile;
  }

  @override
  Future<List<DentalServiceModel>> getAllServices() async {
    return MockData.dentalServices;
  }

  @override
  Future<List<PatientReviewModel>> getPatientReviews() async {
    return MockData.reviews;
  }
}
