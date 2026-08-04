class VillageModel {
  final String id;
  final String userId;
  final String villageName;
  final int population;
  final double areaKm2;
  final String? districtName;
  final String? cityName;
  final String? potential;

  VillageModel({
    required this.id,
    required this.userId,
    required this.villageName,
    required this.population,
    required this.areaKm2,
    this.districtName,
    this.cityName,
    this.potential,
  });

  factory VillageModel.fromJson(Map<String, dynamic> json) {
    return VillageModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      villageName: json['villageName'] as String,
      population: json['population'] as int,
      areaKm2: (json['areaKm2'] as num).toDouble(),
      districtName: json['districtName'] as String?,
      cityName: json['cityName'] as String?,
      potential: json['potential'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'villageName': villageName,
      'population': population,
      'areaKm2': areaKm2,
      'districtName': districtName,
      'cityName': cityName,
      'potential': potential,
    };
  }
}
