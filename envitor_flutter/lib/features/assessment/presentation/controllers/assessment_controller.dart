import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/assessment_model.dart';
import '../../domain/repositories/assessment_repository.dart';
import '../../data/repositories/assessment_repository_impl.dart';

class AssessmentState {
  final AssessmentResponseModel? latestAssessment;
  final bool isLoading;
  final String? errorMessage;
  final bool isInitialized;

  AssessmentState({
    this.latestAssessment,
    this.isLoading = false,
    this.errorMessage,
    this.isInitialized = false,
  });

  AssessmentState copyWith({
    AssessmentResponseModel? latestAssessment,
    bool? isLoading,
    String? errorMessage,
    bool? isInitialized,
    bool clearAssessment = false,
  }) {
    return AssessmentState(
      latestAssessment:
          clearAssessment ? null : (latestAssessment ?? this.latestAssessment),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }
}

class AssessmentNotifier extends StateNotifier<AssessmentState> {
  final AssessmentRepository _assessmentRepository;

  AssessmentNotifier(this._assessmentRepository) : super(AssessmentState());

  Future<void> loadLatestAssessment(String villageId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final assessment = await _assessmentRepository.getLatestAssessment(
        villageId,
      );
      state = state.copyWith(
        latestAssessment: assessment,
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
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final response = await _assessmentRepository.createAssessment(
        villageId: villageId,
        wasteLevel: wasteLevel,
        wasteManagement: wasteManagement,
        waterQuality: waterQuality,
        riverContaminated: riverContaminated,
        greenSpace: greenSpace,
        floodRisk: floodRisk,
        existingPrograms: existingPrograms,
        potentialProblem: potentialProblem,
      );
      state = state.copyWith(latestAssessment: response, isLoading: false);
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
    state = AssessmentState();
  }
}

final assessmentControllerProvider =
    StateNotifierProvider<AssessmentNotifier, AssessmentState>((ref) {
      final repository = ref.watch(assessmentRepositoryProvider);
      return AssessmentNotifier(repository);
    });
