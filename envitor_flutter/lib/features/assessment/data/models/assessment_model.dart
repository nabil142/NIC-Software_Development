class AssessmentModel {
  final String id;
  final String villageId;
  final int wasteLevel;
  final String wasteManagement;
  final int waterQuality;
  final bool riverContaminated;
  final int greenSpace;
  final int floodRisk;
  final List<String> existingPrograms;
  final String? potentialProblem;
  final String? potentialSolutionAI;

  AssessmentModel({
    required this.id,
    required this.villageId,
    required this.wasteLevel,
    required this.wasteManagement,
    required this.waterQuality,
    required this.riverContaminated,
    required this.greenSpace,
    required this.floodRisk,
    required this.existingPrograms,
    this.potentialProblem,
    this.potentialSolutionAI,
  });

  factory AssessmentModel.fromJson(Map<String, dynamic> json) {
    return AssessmentModel(
      id: json['id'] as String,
      villageId: json['villageId'] as String,
      wasteLevel: json['wasteLevel'] as int,
      wasteManagement: json['wasteManagement'] as String,
      waterQuality: json['waterQuality'] as int,
      riverContaminated: json['riverContaminated'] as bool,
      greenSpace: json['greenSpace'] as int,
      floodRisk: json['floodRisk'] as int,
      existingPrograms: List<String>.from(json['existingPrograms'] as List),
      potentialProblem: json['potentialProblem'] as String?,
      potentialSolutionAI: json['potentialSolutionAI'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'villageId': villageId,
      'wasteLevel': wasteLevel,
      'wasteManagement': wasteManagement,
      'waterQuality': waterQuality,
      'riverContaminated': riverContaminated,
      'greenSpace': greenSpace,
      'floodRisk': floodRisk,
      'existingPrograms': existingPrograms,
      'potentialProblem': potentialProblem,
      'potentialSolutionAI': potentialSolutionAI,
    };
  }
}

class DNAScoresModel {
  final String wasteHealth;
  final String waterHealth;
  final String greenHealth;
  final String resilience;

  DNAScoresModel({
    required this.wasteHealth,
    required this.waterHealth,
    required this.greenHealth,
    required this.resilience,
  });

  factory DNAScoresModel.fromJson(Map<String, dynamic> json) {
    return DNAScoresModel(
      wasteHealth: json['waste_health'] as String,
      waterHealth: json['water_health'] as String,
      greenHealth: json['green_health'] as String,
      resilience: json['resilience'] as String,
    );
  }
}

class DNADetailItem {
  final int score;
  final String status;
  final String explanation;

  DNADetailItem({
    required this.score,
    required this.status,
    required this.explanation,
  });

  factory DNADetailItem.fromJson(Map<String, dynamic> json) {
    return DNADetailItem(
      score: json['score'] as int,
      status: json['status'] as String,
      explanation: json['explanation'] as String,
    );
  }
}

class DNADetailsModel {
  final DNADetailItem wasteHealth;
  final DNADetailItem waterHealth;
  final DNADetailItem greenHealth;
  final DNADetailItem resilience;

  DNADetailsModel({
    required this.wasteHealth,
    required this.waterHealth,
    required this.greenHealth,
    required this.resilience,
  });

  factory DNADetailsModel.fromJson(Map<String, dynamic> json) {
    return DNADetailsModel(
      wasteHealth: DNADetailItem.fromJson(
        json['waste_health'] as Map<String, dynamic>,
      ),
      waterHealth: DNADetailItem.fromJson(
        json['water_health'] as Map<String, dynamic>,
      ),
      greenHealth: DNADetailItem.fromJson(
        json['green_health'] as Map<String, dynamic>,
      ),
      resilience: DNADetailItem.fromJson(
        json['resilience'] as Map<String, dynamic>,
      ),
    );
  }
}

class DNAInsightItem {
  final String dimension;
  final String status;
  final String priority;
  final String insight;

  DNAInsightItem({
    required this.dimension,
    required this.status,
    required this.priority,
    required this.insight,
  });

  factory DNAInsightItem.fromJson(Map<String, dynamic> json) {
    return DNAInsightItem(
      dimension: json['dimension'] as String,
      status: json['status'] as String,
      priority: json['priority'] as String,
      insight: json['insight'] as String,
    );
  }
}

class AssessmentResponseModel {
  final AssessmentModel assessment;
  final DNAScoresModel dnaScores;
  final DNADetailsModel dnaDetails;
  final List<DNAInsightItem> dnaInsights;

  AssessmentResponseModel({
    required this.assessment,
    required this.dnaScores,
    required this.dnaDetails,
    required this.dnaInsights,
  });

  factory AssessmentResponseModel.fromJson(Map<String, dynamic> json) {
    return AssessmentResponseModel(
      assessment: AssessmentModel.fromJson(
        json['assessment'] as Map<String, dynamic>,
      ),
      dnaScores: DNAScoresModel.fromJson(
        json['dnaScores'] as Map<String, dynamic>,
      ),
      dnaDetails: DNADetailsModel.fromJson(
        json['dnaDetails'] as Map<String, dynamic>,
      ),
      dnaInsights:
          (json['dnaInsights'] as List)
              .map(
                (item) => DNAInsightItem.fromJson(item as Map<String, dynamic>),
              )
              .toList(),
    );
  }
}
