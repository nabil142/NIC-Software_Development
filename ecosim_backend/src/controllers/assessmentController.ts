import { Response } from 'express';
import { AuthenticatedRequest } from '../middlewares/authMiddleware';
import { prisma } from '../lib/prisma';
import { calculateDNA, getDNADetails, getDNAInsights } from '../services/ruleEngine';

import { runGeminiAnalysis } from '../services/geminiService';

export async function createAssessment(req: AuthenticatedRequest, res: Response) {
  const userId = req.user?.id;
  const { 
    villageId, 
    wasteLevel, 
    wasteManagement, 
    waterQuality, 
    riverContaminated, 
    greenSpace, 
    floodRisk, 
    existingPrograms,
    potentialProblem
  } = req.body;

  if (!userId) {
    return res.status(401).json({ error: 'Sesi kedaluwarsa atau tidak terotorisasi.' });
  }

  if (!villageId || wasteLevel === undefined || !wasteManagement || waterQuality === undefined || 
      riverContaminated === undefined || greenSpace === undefined || floodRisk === undefined || !existingPrograms) {
    return res.status(400).json({ error: 'Semua input kuesioner asesmen wajib diisi.' });
  }

  try {

    const village = await prisma.village.findFirst({
      where: { id: villageId, userId }
    });

    if (!village) {
      return res.status(403).json({ error: 'Akses ditolak. Desa bukan milik Anda.' });
    }

    let potentialSolutionAI: string | null = null;
    if (potentialProblem && potentialProblem.trim().length > 0) {
      try {
        potentialSolutionAI = await runGeminiAnalysis({
          mode: 'potential_solution',
          village: {
            name: village.villageName,
            population: village.population
          },
          baseline: { waste_health: 'Fair', water_health: 'Fair', green_health: 'Fair', resilience: 'Fair' },
          scenarios: [],
          potentialProblem: potentialProblem.trim()
        });
      } catch (aiErr) {
        console.warn('Gagal memproses solusi AI untuk potensi desa:', aiErr);

      }
    }

    const assessment = await prisma.environmentalAssessment.create({
      data: {
        villageId,
        wasteLevel: parseInt(wasteLevel),
        wasteManagement,
        waterQuality: parseInt(waterQuality),
        riverContaminated: !!riverContaminated,
        greenSpace: parseInt(greenSpace),
        floodRisk: parseInt(floodRisk),
        existingPrograms,
        potentialProblem: potentialProblem?.trim() || null,
        potentialSolutionAI
      }
    });

    const dnaScores = calculateDNA(assessment);
    const dnaDetails = getDNADetails(assessment, dnaScores);
    const dnaInsights = getDNAInsights(dnaScores);

    return res.status(201).json({
      message: 'Asesmen berhasil disimpan.',
      assessment,
      dnaScores,
      dnaDetails,
      dnaInsights
    });
  } catch (err: any) {
    console.error('Error saat menyimpan asesmen:', err);
    return res.status(500).json({ error: err.message || 'Gagal menyimpan asesmen.' });
  }
}

export async function getLatestAssessment(req: AuthenticatedRequest, res: Response) {
  const userId = req.user?.id;
  const { villageId } = req.query;

  if (!userId) {
    return res.status(401).json({ error: 'Sesi kedaluwarsa atau tidak terotorisasi.' });
  }

  if (!villageId || typeof villageId !== 'string') {
    return res.status(400).json({ error: 'villageId diperlukan dalam query.' });
  }

  try {

    const village = await prisma.village.findFirst({
      where: { id: villageId, userId }
    });

    if (!village) {
      return res.status(403).json({ error: 'Akses ditolak. Desa bukan milik Anda.' });
    }

    const assessment = await prisma.environmentalAssessment.findFirst({
      where: { villageId },
      orderBy: { createdAt: 'desc' }
    });

    if (!assessment) {
      return res.status(404).json({ error: 'Belum ada data asesmen untuk desa ini.' });
    }

    const dnaScores = calculateDNA(assessment);
    const dnaDetails = getDNADetails(assessment, dnaScores);
    const dnaInsights = getDNAInsights(dnaScores);

    return res.status(200).json({
      assessment,
      dnaScores,
      dnaDetails,
      dnaInsights
    });
  } catch (err: any) {
    console.error('Error saat memuat asesmen:', err);
    return res.status(500).json({ error: err.message || 'Gagal memuat asesmen.' });
  }
}
