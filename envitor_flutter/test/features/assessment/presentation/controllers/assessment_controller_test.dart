import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ecosim_flutter/features/assessment/presentation/controllers/assessment_controller.dart';
import 'package:ecosim_flutter/features/assessment/data/repositories/assessment_repository_impl.dart';
import 'package:ecosim_flutter/features/assessment/domain/repositories/assessment_repository.dart';
import 'package:ecosim_flutter/features/assessment/data/models/assessment_model.dart';

class MockAssessmentRepository implements AssessmentRepository {
  @override
  Future<AssessmentResponseModel> createAssessment({
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
    return AssessmentResponseModel(
      assessment: AssessmentModel(id: 'mock-id', villageId: villageId, wasteLevel: wasteLevel, wasteManagement: wasteManagement, waterQuality: waterQuality, riverContaminated: riverContaminated, greenSpace: greenSpace, floodRisk: floodRisk, existingPrograms: existingPrograms, potentialProblem: potentialProblem),
      dnaScores: DNAScoresModel(wasteHealth: 'A', waterHealth: 'A', greenHealth: 'A', resilience: 'A'),
      dnaDetails: DNADetailsModel(wasteHealth: DNADetailItem(score: 10, status: 'A', explanation: 'A'), waterHealth: DNADetailItem(score: 10, status: 'A', explanation: 'A'), greenHealth: DNADetailItem(score: 10, status: 'A', explanation: 'A'), resilience: DNADetailItem(score: 10, status: 'A', explanation: 'A')),
      dnaInsights: [],
    );
  }

  @override
  Future<AssessmentResponseModel> getLatestAssessment(String villageId) async {
    if (villageId == 'error_village') {
      throw Exception('Data not found');
    }
    return AssessmentResponseModel(
      assessment: AssessmentModel(id: 'latest-id', villageId: villageId, wasteLevel: 1, wasteManagement: 'A', waterQuality: 1, riverContaminated: false, greenSpace: 1, floodRisk: 1, existingPrograms: []),
      dnaScores: DNAScoresModel(wasteHealth: 'A', waterHealth: 'A', greenHealth: 'A', resilience: 'A'),
      dnaDetails: DNADetailsModel(wasteHealth: DNADetailItem(score: 10, status: 'A', explanation: 'A'), waterHealth: DNADetailItem(score: 10, status: 'A', explanation: 'A'), greenHealth: DNADetailItem(score: 10, status: 'A', explanation: 'A'), resilience: DNADetailItem(score: 10, status: 'A', explanation: 'A')),
      dnaInsights: [],
    );
  }
}

void main() {
  group('AssessmentController Tests', () {
    test('loadLatestAssessment success updates state correctly', () async {
      final mockRepo = MockAssessmentRepository();
      final container = ProviderContainer(
        overrides: [assessmentRepositoryProvider.overrideWithValue(mockRepo)],
      );

      final controller = container.read(assessmentControllerProvider.notifier);
      await controller.loadLatestAssessment('v1');

      final state = container.read(assessmentControllerProvider);
      expect(state.isLoading, isFalse);
      expect(state.isInitialized, isTrue);
      expect(state.latestAssessment, isNotNull);
      expect(state.latestAssessment?.assessment.villageId, 'v1');
      expect(state.errorMessage, isNull);
    });

    test('loadLatestAssessment error updates error message', () async {
      final mockRepo = MockAssessmentRepository();
      final container = ProviderContainer(
        overrides: [assessmentRepositoryProvider.overrideWithValue(mockRepo)],
      );

      final controller = container.read(assessmentControllerProvider.notifier);
      await controller.loadLatestAssessment('error_village');

      final state = container.read(assessmentControllerProvider);
      expect(state.isLoading, isFalse);
      expect(state.isInitialized, isTrue);
      expect(state.latestAssessment, isNull);
      expect(state.errorMessage, 'Data not found');
    });

    test('submitAssessment returns true and updates state', () async {
      final mockRepo = MockAssessmentRepository();
      final container = ProviderContainer(
        overrides: [assessmentRepositoryProvider.overrideWithValue(mockRepo)],
      );

      final controller = container.read(assessmentControllerProvider.notifier);
      final result = await controller.submitAssessment(
        villageId: 'v1',
        wasteLevel: 2,
        wasteManagement: 'Bakar',
        waterQuality: 2,
        riverContaminated: true,
        greenSpace: 2,
        floodRisk: 2,
        existingPrograms: [],
      );

      final state = container.read(assessmentControllerProvider);
      expect(result, isTrue);
      expect(state.isLoading, isFalse);
      expect(state.latestAssessment, isNotNull);
      expect(state.latestAssessment?.assessment.id, 'mock-id');
    });
  });
}
