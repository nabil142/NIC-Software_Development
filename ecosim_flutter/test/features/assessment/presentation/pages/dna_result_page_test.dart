import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ecosim_flutter/features/assessment/presentation/pages/dna_result_page.dart';
import 'package:ecosim_flutter/features/assessment/data/models/assessment_model.dart';
import 'package:ecosim_flutter/features/assessment/presentation/controllers/assessment_controller.dart';
import 'package:fl_chart/fl_chart.dart';

class MockAssessmentNotifier extends StateNotifier<AssessmentState> implements AssessmentNotifier {
  MockAssessmentNotifier(AssessmentState state) : super(state);

  @override
  void clear() {}

  @override
  Future<void> loadLatestAssessment(String villageId) async {}

  @override
  Future<bool> submitAssessment({
    required String villageId,
    required int wasteLevel,
    required String wasteManagement,
    required int waterQuality,
    required bool riverContaminated,
    required int greenSpace,
    required int floodRisk,
    required List<String> existingPrograms,
    String? potentialProblem,
  }) async {
    return true;
  }
}

void main() {
  testWidgets('DNAResultPage renders chart and button', (WidgetTester tester) async {
    final mockAssessment = AssessmentResponseModel(
      assessment: AssessmentModel(id: 'a1', villageId: 'v1', wasteLevel: 1, wasteManagement: 'A', waterQuality: 1, riverContaminated: false, greenSpace: 1, floodRisk: 1, existingPrograms: [], potentialSolutionAI: 'Some solution here'),
      dnaScores: DNAScoresModel(wasteHealth: 'A', waterHealth: 'A', greenHealth: 'A', resilience: 'A'),
      dnaDetails: DNADetailsModel(wasteHealth: DNADetailItem(score: 10, status: 'A', explanation: 'A'), waterHealth: DNADetailItem(score: 10, status: 'A', explanation: 'A'), greenHealth: DNADetailItem(score: 10, status: 'A', explanation: 'A'), resilience: DNADetailItem(score: 10, status: 'A', explanation: 'A')),
      dnaInsights: [
        DNAInsightItem(dimension: 'Waste', status: 'Good', priority: 'Low', insight: 'Keep it up')
      ],
    );

    final mockNotifier = MockAssessmentNotifier(
      AssessmentState(
        isInitialized: true,
        isLoading: false,
        latestAssessment: mockAssessment,
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          assessmentControllerProvider.overrideWith((ref) => mockNotifier),
        ],
        child: const MaterialApp(
          home: DnaResultPage(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Analisis Potensi Desa AI'), findsOneWidget);

    expect(find.text('Lanjut Simulasikan Program (Future Builder)'), findsOneWidget);
  });
}
