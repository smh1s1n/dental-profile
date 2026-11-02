import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/dental_chart_model.dart';
import '../../domain/models/prescription_model.dart';
import '../../data/repositories/clinical_repository_impl.dart';

final clinicalRepositoryProvider = Provider<ClinicalRepository>((ref) {
  return ClinicalRepositoryImpl.instance;
});

final dentalChartProvider = FutureProvider.family<Map<int, ToothRecord>, String>((ref, phoneOrId) async {
  final repo = ref.watch(clinicalRepositoryProvider);
  return await repo.getDentalChart(phoneOrId);
});

final prescriptionProvider = FutureProvider.family<DentalPrescriptionModel?, String>((ref, appointmentId) async {
  final repo = ref.watch(clinicalRepositoryProvider);
  return await repo.getPrescription(appointmentId);
});
