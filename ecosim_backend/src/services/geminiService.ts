  import { DNAScores } from './ruleEngine';

interface VillagePayload {
  name: string;
  population: number;
}

interface ScenarioPayload {
  name: string;
  programs: string[];
  projected: DNAScores;
  delta?: number;
}

interface GeminiAnalysisPayload {
  mode: 'analysis' | 'blueprint' | 'potential_solution';
  village: VillagePayload;
  baseline: DNAScores;
  scenarios: ScenarioPayload[];
  analysisText?: string;
  potentialProblem?: string;
}

export async function runGeminiAnalysis(payload: GeminiAnalysisPayload): Promise<string> {
  const { mode, village, baseline, scenarios, potentialProblem } = payload;
  const apiKey = process.env.GEMINI_API_KEY;

  if (!apiKey) {
    throw new Error("GEMINI_API_KEY tidak ditemukan di environment variables backend.");
  }

  let prompt = "";

  if (mode === "potential_solution") {
    if (!potentialProblem) {
      throw new Error("Masalah potensi desa tidak diberikan.");
    }
    
    prompt = `Anda adalah AI Konsultan Pemberdayaan Desa dan Ahli Pembangunan Wilayah.
Tugas Anda adalah memberikan solusi inovatif, langkah penerapan praktis, dan estimasi biaya terkait potensi atau permasalahan desa yang diinputkan pengguna.

Data Desa:
- Nama Desa: ${village.name}
- Jumlah Penduduk: ${village.population} jiwa

Permasalahan / Potensi yang Ingin Dikembangkan:
"${potentialProblem}"

Berikan analisis dan solusi yang objektif, sangat taktis, dan mudah dibaca dengan struktur Markdown berikut secara persis:

## Solusi Pengembangan Potensi Desa

### 💡 Ide Solusi Inovatif
(Tulis 1-2 paragraf singkat tentang gagasan utama atau rekomendasi solusi terbaik untuk menyelesaikan masalah atau memaksimalkan potensi di atas. Berikan pendekatan yang realistis untuk tingkat desa).

### 📝 Langkah-langkah Penerapan (Tahap Awal)
(Berikan 3-4 langkah aksi konkrit dan berurutan yang harus dilakukan oleh pemerintah desa atau masyarakat untuk memulai solusi ini, awali setiap poin dengan checklist '- [ ]')

### 💰 Estimasi Kasar Anggaran
(Berikan perkiraan kasar rentang biaya dalam Rupiah, misal: Rp 10.000.000 - Rp 25.000.000, lalu tambahkan 1 kalimat singkat penjelasan mengapa butuh anggaran tersebut, contoh: "Dana dialokasikan untuk pelatihan warga dan pengadaan bibit/alat awal.")

Jangan gunakan kata pengantar, sapaan pembuka, atau penutup. Langsung mulai dengan judul ## Solusi Pengembangan Potensi Desa.`;
  } else if (mode === "analysis") {
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

Kondisi Kualitatif DNA Desa Saat Ini:
- Pengelolaan Sampah (Waste Management): ${baseline.waste_health}
- Kualitas Air Bersih (Water Quality): ${baseline.water_health}
- Konservasi Lingkungan (Environmental Conservation): ${baseline.green_health}
- Ketahanan Bencana (Disaster Resilience): ${baseline.resilience}

Program Ekologis Pilihan Skenario: ${scenario.programs.join(", ")}
Analisis Kelayakan & Prioritas Kebijakan:
${payload.analysisText || "Skenario pembangunan layak dijalankan secara bertahap."}

Berdasarkan data di atas, susun rencana kerja taktis 12 bulan yang dibagi ke dalam 4 kuartal (Q1, Q2, Q3, Q4) dengan ketentuan profesional sebagai berikut:
1. ESTIMASI ANGGARAN DINAMIS KUSTOM: Anda wajib menghitung perkiraan kisaran anggaran (Range Min - Max dalam Rupiah) secara SPESIFIK dan BERBEDA-BEDA untuk setiap blueprint. Estimasi ini harus didasarkan secara logis pada:
   - Skala populasi desa (${village.population} jiwa).
   - Karakteristik dan harga material nyata dari spesifik program yang dipilih (${scenario.programs.join(", ")}).
   - HARAM HUKUMNYA memberikan angka "template" (misalnya selalu Rp 10jt - Rp 25jt) untuk skenario yang programnya berbeda. Jika programnya pembangunan fisik, harganya harus jauh lebih mahal dari sekadar program sosialisasi.
   - Tulis estimasi anggaran kuartal tersebut tepat di baris pertama di bawah judul kuartal dengan format persis: "- Anggaran: Rp [Estimasi Min] - Rp [Estimasi Max]".
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
