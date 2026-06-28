import { DNAScores, StatusLevel } from './ruleEngine';
import { getProgramById } from './knowledgeBase';

export const statusToVal = (status: StatusLevel): number => {
  switch (status) {
    case 'Poor': return 1;
    case 'Fair': return 2;
    case 'Good': return 3;
    case 'Excellent': return 4;
    default: return 1;
  }
};

export const valToStatus = (val: number): StatusLevel => {
  const rounded = Math.max(1, Math.min(4, Math.round(val)));
  if (rounded === 1) return 'Poor';
  if (rounded === 2) return 'Fair';
  if (rounded === 3) return 'Good';
  return 'Excellent';
};

export function projectScenario(baseline: DNAScores, programIds: string[]): DNAScores {
  const result = { ...baseline };
  const keys: (keyof DNAScores)[] = ['waste_health', 'water_health', 'green_health', 'resilience'];

  for (const key of keys) {
    let val = statusToVal(baseline[key]);

    for (const id of programIds) {
      const program = getProgramById(id);
      if (!program) continue;

      const impact = program.impacts[key];
      if (impact === 'Strong') {
        val += 2;
      } else if (impact === 'Moderate') {
        val += 1;
      }
    }

    result[key] = valToStatus(val);
  }

  return result;
}

export function overallStatus(dna: DNAScores): StatusLevel {
  const avg = (statusToVal(dna.waste_health) + statusToVal(dna.water_health) + statusToVal(dna.green_health) + statusToVal(dna.resilience)) / 4;
  return valToStatus(avg);
}

export function deltaScore(baseline: DNAScores, projected: DNAScores): number {
  const baseAvg = (statusToVal(baseline.waste_health) + statusToVal(baseline.water_health) + statusToVal(baseline.green_health) + statusToVal(baseline.resilience)) / 4;
  const projAvg = (statusToVal(projected.waste_health) + statusToVal(projected.water_health) + statusToVal(projected.green_health) + statusToVal(projected.resilience)) / 4;
  return parseFloat((projAvg - baseAvg).toFixed(2));
}
