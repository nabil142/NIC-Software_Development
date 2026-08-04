import '../../data/models/village_model.dart';

abstract class VillageRepository {
  Future<VillageModel> createOrUpdateVillage({
    required String villageName,
    required int population,
    required double areaKm2,
    String? districtName,
    String? cityName,
    String? potential,
  });
  Future<VillageModel?> getActiveVillage();
}
