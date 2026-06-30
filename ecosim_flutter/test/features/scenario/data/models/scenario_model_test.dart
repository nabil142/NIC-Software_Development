import 'package:flutter_test/flutter_test.dart';
import 'package:ecosim_flutter/features/scenario/data/models/scenario_model.dart';

void main() {
  group('ScenarioModel Tests', () {
    test('fromJson and toJson', () {
      final json = {
        'id': 's-1',
        'villageId': 'v-1',
        'scenarioName': 'Best Plan',
        'selectedPrograms': ['p1', 'p2'],
        'baselineWasteHealth': 1,
        'baselineWaterHealth': 2,
        'baselineGreenHealth': 3,
        'baselineResilience': 4,
        'projectedWasteHealth': 2,
        'projectedWaterHealth': 3,
        'projectedGreenHealth': 4,
        'projectedResilience': 4,
        'aiAnalysis': 'Analysis text',
        'narrativeText': 'Blueprint text',
        'baseline_dna': {
          'waste_health': 'Poor',
          'water_health': 'Fair',
          'green_health': 'Good',
          'resilience': 'Excellent',
        },
        'projected_dna': {
          'waste_health': 'Fair',
          'water_health': 'Good',
          'green_health': 'Excellent',
          'resilience': 'Excellent',
        },
      };

      final model = ScenarioModel.fromJson(json);
      expect(model.id, 's-1');
      expect(model.selectedPrograms.length, 2);
      expect(model.baselineDna?.wasteHealth, 'Poor');
      expect(model.projectedDna?.waterHealth, 'Good');

      final output = model.toJson();
      expect(output['scenarioName'], 'Best Plan');
      expect(output['aiAnalysis'], 'Analysis text');
    });
  });
}
