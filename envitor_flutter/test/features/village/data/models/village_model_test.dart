import 'package:flutter_test/flutter_test.dart';
import 'package:ecosim_flutter/features/village/data/models/village_model.dart';

void main() {
  group('VillageModel Tests', () {
    test('fromJson should parse correctly', () {
      final json = {
        'id': 'v-1',
        'userId': 'u-1',
        'villageName': 'SukaMaju',
        'population': 3000,
        'areaKm2': 5000.0,
      };
      final model = VillageModel.fromJson(json);

      expect(model.id, 'v-1');
      expect(model.villageName, 'SukaMaju');
      expect(model.population, 3000);
      expect(model.areaKm2, 5000.0);
    });

    test('toJson should convert correctly', () {
      final model = VillageModel(
        id: 'v-2',
        userId: 'u-2',
        villageName: 'SukaMundur',
        population: 1500,
        areaKm2: 2500.0,
      );
      final json = model.toJson();

      expect(json['id'], 'v-2');
      expect(json['villageName'], 'SukaMundur');
    });
  });
}
