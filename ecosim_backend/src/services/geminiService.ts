  import { DNAScores } from './ruleEngine';

interface VillagePayload {
  name: string;
  population: number;
  agriculturalAreaKm2: number;
}

interface ScenarioPayload {
  name: string;
  programs: string[];
  projected: DNAScores;
  delta?: number;
}

interface GeminiAnalysisPayload {
  mode: 'analysis' | 'blueprint';
  village: VillagePayload;
  baseline: DNAScores;
  scenarios: ScenarioPayload[];
  analysisText?: string;
}

export async function runGeminiAnalysis(payload: GeminiAnalysisPayload): Promise<string> {
  const { mode, village, baseline, scenarios } = payload;
  const apiKey = process.env.GEMINI_API_KEY;

  if (!apiKey) {
    throw new Error("GEMINI_API_KEY tidak ditemukan di environment variables backend.");
  }

  let prompt = "";

  if (mode === "analysis") {
    if (scenarios.length === 0) {
      throw new Error("Tidak ada skenario untuk dianalisis.");
    }

    const scenariosText = scenarios.map((s, idx) => `
Skenario ${idx + 1}: "${s.name}"
Program: ${s.programs.join(", ")}
Proyeksi DNA Desa:
- Waste Management: ${baseline.waste_health} -> ${s.projected.waste_health}
- Water Quality: ${baseline.water_health} -> ${s.projected.water_health}
- Environmental Conservation: ${baseline.green_health} -> ${s.projected.green_health}
- Disaster Resilience: ${baseline.resilience} -> ${s.projected.resilience}
- Peningkatan Rata-rata: ${s.delta ?? 0} level
`).join("\n---\n");

    prompt = `Anda adalah analis keberlanjutan lingkungan (AI Sustainability Analyst) berpengalaman di Indonesia.
Tugas Anda adalah membandingkan beberapa skenario pembangunan desa berikut secara kritis untuk merekomendasikan skenario terbaik bagi kelangsungan lingkungan desa.

Data Desa:
- Nama: ${village.name}
- Jumlah Penduduk: ${village.population} jiwa
- Luas Wilayah Pertanian: ${village.agriculturalAreaKm2} km²

Kondisi Baseline DNA Desa (Saat Ini):
- Waste Management: ${baseline.waste_health}
- Water Quality: ${baseline.water_health}
- Environmental Conservation: ${baseline.green_health}
- Disaster Resilience: ${baseline.resilience}

Daftar Skenario yang Dibandingkan:
${scenariosText}

Berikan analisis komparatif yang objektif, padat, dan mudah dibaca (dalam Bahasa Indonesia) dengan struktur Markdown berikut secara persis:

## Analisis Perbandingan Skenario

### Rekomendasi Terbaik
[Tulis Nama Skenario Terbaik di sini secara persis sesuai nama skenario di atas]

### Alasan Rekomendasi
(Tulis 2-3 kalimat ringkas menjelaskan mengapa skenario tersebut paling optimal untuk desa ini)

### Kelebihan Skenario Terbaik
(Tulis 2-3 poin kelebihan utama dari skenario terbaik yang direkomendasikan, awali setiap poin dengan '✓')

### Risiko & Hambatan Skenario Terbaik
(Tulis 1-2 poin risiko kritis implementasi program pada skenario terbaik, awali setiap poin dengan '✓')

### Ringkasan Perbandingan
(Tulis perbandingan ringkas antar semua skenario yang dinilai dalam 2-3 kalimat)

Jangan gunakan kata pengantar atau penutup. Langsung mulai dengan judul ## Analisis Perbandingan Skenario.`;
  } else if (mode === "blueprint") {
    const scenario = scenarios[0];
    if (!scenario) {
      throw new Error("Skenario tidak ditemukan untuk membuat blueprint.");
    }
    
    prompt = `Anda adalah Perencana Pembangunan Wilayah dan Konsultan Anggaran Desa (APBDes) profesional yang ahli dalam menyusun program kelestarian ekologi di tingkat pedesaan Indonesia.
Tugas Anda adalah merancang dokumen rencana Cetak Biru (Blueprint) teknis implementasi taktis program lingkungan desa berdurasi 12 bulan berdasarkan data empiris berikut:

Data Desa:
- Nama Desa: ${village.name}
- Jumlah Penduduk: ${village.population} jiwa
- Luas Pertanian: ${village.agriculturalAreaKm2} km²

Kondisi Kualitatif DNA Desa Saat Ini:
- Pengelolaan Sampah (Waste Management): ${baseline.waste_health}
- Kualitas Air Bersih (Water Quality): ${baseline.water_health}
- Konservasi Lingkungan (Environmental Conservation): ${baseline.green_health}
- Ketahanan Bencana (Disaster Resilience): ${baseline.resilience}

Program Ekologis Pilihan Skenario: ${scenario.programs.join(", ")}
Analisis Kelayakan & Prioritas Kebijakan:
${payload.analysisText || "Skenario pembangunan layak dijalankan secara bertahap."}

Berdasarkan data di atas, susun rencana kerja taktis 12 bulan yang dibagi ke dalam 4 kuartal (Q1, Q2, Q3, Q4) dengan ketentuan profesional sebagai berikut:
1. ESTIMASI ANGGARAN DINAMIS: Anda wajib memperkirakan secara cerdas kisaran anggaran (Range Min - Max dalam Rupiah) yang dibutuhkan untuk mendanai poin aksi di setiap kuartal. Estimasi ini harus didasarkan secara logis pada:
   - Skala populasi desa (desa berpenduduk besar membutuhkan anggaran fasilitas/sosialisasi yang lebih besar).
   - Kompleksitas program ekologis yang dipilih (program berskala tinggi membutuhkan anggaran infrastruktur fisik yang lebih besar).
   - Tulis estimasi anggaran kuartal tersebut tepat di baris pertama di bawah judul kuartal dengan format persis: "- Anggaran: Rp [Estimasi Min] - Rp [Estimasi Max]". Gunakan angka riil hasil perhitungan Anda (contoh: "- Anggaran: Rp 12.000.000 - Rp 22.000.000"). JANGAN menyalin mentah-mentah angka dari contoh petunjuk ini!
2. RENCANA AKSI OPERASIONAL: Berikan tepat 3 (tiga) poin aksi operasional per kuartal. Setiap poin aksi harus ditulis secara singkat, konkret, padat, dan langsung mengarah ke instruksi kerja lapangan dengan BATAS MAKSIMAL 6 KATA per poin aksi. Jangan menulis penjelasan bertele-tele atau paragraf panjang.

Gunakan format struktur Markdown berikut secara persis untuk mempermudah sistem melakukan ekstraksi data visual:

## Blueprint 12 Bulan

### Q1: [Fokus Kuartal 1, Maksimal 4 kata. Misal: Perencanaan & Regulasi Desa]
- Anggaran: Rp [Estimasi Min Kalkulasi Anda] - Rp [Estimasi Max Kalkulasi Anda]
- Poin aksi 1 (Maksimal 6 kata)
- Poin aksi 2 (Maksimal 6 kata)
- Poin aksi 3 (Maksimal 6 kata)

### Q2: [Fokus Kuartal 2, Maksimal 4 kata]
- Anggaran: Rp [Estimasi Min Kalkulasi Anda] - Rp [Estimasi Max Kalkulasi Anda]
- Poin aksi 1 (Maksimal 6 kata)
- Poin aksi 2 (Maksimal 6 kata)
- Poin aksi 3 (Maksimal 6 kata)

### Q3: [Fokus Kuartal 3, Maksimal 4 kata]
- Anggaran: Rp [Estimasi Min Kalkulasi Anda] - Rp [Estimasi Max Kalkulasi Anda]
- Poin aksi 1 (Maksimal 6 kata)
- Poin aksi 2 (Maksimal 6 kata)
- Poin aksi 3 (Maksimal 6 kata)

### Q4: [Fokus Kuartal 4, Maksimal 4 kata]
- Anggaran: Rp [Estimasi Min Kalkulasi Anda] - Rp [Estimasi Max Kalkulasi Anda]
- Poin aksi 1 (Maksimal 6 kata)
- Poin aksi 2 (Maksimal 6 kata)
- Poin aksi 3 (Maksimal 6 kata)

Jangan gunakan kata pengantar, sapaan pembuka, atau penutup. Langsung mulai dengan judul ## Blueprint 12 Bulan.`;
  }

  const MODELS_TO_TRY = [
    "gemini-2.5-flash",
    "gemini-2.5-flash-lite",
    "gemini-2.0-flash",
    "gemini-2.0-flash-lite",
    "gemini-2.5-pro"
  ];

  let lastError: any = null;

  for (const modelName of MODELS_TO_TRY) {
    try {
      console.log(`Mencoba memanggil Gemini API dengan model: ${modelName}`);
      const response = await fetch(
        `https://generativelanguage.googleapis.com/v1beta/models/${modelName}:generateContent?key=${apiKey}`,
        {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({
            contents: [{ parts: [{ text: prompt }] }],
            generationConfig: { temperature: 0.7, maxOutputTokens: 8192 },
          }),
        }
      );

      if (!response.ok) {
        const errText = await response.text();
        let parsedError;
        try { 
          parsedError = JSON.parse(errText); 
        } catch { 
          parsedError = null; 
        }
        const message = parsedError?.error?.message || response.statusText || errText;
        throw new Error(message);
      }

      const geminiData = (await response.json()) as any;
      const text = geminiData?.candidates?.[0]?.content?.parts?.[0]?.text;
      
      if (text) {
        console.log(`Sukses menggunakan model: ${modelName}`);
        return text;
      } else {
        throw new Error("API merespons dengan data kosong.");
      }
    } catch (err: any) {
      console.warn(`Model ${modelName} gagal:`, err.message);
      lastError = err;
    }
  }

  throw new Error(`Semua model Gemini gagal merespons. Error terakhir: ${lastError?.message || "Unknown error"}`);
}
