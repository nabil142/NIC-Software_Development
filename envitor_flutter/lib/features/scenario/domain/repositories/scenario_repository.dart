import '../../data/models/scenario_model.dart';

abstract class ScenarioRepository {
  Future<ScenarioModel> createScenario({
    required String villageId,
    required String scenarioName,
    required List<String> selectedPrograms,
  });
  Future<List<ScenarioModel>> getScenarios(String villageId);
  Future<String> runScenarioAnalysis(String scenarioId);
  Future<String> runScenarioBlueprint(String scenarioId);
}
