import { Response } from 'express';
import { AuthenticatedRequest } from '../middlewares/authMiddleware';
import { prisma } from '../lib/prisma';
import { projectScenario, statusToVal, valToStatus, deltaScore } from '../services/scenarioEngine';
import { getProgramById } from '../services/knowledgeBase';
import { runGeminiAnalysis } from '../services/geminiService';
import { DNAScores } from '../services/ruleEngine';

export async function createScenario(req: AuthenticatedRequest, res: Response) {
  const userId = req.user?.id;
  const { villageId, scenarioName, selectedPrograms } = req.body;

  if (!userId) {
    return res.status(401).json({ error: 'Sesi kedaluwarsa atau tidak terotorisasi.' });
  }

  if (!villageId || !scenarioName || !selectedPrograms) {
    return res.status(400).json({ error: 'villageId, scenarioName, dan selectedPrograms wajib diisi.' });
  }

  try {
    // Verify village
    const village = await prisma.village.findFirst({
      where: { id: villageId, userId }
    });

    if (!village) {
      return res.status(403).json({ error: 'Akses ditolak. Desa bukan milik Anda.' });
    }

    // Get latest assessment to derive baseline DNA
    const latestAssessment = await prisma.environmentalAssessment.findFirst({
      where: { villageId },
      orderBy: { createdAt: 'desc' }
    });

    if (!latestAssessment) {
      return res.status(400).json({ error: 'Desa harus melakukan asesmen terlebih dahulu.' });
    }

    // 1. Calculate baseline DNA
    const { calculateDNA } = require('../services/ruleEngine');
    const baseline = calculateDNA(latestAssessment);

    // 2. Project DNA after programs
    const projected = projectScenario(baseline, selectedPrograms);

    // Save to Neon DB
    const scenario = await prisma.scenario.create({
      data: {
        villageId,
        scenarioName,
        selectedPrograms,
        baselineWasteHealth: statusToVal(baseline.waste_health),
        baselineWaterHealth: statusToVal(baseline.water_health),
        baselineGreenHealth: statusToVal(baseline.green_health),
        baselineResilience: statusToVal(baseline.resilience),
        projectedWasteHealth: statusToVal(projected.waste_health),
        projectedWaterHealth: statusToVal(projected.water_health),
        projectedGreenHealth: statusToVal(projected.green_health),
        projectedResilience: statusToVal(projected.resilience)
      }
    });

    // Map response model to qualitative labels
    const responseScenario = {
      ...scenario,
      baseline_dna: baseline,
      projected_dna: projected
    };

    return res.status(201).json({
      message: 'Skenario berhasil disimpan.',
      scenario: responseScenario
    });
  } catch (err: any) {
    console.error('Error saat menyimpan skenario:', err);
    return res.status(500).json({ error: err.message || 'Gagal menyimpan skenario.' });
  }
}

export async function getScenarios(req: AuthenticatedRequest, res: Response) {
  const userId = req.user?.id;
  const { villageId } = req.query;

  if (!userId) {
    return res.status(401).json({ error: 'Sesi kedaluwarsa atau tidak terotorisasi.' });
  }

  if (!villageId || typeof villageId !== 'string') {
    return res.status(400).json({ error: 'villageId diperlukan dalam query.' });
  }

  try {
    // Verify village
    const village = await prisma.village.findFirst({
      where: { id: villageId, userId }
    });

    if (!village) {
      return res.status(403).json({ error: 'Akses ditolak. Desa bukan milik Anda.' });
    }

    const scenarios = await prisma.scenario.findMany({
      where: { villageId },
      orderBy: { createdAt: 'desc' }
    });

    // Map to qualitative labels
    const mappedScenarios = scenarios.map((s) => ({
      ...s,
      baseline_dna: {
        waste_health: valToStatus(s.baselineWasteHealth),
        water_health: valToStatus(s.baselineWaterHealth),
        green_health: valToStatus(s.baselineGreenHealth),
        resilience: valToStatus(s.baselineResilience)
      },
      projected_dna: {
        waste_health: valToStatus(s.projectedWasteHealth),
        water_health: valToStatus(s.projectedWaterHealth),
        green_health: valToStatus(s.projectedGreenHealth),
        resilience: valToStatus(s.projectedResilience)
      }
    }));

    return res.status(200).json({ scenarios: mappedScenarios });
  } catch (err: any) {
    console.error('Error saat memuat skenarios:', err);
    return res.status(500).json({ error: err.message || 'Gagal memuat skenarios.' });
  }
}

export async function runScenarioAnalysis(req: AuthenticatedRequest, res: Response) {
  const userId = req.user?.id;
  const { id } = req.params; // Active Scenario ID

  if (!userId) {
    return res.status(401).json({ error: 'Sesi kedaluwarsa atau tidak terotorisasi.' });
  }

  try {
    // Find active scenario
    const activeScenario = await prisma.scenario.findUnique({ where: { id } });
    if (!activeScenario) {
      return res.status(404).json({ error: 'Skenario tidak ditemukan.' });
    }

    // Verify village ownership
    const village = await prisma.village.findFirst({
      where: { id: activeScenario.villageId, userId }
    });
    if (!village) {
      return res.status(403).json({ error: 'Akses ditolak.' });
    }

    // Load up to 3 scenarios for comparative analysis
    const list = await prisma.scenario.findMany({
      where: { villageId: village.id },
      orderBy: { createdAt: 'desc' },
      take: 3
    });

    const baselineDna = {
      waste_health: valToStatus(activeScenario.baselineWasteHealth),
      water_health: valToStatus(activeScenario.baselineWaterHealth),
      green_health: valToStatus(activeScenario.baselineGreenHealth),
      resilience: valToStatus(activeScenario.baselineResilience)
    };

    const scenariosPayload = list.map((s) => {
      const base = {
        waste_health: valToStatus(s.baselineWasteHealth),
        water_health: valToStatus(s.baselineWaterHealth),
        green_health: valToStatus(s.baselineGreenHealth),
        resilience: valToStatus(s.baselineResilience)
      };
      const proj = {
        waste_health: valToStatus(s.projectedWasteHealth),
        water_health: valToStatus(s.projectedWaterHealth),
        green_health: valToStatus(s.projectedGreenHealth),
        resilience: valToStatus(s.projectedResilience)
      };
      return {
        name: s.scenarioName,
        programs: s.selectedPrograms.map(pId => getProgramById(pId)?.name ?? pId),
        projected: proj,
        delta: deltaScore(base, proj)
      };
    });

    const aiAnalysisResult = await runGeminiAnalysis({
      mode: 'analysis',
      village: {
        name: village.villageName,
        population: village.population,
        agriculturalAreaKm2: village.agriculturalAreaKm2
      },
      baseline: baselineDna,
      scenarios: scenariosPayload
    });

    // Update active scenario with the analysis result in Neon DB
    await prisma.scenario.update({
      where: { id },
      data: { aiAnalysis: aiAnalysisResult }
    });

    return res.status(200).json({ result: aiAnalysisResult });
  } catch (err: any) {
    console.error('Error saat analisis AI:', err);
    return res.status(500).json({ error: err.message || 'Gagal menjalankan analisis AI.' });
  }
}

export async function runScenarioBlueprint(req: AuthenticatedRequest, res: Response) {
  const userId = req.user?.id;
  const { id } = req.params; // Chosen Scenario ID

  if (!userId) {
    return res.status(401).json({ error: 'Sesi kedaluwarsa atau tidak terotorisasi.' });
  }

  try {
    // Find scenario
    const chosenScenario = await prisma.scenario.findUnique({ where: { id } });
    if (!chosenScenario) {
      return res.status(404).json({ error: 'Skenario tidak ditemukan.' });
    }

    // Verify village ownership
    const village = await prisma.village.findFirst({
      where: { id: chosenScenario.villageId, userId }
    });
    if (!village) {
      return res.status(403).json({ error: 'Akses ditolak.' });
    }

    const baselineDna = {
      waste_health: valToStatus(chosenScenario.baselineWasteHealth),
      water_health: valToStatus(chosenScenario.baselineWaterHealth),
      green_health: valToStatus(chosenScenario.baselineGreenHealth),
      resilience: valToStatus(chosenScenario.baselineResilience)
    };

    const projectedDna = {
      waste_health: valToStatus(chosenScenario.projectedWasteHealth),
      water_health: valToStatus(chosenScenario.projectedWaterHealth),
      green_health: valToStatus(chosenScenario.projectedGreenHealth),
      resilience: valToStatus(chosenScenario.projectedResilience)
    };

    const blueprintResult = await runGeminiAnalysis({
      mode: 'blueprint',
      village: {
        name: village.villageName,
        population: village.population,
        agriculturalAreaKm2: village.agriculturalAreaKm2
      },
      baseline: baselineDna,
      scenarios: [{
        name: chosenScenario.scenarioName,
        programs: chosenScenario.selectedPrograms.map(pId => getProgramById(pId)?.name ?? pId),
        projected: projectedDna
      }],
      analysisText: chosenScenario.aiAnalysis || undefined
    });

    // Update scenario with the narrative text in Neon DB
    await prisma.scenario.update({
      where: { id },
      data: { narrativeText: blueprintResult }
    });

    return res.status(200).json({ result: blueprintResult });
  } catch (err: any) {
    console.error('Error saat memproses blueprint AI:', err);
    return res.status(500).json({ error: err.message || 'Gagal memproses blueprint AI.' });
  }
}
