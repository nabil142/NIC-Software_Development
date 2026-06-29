import { Response } from 'express';
import { AuthenticatedRequest } from '../middlewares/authMiddleware';
import { prisma } from '../lib/prisma';

export async function createOrUpdateVillage(req: AuthenticatedRequest, res: Response) {
  const userId = req.user?.id;
  const { villageName, population, areaKm2, districtName, cityName, potential } = req.body;

  if (!userId) {
    return res.status(401).json({ error: 'Sesi kedaluwarsa atau tidak terotorisasi.' });
  }

  if (!villageName || population === undefined || areaKm2 === undefined) {
    return res.status(400).json({ error: 'Field villageName, population, dan areaKm2 wajib diisi.' });
  }

  try {

    const existing = await prisma.village.findFirst({
      where: { userId },
      orderBy: { createdAt: 'desc' }
    });

    let village;

    if (existing) {

      village = await prisma.village.update({
        where: { id: existing.id },
        data: {
          villageName,
          population: parseInt(population),
          areaKm2: parseFloat(areaKm2),
          districtName,
          cityName,
          potential
        }
      });
    } else {

      village = await prisma.village.create({
        data: {
          userId,
          villageName,
          population: parseInt(population),
          areaKm2: parseFloat(areaKm2),
          districtName,
          cityName,
          potential
        }
      });
    }

    return res.status(200).json({
      message: 'Profil desa berhasil disimpan.',
      village
    });
  } catch (err: any) {
    console.error('Error saat menyimpan profil desa:', err);
    return res.status(500).json({ error: err.message || 'Gagal menyimpan profil desa.' });
  }
}

export async function getActiveVillage(req: AuthenticatedRequest, res: Response) {
  const userId = req.user?.id;

  if (!userId) {
    return res.status(401).json({ error: 'Sesi kedaluwarsa atau tidak terotorisasi.' });
  }

  try {
    const village = await prisma.village.findFirst({
      where: { userId },
      orderBy: { createdAt: 'desc' }
    });

    if (!village) {
      return res.status(404).json({ error: 'Profil desa belum dikonfigurasi.' });
    }

    return res.status(200).json({ village });
  } catch (err: any) {
    console.error('Error saat memuat profil desa:', err);
    return res.status(500).json({ error: err.message || 'Gagal memuat profil desa.' });
  }
}
