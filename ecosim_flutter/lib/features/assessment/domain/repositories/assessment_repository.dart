import '../../data/models/assessment_model.dart';

abstract class AssessmentRepository {
  Future<AssessmentResponseModel> createAssessment({
    required String villageId,
    required int wasteLevel,
    required String wasteManagement,
    required int waterQuality,
    required bool riverContaminated,
    required int greenSpace,
    required int floodRisk,
    required List<String> existingPrograms,
  });
  Future<AssessmentResponseModel?> getLatestAssessment(String villageId);
}
