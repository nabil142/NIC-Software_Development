import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ecosim_flutter/features/village/presentation/controllers/village_controller.dart';
import 'package:ecosim_flutter/features/assessment/presentation/controllers/assessment_controller.dart';
import 'package:ecosim_flutter/features/scenario/presentation/controllers/scenario_controller.dart';
import 'package:ecosim_flutter/features/village/data/models/village_model.dart';
import 'package:ecosim_flutter/features/assessment/data/models/assessment_model.dart';
import 'package:ecosim_flutter/features/scenario/data/models/scenario_model.dart';

class MockVillageNotifier extends StateNotifier<VillageState> implements VillageNotifier {
  MockVillageNotifier() : super(VillageState(
    activeVillage: VillageModel(id: 'v1', userId: 'u1', villageName: 'Mock Village', population: 100, areaKm2: 10.0)
  ));
  
  @override
  Future<void> loadVillages() async {}
  @override
  Future<void> loadActiveVillage() async {}
  @override
  Future<void> createVillage(VillageModel village) async {}
  @override
  Future<void> deleteVillage(String id) async {}
  @override
  Future<void> setActiveVillage(VillageModel village) async {}
  @override
  void clear() {}
  @override
  Future<bool> saveProfile({required String villageName, required int population, required double areaKm2, String? districtName, String? cityName, String? typography, String? potential}) async { return true; }
}

class MockAssessmentNotifier extends StateNotifier<AssessmentState> implements AssessmentNotifier {
  MockAssessmentNotifier() : super(AssessmentState(
    isInitialized: true, 
    isLoading: false, 
    latestAssessment: AssessmentResponseModel(
      assessment: AssessmentModel(id: 'a1', villageId: 'v1', wasteLevel: 1, wasteManagement: 'A', waterQuality: 1, riverContaminated: false, greenSpace: 1, floodRisk: 1, existingPrograms: []),
      dnaScores: DNAScoresModel(wasteHealth: 'A', waterHealth: 'A', greenHealth: 'A', resilience: 'A'),
      dnaDetails: DNADetailsModel(wasteHealth: DNADetailItem(score: 10, status: 'A', explanation: 'A'), waterHealth: DNADetailItem(score: 10, status: 'A', explanation: 'A'), greenHealth: DNADetailItem(score: 10, status: 'A', explanation: 'A'), resilience: DNADetailItem(score: 10, status: 'A', explanation: 'A')),
      dnaInsights: [],
    )
  ));
  
  @override
  void clear() {}
  @override
  Future<void> loadLatestAssessment(String villageId) async {}
  @override
  Future<bool> submitAssessment({required String villageId, required int wasteLevel, required String wasteManagement, required int waterQuality, required bool riverContaminated, required int greenSpace, required int floodRisk, required List<String> existingPrograms, String? potentialProblem}) async { return true; }
}

class MockScenarioNotifier extends StateNotifier<ScenarioState> implements ScenarioNotifier {
  MockScenarioNotifier() : super(ScenarioState(
    isInitialized: true,
    isLoading: false,
    scenarios: [
      ScenarioModel(
        id: 's1',
        villageId: 'v1',
        scenarioName: 'Test Scenario',
        selectedPrograms: [],
        baselineWasteHealth: 1,
        baselineWaterHealth: 1,
        baselineGreenHealth: 1,
        baselineResilience: 1,
        projectedWasteHealth: 1,
        projectedWaterHealth: 1,
        projectedGreenHealth: 1,
        projectedResilience: 1,
        narrativeText: 'Test Narrative',
      )
    ],
    activeScenario: ScenarioModel(
      id: 's1',
      villageId: 'v1',
      scenarioName: 'Test Scenario',
      selectedPrograms: [],
      baselineWasteHealth: 1,
      baselineWaterHealth: 1,
      baselineGreenHealth: 1,
      baselineResilience: 1,
      projectedWasteHealth: 1,
      projectedWaterHealth: 1,
      projectedGreenHealth: 1,
      projectedResilience: 1,
      narrativeText: 'Test Narrative',
    ),
  ));
  
  @override
  void clear() {}
  @override
  Future<void> loadScenarios(String villageId) async {}
  @override
  Future<ScenarioModel?> createNewScenario({required String villageId, required String scenarioName, required List<String> selectedPrograms}) async { return null; }
  @override
  Future<void> deleteScenario(String scenarioId, String villageId) async {}
  @override
  Future<bool> runAIAnalysis() async { return true; }
  @override
  Future<bool> runAIBlueprint() async { return true; }
  @override
  void selectActiveScenario(ScenarioModel scenario) {}
}
