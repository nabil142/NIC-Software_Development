import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/scenario_model.dart';
import '../../domain/repositories/scenario_repository.dart';
import '../../data/repositories/scenario_repository_impl.dart';

class ScenarioState {
  final List<ScenarioModel> scenarios;
  final ScenarioModel? activeScenario;
  final bool isLoading;
  final String? errorMessage;
  final bool isInitialized;

  ScenarioState({
    this.scenarios = const [],
    this.activeScenario,
    this.isLoading = false,
    this.errorMessage,
    this.isInitialized = false,
  });

  ScenarioState copyWith({
    List<ScenarioModel>? scenarios,
    ScenarioModel? activeScenario,
    bool? isLoading,
    String? errorMessage,
    bool? isInitialized,
  }) {
    return ScenarioState(
      scenarios: scenarios ?? this.scenarios,
      activeScenario: activeScenario ?? this.activeScenario,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }
}

class ScenarioNotifier extends StateNotifier<ScenarioState> {
  final ScenarioRepository _scenarioRepository;

  ScenarioNotifier(this._scenarioRepository) : super(ScenarioState());

  Future<void> loadScenarios(String villageId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final list = await _scenarioRepository.getScenarios(villageId);
      ScenarioModel? active = state.activeScenario;
      if (active != null) {
        final match = list.where((element) => element.id == active!.id);
        if (match.isNotEmpty) {
          active = match.first;
        }
      } else if (list.isNotEmpty) {
        active = list.first;
      }
      state = state.copyWith(
        scenarios: list,
        activeScenario: active,
        isLoading: false,
        isInitialized: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isInitialized: true,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  void selectActiveScenario(ScenarioModel scenario) {
    state = state.copyWith(activeScenario: scenario);
  }

  Future<ScenarioModel?> createNewScenario({
    required String villageId,
    required String scenarioName,
    required List<String> selectedPrograms,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final scenario = await _scenarioRepository.createScenario(
        villageId: villageId,
        scenarioName: scenarioName,
        selectedPrograms: selectedPrograms,
      );
      final updatedList = [scenario, ...state.scenarios];
      state = state.copyWith(
        scenarios: updatedList,
        activeScenario: scenario,
        isLoading: false,
      );
      return scenario;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return null;
    }
  }

  Future<bool> runAIAnalysis() async {
    final active = state.activeScenario;
    if (active == null) {
      state = state.copyWith(errorMessage: 'Tidak ada skenario aktif terpilih.');
      return false;
    }
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final resultText = await _scenarioRepository.runScenarioAnalysis(active.id);
      
      final updatedActive = ScenarioModel(
        id: active.id,
        villageId: active.villageId,
        scenarioName: active.scenarioName,
        selectedPrograms: active.selectedPrograms,
        baselineWasteHealth: active.baselineWasteHealth,
        baselineWaterHealth: active.baselineWaterHealth,
        baselineGreenHealth: active.baselineGreenHealth,
        baselineResilience: active.baselineResilience,
        projectedWasteHealth: active.projectedWasteHealth,
        projectedWaterHealth: active.projectedWaterHealth,
        projectedGreenHealth: active.projectedGreenHealth,
        projectedResilience: active.projectedResilience,
        aiAnalysis: resultText,
        narrativeText: active.narrativeText,
        baselineDna: active.baselineDna,
        projectedDna: active.projectedDna,
      );

      final updatedList = state.scenarios.map((s) => s.id == active.id ? updatedActive : s).toList();
      state = state.copyWith(
        scenarios: updatedList,
        activeScenario: updatedActive,
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  Future<bool> runAIBlueprint() async {
    final active = state.activeScenario;
    if (active == null) {
      state = state.copyWith(errorMessage: 'Tidak ada skenario aktif terpilih.');
      return false;
    }
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final resultText = await _scenarioRepository.runScenarioBlueprint(active.id);
      
      final updatedActive = ScenarioModel(
        id: active.id,
        villageId: active.villageId,
        scenarioName: active.scenarioName,
        selectedPrograms: active.selectedPrograms,
        baselineWasteHealth: active.baselineWasteHealth,
        baselineWaterHealth: active.baselineWaterHealth,
        baselineGreenHealth: active.baselineGreenHealth,
        baselineResilience: active.baselineResilience,
        projectedWasteHealth: active.projectedWasteHealth,
        projectedWaterHealth: active.projectedWaterHealth,
        projectedGreenHealth: active.projectedGreenHealth,
        projectedResilience: active.projectedResilience,
        aiAnalysis: active.aiAnalysis,
        narrativeText: resultText,
        baselineDna: active.baselineDna,
        projectedDna: active.projectedDna,
      );

      final updatedList = state.scenarios.map((s) => s.id == active.id ? updatedActive : s).toList();
      state = state.copyWith(
        scenarios: updatedList,
        activeScenario: updatedActive,
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  void clear() {
    state = ScenarioState();
  }
}

// Provider
final scenarioControllerProvider = StateNotifierProvider<ScenarioNotifier, ScenarioState>((ref) {
  final repository = ref.watch(scenarioRepositoryProvider);
  return ScenarioNotifier(repository);
});
