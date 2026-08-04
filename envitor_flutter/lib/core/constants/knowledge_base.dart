class InterventionProgram {
  final String id;
  final String name;
  final String description;
  final String category;
  final Map<String, String> impacts;
  final String cost;
  final int months;
  final String icon;
  final String colorHex;
  final String bgColorHex;

  InterventionProgram({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.impacts,
    required this.cost,
    required this.months,
    required this.icon,
    required this.colorHex,
    required this.bgColorHex,
  });
}

final List<InterventionProgram> programsCatalog = [
  InterventionProgram(
    id: 'bank_sampah',
    name: 'Bank Sampah',
    description: 'Sistem tabungan sampah berbasis komunitas',
    category: 'waste',
    impacts: {
      'waste_health': 'Strong',
      'water_health': 'None',
      'green_health': 'Moderate',
      'resilience': 'None',
    },
    cost: 'rendah',
    months: 3,
    icon: '♻',
    colorHex: '92400E',
    bgColorHex: 'FEF3C7',
  ),
  InterventionProgram(
    id: 'penghijauan',
    name: 'Penghijauan',
    description: 'Program Penanaman pohon dan restorasi ruang hijau',
    category: 'green',
    impacts: {
      'waste_health': 'None',
      'water_health': 'None',
      'green_health': 'Strong',
      'resilience': 'Moderate',
    },
    cost: 'sedang',
    months: 12,
    icon: '🌳',
    colorHex: '166534',
    bgColorHex: 'DCFCE7',
  ),
  InterventionProgram(
    id: 'biopori',
    name: 'Biopori',
    description:
        'Lubang resapan untuk pengolahan air dan meningkatkan kesuburan tanah',
    category: 'water',
    impacts: {
      'waste_health': 'None',
      'water_health': 'Moderate',
      'green_health': 'None',
      'resilience': 'Strong',
    },
    cost: 'rendah',
    months: 2,
    icon: '🕳',
    colorHex: '1E40AF',
    bgColorHex: 'DBEAFE',
  ),
  InterventionProgram(
    id: 'sumur_resapan',
    name: 'Sumur Resapan',
    description: 'Infrastruktur resapan air hujan untuk mitigasi',
    category: 'resilience',
    impacts: {
      'waste_health': 'None',
      'water_health': 'Moderate',
      'green_health': 'None',
      'resilience': 'Strong',
    },
    cost: 'sedang',
    months: 4,
    icon: '💧',
    colorHex: '0E7490',
    bgColorHex: 'CFFAFE',
  ),
  InterventionProgram(
    id: 'rehabilitasi_sungai',
    name: 'Rehabilitasi Sungai',
    description: 'Pemulihan ekosistem sungai secara menyeluruh',
    category: 'water',
    impacts: {
      'waste_health': 'None',
      'water_health': 'Strong',
      'green_health': 'None',
      'resilience': 'Moderate',
    },
    cost: 'tinggi',
    months: 18,
    icon: '🌊',
    colorHex: '0369A1',
    bgColorHex: 'E0F2FE',
  ),
  InterventionProgram(
    id: 'komposter_komunal',
    name: 'Komposter Komunal',
    description:
        'Fasilitas pengomposan sampah organik skala desa untuk pertanian dan taman',
    category: 'waste',
    impacts: {
      'waste_health': 'Strong',
      'water_health': 'None',
      'green_health': 'Moderate',
      'resilience': 'None',
    },
    cost: 'rendah',
    months: 2,
    icon: '🏡',
    colorHex: '4D7C0F',
    bgColorHex: 'ECFCCB',
  ),
];

InterventionProgram? getProgramById(String id) {
  try {
    return programsCatalog.firstWhere((p) => p.id == id);
  } catch (_) {
    return null;
  }
}
