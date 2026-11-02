import '../../domain/models/dental_chart_model.dart';
import '../../domain/models/prescription_model.dart';
import '../../../../core/services/storage_service.dart';

abstract class ClinicalRepository {
  Future<Map<int, ToothRecord>> getDentalChart(String patientIdOrPhone);
  Future<void> updateToothRecord(String patientIdOrPhone, ToothRecord record);
  Future<DentalPrescriptionModel?> getPrescription(String appointmentId);
  Future<void> savePrescription(DentalPrescriptionModel prescription);
}

class ClinicalRepositoryImpl implements ClinicalRepository {
  ClinicalRepositoryImpl._internal();
  static final ClinicalRepositoryImpl instance = ClinicalRepositoryImpl._internal();

  static const String _chartPrefix = 'smilecraft_chart_';
  static const String _rxPrefix = 'smilecraft_rx_';

  @override
  Future<Map<int, ToothRecord>> getDentalChart(String patientIdOrPhone) async {
    final storage = StorageService.instance;
    await storage.init();
    final jsonList = storage.getJsonList('$_chartPrefix$patientIdOrPhone');

    final Map<int, ToothRecord> map = {};
    // Initialize standard adult 32 teeth (FDI 11-18, 21-28, 31-38, 41-48)
    final allTeeth = [
      18, 17, 16, 15, 14, 13, 12, 11,
      21, 22, 23, 24, 25, 26, 27, 28,
      38, 37, 36, 35, 34, 33, 32, 31,
      48, 47, 46, 45, 44, 43, 42, 41,
    ];

    for (var t in allTeeth) {
      map[t] = ToothRecord(toothNumber: t, condition: ToothCondition.healthy);
    }

    if (jsonList != null) {
      for (var item in jsonList) {
        final record = ToothRecord.fromJson(item);
        map[record.toothNumber] = record;
      }
    }

    return map;
  }

  @override
  Future<void> updateToothRecord(String patientIdOrPhone, ToothRecord record) async {
    final chart = await getDentalChart(patientIdOrPhone);
    chart[record.toothNumber] = record;

    final jsonList = chart.values.map((v) => v.toJson()).toList();
    await StorageService.instance.setJsonList('$_chartPrefix$patientIdOrPhone', jsonList);
  }

  @override
  Future<DentalPrescriptionModel?> getPrescription(String appointmentId) async {
    final storage = StorageService.instance;
    await storage.init();
    final json = storage.getJson('$_rxPrefix$appointmentId');
    if (json == null) {
      // Return a standard sample prescription if none created yet
      return DentalPrescriptionModel(
        id: 'RX-${DateTime.now().millisecondsSinceEpoch % 10000}',
        appointmentId: appointmentId,
        patientName: 'Kazi Farhan',
        patientAge: 45,
        patientGender: 'Male',
        date: DateTime.now().toIso8601String().split('T').first,
        chamberName: 'SmileCraft Dental Care (Dhanmondi)',
        diagnosis: 'Acute Irreversible Pulpitis (#46) with Periapical Periodontitis',
        medicines: const [
          PrescribedMedicine(name: 'Tab. Moxaclav 625mg (Amoxicillin + Clavulanic Acid)', dosage: '1 + 0 + 1', instruction: 'ভরা পেটে ৫ দিন (After meals for 5 days)'),
          PrescribedMedicine(name: 'Tab. Ketorolac 10mg (Pain Relief)', dosage: '1 + 0 + 1 (প্রয়োজনে)', instruction: 'তীব্র ব্যথায় ভরা পেটে অ্যান্টাসিড সহ'),
          PrescribedMedicine(name: 'Cap. Esomeprazole 20mg', dosage: '1 + 0 + 1', instruction: 'খাবারের ৩০ মিনিট পূর্বে ৫ দিন'),
          PrescribedMedicine(name: 'Chlorhexidine 0.2% Oral Rinse (Mouthwash)', dosage: 'দিনে ২ বার', instruction: '১০ মি.লি. কুসুম গরম পানিতে মিশিয়ে ৩০ সেকেন্ড কুলকুচি'),
        ],
        advice: const [
          'আজ রাতে নরম ও সাধারণ তাপমাত্রার খাবার খান।',
          'চিকিৎসাকৃত দাঁতের দিকে শক্ত খাবার চিবাবেন না।',
          'আগামী রবিবার পরবর্তী রুট ক্যানেল সিটিংয়ের জন্য আসুন।',
        ],
        nextVisitDate: 'Next Sunday 6:30 PM',
      );
    }
    return DentalPrescriptionModel.fromJson(json);
  }

  @override
  Future<void> savePrescription(DentalPrescriptionModel prescription) async {
    await StorageService.instance.setJson('$_rxPrefix${prescription.appointmentId}', prescription.toJson());
  }
}
