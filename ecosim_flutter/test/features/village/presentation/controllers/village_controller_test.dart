import 'package:flutter_test/flutter_test.dart';
import 'package:ecosim_flutter/features/village/data/repositories/village_repository_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ecosim_flutter/features/village/presentation/controllers/village_controller.dart';
import 'package:ecosim_flutter/features/village/domain/repositories/village_repository.dart';
import 'package:ecosim_flutter/features/village/data/models/village_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockVillageRepository implements VillageRepository {
  @override
  Future<VillageModel> getActiveVillage() async {
    return VillageModel(
      id: 'v1',
      userId: 'u1',
      villageName: 'Test Desa',
      population: 100,
      areaKm2: 10.0,
    );
  }

  @override
  Future<VillageModel> createOrUpdateVillage({
    required String villageName,
    required int population,
    required double areaKm2,
    String? districtName,
    String? cityName,
    String? potential,
  }) async {
    return VillageModel(
      id: 'v2',
      userId: 'u1',
      villageName: villageName,
      population: population,
      areaKm2: areaKm2,
    );
  }
}

void main() {
  test('VillageController loads active village correctly', () async {
    SharedPreferences.setMockInitialValues({'auth_token': 'dummy_token'});
    final mockRepo = MockVillageRepository();
    final container = ProviderContainer(
      overrides: [villageRepositoryProvider.overrideWithValue(mockRepo)],
    );

    final controller = container.read(villageControllerProvider.notifier);
    await controller.loadActiveVillage();

    final state = container.read(villageControllerProvider);
    expect(state.activeVillage, isNotNull);
    expect(state.activeVillage!.villageName, 'Test Desa');
  });
}
