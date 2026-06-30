import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ecosim_flutter/features/village/data/repositories/village_repository_impl.dart';
import 'package:ecosim_flutter/features/assessment/data/repositories/assessment_repository_impl.dart';
import 'package:ecosim_flutter/features/scenario/data/repositories/scenario_repository_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ecosim_flutter/features/scenario/presentation/pages/summary_report_page.dart';
import 'package:ecosim_flutter/features/village/presentation/controllers/village_controller.dart';
import 'package:ecosim_flutter/features/village/data/models/village_model.dart';
import 'package:ecosim_flutter/features/assessment/presentation/controllers/assessment_controller.dart';
import 'package:ecosim_flutter/features/assessment/data/models/assessment_model.dart';
import 'package:ecosim_flutter/features/scenario/presentation/controllers/scenario_controller.dart';
import 'package:ecosim_flutter/features/scenario/data/models/scenario_model.dart';

void main() {
  testWidgets('SummaryReportPage renders with data', (
    WidgetTester tester,
  ) async {
    final village = VillageModel(
      id: 'v1',
      userId: 'u1',
      villageName: 'SukaMaju',
      population: 100,
      areaKm2: 10,
    );
    final assessment = AssessmentResponseModel(
      assessment: AssessmentModel(
        id: 'a1',
        villageId: 'v1',
        wasteLevel: 1,
        wasteManagement: 'tps',
        waterQuality: 1,
        riverContaminated: false,
        greenSpace: 1,
        floodRisk: 1,
        existingPrograms: [],
      ),
      dnaScores: DNAScoresModel(
        wasteHealth: 'Fair',
        waterHealth: 'Good',
        greenHealth: 'Poor',
        resilience: 'Fair',
      ),
      dnaDetails: DNADetailsModel(
        wasteHealth: DNADetailItem(
          score: 50,
          status: 'Fair',
          explanation: 'exp',
        ),
        waterHealth: DNADetailItem(
          score: 50,
          status: 'Fair',
          explanation: 'exp',
        ),
        greenHealth: DNADetailItem(
          score: 50,
          status: 'Poor',
          explanation: 'exp',
        ),
        resilience: DNADetailItem(
          score: 50,
          status: 'Fair',
          explanation: 'exp',
        ),
      ),
      dnaInsights: [
        DNAInsightItem(
          dimension: 'dim',
          status: 'Fair',
          priority: 'High',
          insight: 'Do this',
        ),
      ],
    );
    final scenario = ScenarioModel(
      id: 's1',
      villageId: 'v1',
      scenarioName: 'Test',
      selectedPrograms: [],
      baselineWasteHealth: 1,
      baselineWaterHealth: 1,
      baselineGreenHealth: 1,
      baselineResilience: 1,
      projectedWasteHealth: 2,
      projectedWaterHealth: 2,
      projectedGreenHealth: 2,
      projectedResilience: 2,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          villageControllerProvider.overrideWith(
            (ref) => VillageNotifier(ref.read(villageRepositoryProvider))
              ..state = VillageState(activeVillage: village, isLoading: false),
          ),
          assessmentControllerProvider.overrideWith(
            (ref) => AssessmentNotifier(ref.read(assessmentRepositoryProvider))
              ..state = AssessmentState(
                latestAssessment: assessment,
                isLoading: false,
                errorMessage: null,
              ),
          ),
          scenarioControllerProvider.overrideWith(
            (ref) =>
                ScenarioNotifier(ref.read(scenarioRepositoryProvider))
                  ..state = ScenarioState(
                    activeScenario: scenario,
                    isLoading: false,
                    errorMessage: null,
                    scenarios: [],
                  ),
          ),
        ],
        child: const MaterialApp(home: SummaryReportPage()),
      ),
    );

    expect(find.text('Rangkuman Laporan'), findsOneWidget);
    expect(find.textContaining('SukaMaju'), findsWidgets);
    expect(find.text('Skor Kinerja Desa'), findsOneWidget);
  });
}
