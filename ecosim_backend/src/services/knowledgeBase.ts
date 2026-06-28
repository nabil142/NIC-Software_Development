export type ImpactLevel = 'Strong' | 'Moderate' | 'None';

export interface InterventionProgram {
  id: string;
  name: string;
  description: string;
  category: 'waste' | 'water' | 'green' | 'resilience';
  impacts: {
    waste_health: ImpactLevel;
    water_health: ImpactLevel;
    green_health: ImpactLevel;
    resilience: ImpactLevel;
  };
  cost: 'rendah' | 'sedang' | 'tinggi';
  months: number;
  icon: string;
  color: string;
  bgColor: string;
}

export const PROGRAMS: InterventionProgram[] = [
  {
    id: 'bank_sampah',
    name: 'Bank Sampah',
    description: 'Sistem tabungan sampah berbasis komunitas dengan pemilahan dan daur ulang terpadu.',
    category: 'waste',
    impacts: { waste_health: 'Strong', water_health: 'None', green_health: 'Moderate', resilience: 'None' },
    cost: 'rendah',
    months: 3,
    icon: '♻',
    color: '#92400e',
    bgColor: '#fef3c7',
  },
  {
    id: 'penghijauan',
    name: 'Penghijauan',
    description: 'Program penanaman pohon dan restorasi ruang hijau desa secara masif.',
    category: 'green',
    impacts: { waste_health: 'None', water_health: 'None', green_health: 'Strong', resilience: 'Moderate' },
    cost: 'sedang',
    months: 12,
    icon: '🌳',
    color: '#166534',
    bgColor: '#dcfce7',
  },
  {
    id: 'biopori',
    name: 'Biopori',
    description: 'Lubang resapan vertikal untuk pengolahan air dan peningkatan kesuburan tanah.',
    category: 'water',
    impacts: { waste_health: 'None', water_health: 'Moderate', green_health: 'None', resilience: 'Strong' },
    cost: 'rendah',
    months: 2,
    icon: '🕳',
    color: '#1e40af',
    bgColor: '#dbeafe',
  },
  {
    id: 'sumur_resapan',
    name: 'Sumur Resapan',
    description: 'Infrastruktur resapan air hujan untuk mengisi cadangan air tanah dan mitigasi banjir.',
    category: 'resilience',
    impacts: { waste_health: 'None', water_health: 'Moderate', green_health: 'None', resilience: 'Strong' },
    cost: 'sedang',
    months: 4,
    icon: '💧',
    color: '#0e7490',
    bgColor: '#cffafe',
  },
  {
    id: 'rehabilitasi_sungai',
    name: 'Rehabilitasi Sungai',
    description: 'Pemulihan ekosistem sungai secara menyeluruh termasuk pembersihan dan penghijauan sempadan.',
    category: 'water',
    impacts: { waste_health: 'None', water_health: 'Strong', green_health: 'None', resilience: 'Moderate' },
    cost: 'tinggi',
    months: 18,
    icon: '🌊',
    color: '#0369a1',
    bgColor: '#e0f2fe',
  },
  {
    id: 'komposter_komunal',
    name: 'Komposter Komunal',
    description: 'Fasilitas pengomposan sampah organik skala desa untuk pertanian dan taman.',
    category: 'waste',
    impacts: { waste_health: 'Strong', water_health: 'None', green_health: 'Moderate', resilience: 'None' },
    cost: 'rendah',
    months: 2,
    icon: '🏡',
    color: '#4d7c0f',
    bgColor: '#ecfccb',
  },
];

export const getProgramById = (id: string): InterventionProgram | undefined =>
  PROGRAMS.find((p) => p.id === id);
