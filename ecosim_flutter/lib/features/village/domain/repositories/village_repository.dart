import '../../data/models/village_model.dart';

abstract class VillageRepository {
  Future<VillageModel> createOrUpdateVillage({
    required String villageName,
    required int population,
    required double areaKm2,
    required double agriculturalAreaKm2,
  });
  Future<VillageModel?> getActiveVillage();
}
