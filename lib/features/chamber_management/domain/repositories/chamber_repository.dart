import '../models/chamber_model.dart';
import '../../../../core/constants/mock_data.dart';

abstract class ChamberRepository {
  Future<List<ChamberModel>> getAllChambers();
  Future<ChamberModel?> getChamberById(String id);
}

class ChamberRepositoryImpl implements ChamberRepository {
  ChamberRepositoryImpl._internal();
  static final ChamberRepositoryImpl instance = ChamberRepositoryImpl._internal();

  @override
  Future<List<ChamberModel>> getAllChambers() async {
    return MockData.chambers;
  }

  @override
  Future<ChamberModel?> getChamberById(String id) async {
    try {
      return MockData.chambers.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }
}
