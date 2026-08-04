import bcrypt from 'bcryptjs';
import { PrismaClient } from '@prisma/client';
import * as dotenv from 'dotenv';
import * as path from 'path';
import * as fs from 'fs';

// Load environment
const nodeEnv = process.env.NODE_ENV || 'production';
const envPath = path.resolve(process.cwd(), `.env.${nodeEnv}`);
if (fs.existsSync(envPath)) {
  dotenv.config({ path: envPath });
} else {
  dotenv.config();
}

const prisma = new PrismaClient();

async function seedDemoAccount() {
  console.log('🌱 Membuat akun demo untuk Apple Review...\n');

  const DEMO_EMAIL = 'demo@envitor.com';
  const DEMO_PASSWORD = 'Demo1234!';

  try {
    // 1. Hapus akun demo lama jika ada (agar script bisa dijalankan ulang)
    const existing = await prisma.user.findUnique({ where: { email: DEMO_EMAIL } });
    if (existing) {
      await prisma.user.delete({ where: { email: DEMO_EMAIL } });
      console.log('♻️  Akun demo lama dihapus, membuat yang baru...');
    }

    // 2. Buat user demo
    const salt = await bcrypt.genSalt(10);
    const passwordHash = await bcrypt.hash(DEMO_PASSWORD, salt);

    const user = await prisma.user.create({
      data: {
        email: DEMO_EMAIL,
        passwordHash,
      },
    });
    console.log(`✅ User demo dibuat: ${user.email}`);

    // 3. Buat profil desa demo
    const village = await prisma.village.create({
      data: {
        userId: user.id,
        villageName: 'Desa Sukamaju',
        population: 4250,
        areaKm2: 12.5,
        districtName: 'Kecamatan Ciawi',
        cityName: 'Kabupaten Bogor',
        potential: 'Pertanian padi, perkebunan sayuran, dan ekowisata alam berbasis sungai',
      },
    });
    console.log(`✅ Profil desa demo dibuat: ${village.villageName}`);

    // 4. Buat asesmen lingkungan demo
    const assessment = await prisma.environmentalAssessment.create({
      data: {
        villageId: village.id,
        wasteLevel: 3,
        wasteManagement: 'tps',
        waterQuality: 2,
        riverContaminated: true,
        greenSpace: 2,
        floodRisk: 3,
        existingPrograms: ['kerja_bakti', 'bank_sampah'],
        potentialProblem:
          'Desa Sukamaju menghadapi permasalahan lingkungan yang kompleks. Tingkat timbunan sampah cukup tinggi dengan sistem pengelolaan yang masih bergantung pada TPS konvensional. Kualitas air sungai mengalami penurunan akibat pembuangan limbah rumah tangga langsung ke badan air. Ruang hijau yang terbatas memperparah kemampuan desa dalam menyerap air hujan, sehingga risiko banjir di musim penghujan cukup signifikan.',
        potentialSolutionAI:
          'Rekomendasi program prioritas: (1) Implementasi program Bank Sampah berbasis RT/RW untuk meningkatkan nilai ekonomi sampah rumah tangga; (2) Pembangunan instalasi pengolahan air limbah (IPAL) komunal di titik-titik strategis dekat sungai; (3) Program penanaman pohon di bantaran sungai dan lahan kosong untuk meningkatkan serapan air; (4) Pembangunan biopori dan sumur resapan untuk mitigasi banjir jangka pendek.',
      },
    });
    console.log(`✅ Asesmen lingkungan demo dibuat`);

    // 5. Buat skenario demo
    const scenario = await prisma.scenario.create({
      data: {
        villageId: village.id,
        scenarioName: 'Program Desa Hijau Terintegrasi 2025',
        selectedPrograms: ['bank_sampah', 'ipal_komunal', 'penghijauan', 'biopori'],
        baselineWasteHealth: 40,
        baselineWaterHealth: 30,
        baselineGreenHealth: 35,
        baselineResilience: 25,
        projectedWasteHealth: 75,
        projectedWaterHealth: 68,
        projectedGreenHealth: 72,
        projectedResilience: 65,
        aiAnalysis:
          'Berdasarkan analisis data asesmen Desa Sukamaju, kombinasi program yang dipilih memiliki potensi dampak yang signifikan. Program Bank Sampah akan meningkatkan indeks kesehatan pengelolaan sampah sebesar 35 poin dengan estimasi reduksi volume sampah ke TPS sebesar 40%. Implementasi IPAL Komunal diproyeksikan meningkatkan kualitas air sungai secara bertahap dalam 6-12 bulan. Program penghijauan bantaran sungai dan pemasangan biopori akan meningkatkan kapasitas infiltrasi tanah sehingga risiko banjir dapat dikurangi secara signifikan.',
        narrativeText:
          '# Blueprint Program Desa Hijau Terintegrasi 2025\n\n## Latar Belakang\nDesa Sukamaju, Kecamatan Ciawi, Kabupaten Bogor, dengan jumlah penduduk 4.250 jiwa dan luas wilayah 12,5 km² berkomitmen untuk mewujudkan lingkungan desa yang sehat dan berkelanjutan melalui Program Desa Hijau Terintegrasi 2025.\n\n## Tujuan Program\nProgram ini bertujuan untuk meningkatkan seluruh indikator kesehatan lingkungan desa secara terukur dalam rentang waktu 12 bulan.\n\n## Program yang Dipilih\n1. **Bank Sampah RT/RW** — Pendirian unit bank sampah di setiap RT\n2. **IPAL Komunal** — Pembangunan instalasi pengolahan limbah komunal\n3. **Penghijauan Bantaran Sungai** — Penanaman 500 pohon di sepanjang DAS\n4. **Biopori & Sumur Resapan** — Pemasangan 200 titik biopori\n\n## Target Capaian\n- Indeks Kesehatan Sampah: 40 → 75 poin\n- Indeks Kualitas Air: 30 → 68 poin\n- Indeks Ruang Hijau: 35 → 72 poin\n- Indeks Ketahanan Banjir: 25 → 65 poin',
      },
    });
    console.log(`✅ Skenario demo dibuat: ${scenario.scenarioName}`);

    console.log('\n🎉 SELESAI! Akun demo berhasil dibuat.\n');
    console.log('═══════════════════════════════════════');
    console.log('  📧 Email    : demo@envitor.com');
    console.log('  🔑 Password : Demo1234!');
    console.log('═══════════════════════════════════════');
    console.log('\nGunakan kredensial di atas untuk diisi di form TestFlight External Testing.\n');

  } catch (error) {
    console.error('❌ Gagal membuat akun demo:', error);
    throw error;
  } finally {
    await prisma.$disconnect();
  }
}

seedDemoAccount();
