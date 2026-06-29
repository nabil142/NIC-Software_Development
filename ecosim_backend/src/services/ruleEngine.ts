export type StatusLevel = 'Poor' | 'Fair' | 'Good' | 'Excellent';

export interface DNAScores {
  waste_health: StatusLevel;
  water_health: StatusLevel;
  green_health: StatusLevel;
  resilience: StatusLevel;
}

export interface AssessmentInput {
  wasteLevel: number;
  wasteManagement: string;
  waterQuality: number;
  riverContaminated: boolean;
  greenSpace: number;
  floodRisk: number;
  existingPrograms: string[];
}

function mapLevel(val: number): number {
  if (val <= 3) return 0;
  if (val <= 7) return 1;
  return 2;
}

function mapWater(val: number): number {

  if (val >= 8) return 0;
  if (val >= 4) return 1;
  return 2;
}

function mapFlood(val: number): number {

  if (val >= 8) return 2;
  if (val >= 4) return 1;
  return 0;
}

export function calculateDNA(raw: AssessmentInput): DNAScores {
  const a = {
    wasteLevel: mapLevel(raw.wasteLevel),
    wasteManagement: raw.wasteManagement,
    waterQuality: mapWater(raw.waterQuality),
    riverContaminated: raw.riverContaminated,
    greenSpace: mapLevel(raw.greenSpace),
    floodRisk: mapFlood(raw.floodRisk),
    existingPrograms: raw.existingPrograms,
  };

  let waste_health: StatusLevel = 'Poor';
  if (a.wasteManagement === 'none') {
    waste_health = a.wasteLevel === 0 ? 'Fair' : 'Poor';
  } else if (a.wasteManagement === 'tps') {
    waste_health = a.wasteLevel === 2 ? 'Poor' : a.wasteLevel === 1 ? 'Fair' : 'Good';
  } else if (a.wasteManagement === 'bank_sampah' || a.wasteManagement === 'komposter') {
    waste_health = a.wasteLevel === 2 ? 'Fair' : a.wasteLevel === 1 ? 'Good' : 'Excellent';
  }

  let water_health: StatusLevel = 'Poor';
  if (a.waterQuality === 0) {
    water_health = a.riverContaminated ? 'Good' : 'Excellent';
  } else if (a.waterQuality === 1) {
    water_health = a.riverContaminated ? 'Fair' : 'Good';
  } else if (a.waterQuality === 2) {
    water_health = a.riverContaminated ? 'Poor' : 'Fair';
  }

  let green_health: StatusLevel = 'Poor';
  if (a.greenSpace === 0) {
    green_health = 'Poor';
  } else if (a.greenSpace === 1) {
    green_health = 'Fair';
  } else if (a.greenSpace === 2) {
    const hasPenghijauan = a.existingPrograms.includes('penghijauan');
    green_health = hasPenghijauan ? 'Excellent' : 'Good';
  }

  let resilience: StatusLevel = 'Poor';
  if (a.floodRisk === 2) {
    resilience = 'Poor';
  } else if (a.floodRisk === 1) {
    resilience = 'Fair';
  } else if (a.floodRisk === 0) {
    if (a.greenSpace === 0) {
      resilience = 'Fair';
    } else {
      resilience = (a.greenSpace === 2 || a.waterQuality === 0) ? 'Excellent' : 'Good';
    }
  }

  return { waste_health, water_health, green_health, resilience };
}

export interface DNADetailItem {
  score: number;
  status: StatusLevel;
  explanation: string;
}

export function getDNADetails(raw: AssessmentInput, dna: DNAScores): Record<keyof DNAScores, DNADetailItem> {
  const a = {
    wasteLevel: mapLevel(raw.wasteLevel),
    wasteManagement: raw.wasteManagement,
    waterQuality: mapWater(raw.waterQuality),
    riverContaminated: raw.riverContaminated,
    greenSpace: mapLevel(raw.greenSpace),
    floodRisk: mapFlood(raw.floodRisk),
    existingPrograms: raw.existingPrograms,
  };

  const scoreMap: Record<StatusLevel, number> = {
    'Poor': 1,
    'Fair': 2,
    'Good': 3,
    'Excellent': 4
  };

  const causes: Record<keyof DNAScores, string[]> = {
    waste_health: [],
    water_health: [],
    green_health: [],
    resilience: [],
  };

  if (a.wasteManagement === 'none') {
    causes.waste_health.push('Belum tersedia sarana TPS atau pembuangan sampah terorganisir.');
  } else if (a.wasteManagement === 'tps') {
    causes.waste_health.push('Pengelolaan sampah baru sebatas pengumpulan di TPS (belum ada daur ulang/kompos).');
  } else if (a.wasteManagement === 'bank_sampah') {
    causes.waste_health.push('Desa telah mengaktifkan program Bank Sampah komunitas.');
  } else if (a.wasteManagement === 'komposter') {
    causes.waste_health.push('Desa memanfaatkan komposter komunal untuk sampah organik.');
  }

  if (a.wasteLevel === 2) {
    causes.waste_health.push('Volume timbulan sampah liar/tidak terkelola di lingkungan masih tinggi.');
  } else if (a.wasteLevel === 1) {
    causes.waste_health.push('Masih terlihat tumpukan sampah tidak terkelola di beberapa titik.');
  } else {
    causes.waste_health.push('Sampah liar tidak terkelola sangat minim/hampir tidak ada.');
  }

  if (a.waterQuality === 2) {
    causes.water_health.push('Sumber air warga sering mengalami kekeruhan atau berbau.');
  } else if (a.waterQuality === 1) {
    causes.water_health.push('Sumber air warga kadang keruh atau berbau, terutama di musim hujan.');
  } else {
    causes.water_health.push('Sumber air warga jernih, bersih, dan tidak berbau.');
  }

  if (a.riverContaminated) {
    causes.water_health.push('Sungai terdekat dalam kondisi tercemar banyak sampah atau limbah.');
  } else {
    causes.water_health.push('Sungai terdekat dalam kondisi bersih bebas tumpukan limbah.');
  }

  if (a.greenSpace === 0) {
    causes.green_health.push('Tidak ada program penghijauan desa yang berjalan aktif.');
  } else if (a.greenSpace === 1) {
    causes.green_health.push('Program penghijauan desa masih terbatas pada beberapa area kecil.');
  } else {
    causes.green_health.push('Program penanaman pohon dan pelestarian ruang terbuka hijau berjalan rutin.');
  }

  if (a.existingPrograms.includes('penghijauan')) {
    causes.green_health.push('Didukung partisipasi warga dalam penanaman pohon mandiri.');
  }

  if (a.floodRisk === 2) {
    causes.resilience.push('Desa sering dilanda banjir (lebih dari 2 kali kejadian dalam setahun).');
  } else if (a.floodRisk === 1) {
    causes.resilience.push('Kerentanan banjir tingkat sedang (1-2 kali kejadian per tahun).');
  } else {
    causes.resilience.push('Desa relatif aman dan jarang atau tidak pernah banjir.');
  }

  if (a.greenSpace === 0) {
    causes.resilience.push('Ketiadaan area resapan vegetasi hijau memperlemah ketahanan tanah menyerap limpahan air.');
  }

  return {
    waste_health: {
      score: scoreMap[dna.waste_health],
      status: dna.waste_health,
      explanation: causes.waste_health.join(' ')
    },
    water_health: {
      score: scoreMap[dna.water_health],
      status: dna.water_health,
      explanation: causes.water_health.join(' ')
    },
    green_health: {
      score: scoreMap[dna.green_health],
      status: dna.green_health,
      explanation: causes.green_health.join(' ')
    },
    resilience: {
      score: scoreMap[dna.resilience],
      status: dna.resilience,
      explanation: causes.resilience.join(' ')
    }
  };
}

export interface DNAInsightItem {
  dimension: string;
  status: StatusLevel;
  priority: 'High' | 'Medium' | 'Low';
  insight: string;
}

export function getDNAInsights(dna: DNAScores): DNAInsightItem[] {
  const priorityMap: Record<StatusLevel, 'High' | 'Medium' | 'Low'> = {
    'Poor': 'High',
    'Fair': 'Medium',
    'Good': 'Low',
    'Excellent': 'Low'
  };

  return [
    {
      dimension: 'Sanitasi & Pengelolaan Sampah',
      status: dna.waste_health,
      priority: priorityMap[dna.waste_health],
      insight: dna.waste_health === 'Poor' || dna.waste_health === 'Fair'
        ? 'Pengelolaan sampah menjadi isu utama dan butuh program prioritas. Pertimbangkan pengadaan TPS teratur dan sosialisasi pemilahan sampah.'
        : 'Sistem pengelolaan sampah di desa dalam kondisi memadai. Pertahankan program pemilahan dan daur ulang aktif.'
    },
    {
      dimension: 'Kualitas Air Konsumsi',
      status: dna.water_health,
      priority: priorityMap[dna.water_health],
      insight: dna.water_health === 'Poor' || dna.water_health === 'Fair'
        ? 'Kualitas air/sungai perlu perhatian serius demi kesehatan warga. Lakukan pembersihan rutin aliran sungai dan uji kelayakan sumur air.'
        : 'Kualitas sumber daya air dan kebersihan sungai terjaga baik. Pertahankan perlindungan sumber air alami.'
    },
    {
      dimension: 'Kelestarian Hijau & Keanekaragaman',
      status: dna.green_health,
      priority: priorityMap[dna.green_health],
      insight: dna.green_health === 'Poor' || dna.green_health === 'Fair'
        ? 'Kawasan konservasi lingkungan/penghijauan masih sangat minim. Lakukan reboisasi massal, penanaman pohon pelindung, dan pembukaan taman desa.'
        : 'Konservasi lingkungan dan ruang hijau desa berjalan dengan baik. Teruskan gerakan penanaman pohon berkala.'
    },
    {
      dimension: 'Mitigasi Bencana & Resiliensi',
      status: dna.resilience,
      priority: priorityMap[dna.resilience],
      insight: dna.resilience === 'Poor' || dna.resilience === 'Fair'
        ? 'Tingkat kesiapsiagaan dan ketahanan terhadap bencana banjir masih lemah. Bangun infrastruktur sumur resapan, biopori, dan sistem peringatan dini.'
        : 'Desa memiliki ketahanan dan daya dukung bencana banjir yang kuat. Lakukan pemeliharaan berkala infrastruktur drainase.'
    }
  ];
}
