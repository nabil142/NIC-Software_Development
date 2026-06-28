class VillageModel {
  final String id;
  final String userId;
  final String villageName;
  final int population;
  final double areaKm2;
  final double agriculturalAreaKm2;

  VillageModel({
    required this.id,
    required this.userId,
    required this.villageName,
    required this.population,
    required this.areaKm2,
    required this.agriculturalAreaKm2,
  });

  factory VillageModel.fromJson(Map<String, dynamic> json) {
    return VillageModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      villageName: json['villageName'] as String,
      population: json['population'] as int,
      areaKm2: (json['areaKm2'] as num).toDouble(),
      agriculturalAreaKm2: (json['agriculturalAreaKm2'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'villageName': villageName,
      'population': population,
      'areaKm2': areaKm2,
      'agriculturalAreaKm2': agriculturalAreaKm2,
    };
  }
}
