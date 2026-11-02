import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dental_profile/features/clinical_records/data/repositories/clinical_repository_impl.dart';
import 'package:dental_profile/features/clinical_records/domain/models/dental_chart_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ClinicalRepositoryImpl Tests', () {
    test('Initializes full 32 teeth in FDI 2-digit notation', () async {
      final repo = ClinicalRepositoryImpl.instance;
      final chart = await repo.getDentalChart('01711223344');

      expect(chart.length, equals(32));
      expect(chart.containsKey(11), isTrue); // Upper Right Central Incisor
      expect(chart.containsKey(21), isTrue); // Upper Left Central Incisor
      expect(chart.containsKey(36), isTrue); // Lower Left First Molar
      expect(chart.containsKey(48), isTrue); // Lower Right Third Molar (Wisdom)
    });

    test('Updates and persists tooth condition', () async {
      final repo = ClinicalRepositoryImpl.instance;
      const phone = '01711223344';

      await repo.updateToothRecord(
        phone,
        const ToothRecord(
          toothNumber: 46,
          condition: ToothCondition.rct,
          clinicalNote: 'Rotary RCT completed with bioceramic obturation',
        ),
      );

      final updatedChart = await repo.getDentalChart(phone);
      expect(updatedChart[46]?.condition, equals(ToothCondition.rct));
      expect(updatedChart[46]?.clinicalNote, contains('Rotary RCT'));
    });
  });
}
