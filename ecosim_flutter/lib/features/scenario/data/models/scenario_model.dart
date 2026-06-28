import '../../../assessment/data/models/assessment_model.dart';

class ScenarioModel {
  final String id;
  final String villageId;
  final String scenarioName;
  final List<String> selectedPrograms;
  final int baselineWasteHealth;
  final int baselineWaterHealth;
  final int baselineGreenHealth;
  final int baselineResilience;
  final int projectedWasteHealth;
  final int projectedWaterHealth;
  final int projectedGreenHealth;
  final int projectedResilience;
  final String? aiAnalysis;
  final String? narrativeText;
  final DNAScoresModel? baselineDna;
  final DNAScoresModel? projectedDna;

  ScenarioModel({
    required this.id,
    required this.villageId,
    required this.scenarioName,
    required this.selectedPrograms,
    required this.baselineWasteHealth,
    required this.baselineWaterHealth,
    required this.baselineGreenHealth,
    required this.baselineResilience,
    required this.projectedWasteHealth,
    required this.projectedWaterHealth,
    required this.projectedGreenHealth,
    required this.projectedResilience,
    this.aiAnalysis,
    this.narrativeText,
    this.baselineDna,
    this.projectedDna,
  });

  factory ScenarioModel.fromJson(Map<String, dynamic> json) {
    return ScenarioModel(
      id: json['id'] as String,
      villageId: json['villageId'] as String,
      scenarioName: json['scenarioName'] as String,
      selectedPrograms: List<String>.from(json['selectedPrograms'] as List),
      baselineWasteHealth: json['baselineWasteHealth'] as int,
      baselineWaterHealth: json['baselineWaterHealth'] as int,
      baselineGreenHealth: json['baselineGreenHealth'] as int,
      baselineResilience: json['baselineResilience'] as int,
      projectedWasteHealth: json['projectedWasteHealth'] as int,
      projectedWaterHealth: json['projectedWaterHealth'] as int,
      projectedGreenHealth: json['projectedGreenHealth'] as int,
      projectedResilience: json['projectedResilience'] as int,
      aiAnalysis: json['aiAnalysis'] as String?,
      narrativeText: json['narrativeText'] as String?,
      baselineDna: json['baseline_dna'] != null 
          ? DNAScoresModel.fromJson(json['baseline_dna'] as Map<String, dynamic>)
          : null,
      projectedDna: json['projected_dna'] != null
          ? DNAScoresModel.fromJson(json['projected_dna'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'villageId': villageId,
      'scenarioName': scenarioName,
      'selectedPrograms': selectedPrograms,
      'baselineWasteHealth': baselineWasteHealth,
      'baselineWaterHealth': baselineWaterHealth,
      'baselineGreenHealth': baselineGreenHealth,
      'baselineResilience': baselineResilience,
      'projectedWasteHealth': projectedWasteHealth,
      'projectedWaterHealth': projectedWaterHealth,
      'projectedGreenHealth': projectedGreenHealth,
      'projectedResilience': projectedResilience,
      'aiAnalysis': aiAnalysis,
      'narrativeText': narrativeText,
    };
  }
}
