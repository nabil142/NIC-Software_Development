import 'package:flutter_test/flutter_test.dart';
import 'package:ecosim_flutter/features/assessment/data/models/assessment_model.dart';

void main() {
  group('Assessment Models Tests', () {
    test('AssessmentModel fromJson and toJson', () {
      final json = {
        'id': 'a-1',
        'villageId': 'v-1',
        'wasteLevel': 5,
        'wasteManagement': 'tps',
        'waterQuality': 8,
        'riverContaminated': false,
        'greenSpace': 7,
        'floodRisk': 2,
        'existingPrograms': ['p-1'],
        'potentialProblem': 'Banjir',
        'potentialSolutionAI': 'Solusi AI',
      };

      final model = AssessmentModel.fromJson(json);
      expect(model.id, 'a-1');
      expect(model.wasteLevel, 5);
      expect(model.existingPrograms.length, 1);

      final outputJson = model.toJson();
      expect(outputJson['potentialProblem'], 'Banjir');
    });

    test('DNAScoresModel fromJson', () {
      final json = {
        'waste_health': 'Fair',
        'water_health': 'Good',
        'green_health': 'Excellent',
        'resilience': 'Poor',
      };

      final model = DNAScoresModel.fromJson(json);
      expect(model.wasteHealth, 'Fair');
      expect(model.waterHealth, 'Good');
    });
  });
}
