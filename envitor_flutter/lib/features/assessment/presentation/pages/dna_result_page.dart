import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../controllers/assessment_controller.dart';

class DnaResultPage extends ConsumerStatefulWidget {
  const DnaResultPage({super.key});

  @override
  ConsumerState<DnaResultPage> createState() => _DnaResultPageState();
}

class _DnaResultPageState extends ConsumerState<DnaResultPage> {
  Map<String, List<String>> _parseAiOutput(String rawText) {
    final Map<String, List<String>> parsed = {
      'ide': [],
      'langkah': [],
      'anggaran': [],
    };

    final lines = rawText.split('\n');
    String currentSection = '';

    for (var line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;

      final lower = trimmed.toLowerCase();

      if (lower.startsWith('### 💡 ide') || lower.startsWith('### ide')) {
        currentSection = 'ide';
        continue;
      } else if (lower.startsWith('### 📝 langkah') ||
          lower.startsWith('### langkah')) {
        currentSection = 'langkah';
        continue;
      } else if (lower.startsWith('### 💰 estimasi') ||
          lower.startsWith('### estimasi')) {
        currentSection = 'anggaran';
        continue;
      } else if (trimmed.startsWith('## ')) {
        continue;
      }

      if (currentSection == 'ide') {
        final clean = trimmed.replaceAll(RegExp(r'^[\*\-\✓\d\.\s]+'), '');
        if (clean.isNotEmpty) {
          parsed['ide']!.add(clean);
        }
      } else if (currentSection == 'langkah') {
        final clean = trimmed.replaceAll(RegExp(r'^[\*\-\✓\d\.\s]+'), '');
        if (clean.isNotEmpty) {
          parsed['langkah']!.add(clean);
        }
      } else if (currentSection == 'anggaran') {
        final clean = trimmed.replaceAll(RegExp(r'^[\*\-\✓\d\.\s]+'), '');
        if (clean.isNotEmpty) {
          parsed['anggaran']!.add(clean);
        }
      }
    }

    if (parsed['ide']!.isEmpty &&
        parsed['langkah']!.isEmpty &&
        parsed['anggaran']!.isEmpty) {
      parsed['ide'] = [rawText];
    }

    return parsed;
  }

  Widget _buildGagasanUtama(List<String> paragraphs) {
    if (paragraphs.isEmpty) return const SizedBox();
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFCE1B6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFC08A3F), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5B01E),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.emoji_events, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5B01E).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'SOLUSI INOVATIF',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFFB5700A),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Gagasan Utama',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          ...paragraphs.map((p) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  p,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildLangkahPenerapan(List<String> bullets) {
    if (bullets.isEmpty) return const SizedBox();
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFC3D6CB), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF5E8B3D),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.format_list_bulleted, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 12),
              Text(
                'Langkah Penerapan',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...bullets.asMap().entries.map((entry) {
            // Bersihkan teks dari markdown (**, [], -, angka depan)
            String fullText = entry.value;
            fullText = fullText.replaceAll(RegExp(r'\[\s?\]'), ''); // Hapus [ ]
            fullText = fullText.replaceAll('*', ''); // Hapus ** atau *
            fullText = fullText.replaceAll(RegExp(r'^[\d\.\-\s]+'), '').trim(); 
            
            // Ambil judul (sebelum titik dua atau strip jika ada)
            String title = fullText;
            int splitIdx = fullText.indexOf(':');
            if (splitIdx == -1) splitIdx = fullText.indexOf(' - ');
            if (splitIdx != -1 && splitIdx < 60) {
              title = fullText.substring(0, splitIdx).trim();
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey.withOpacity(0.4)),
              ),
              child: Theme(
                data: Theme.of(context).copyWith(
                  dividerColor: Colors.transparent,
                ),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                  childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                  iconColor: Colors.black54,
                  collapsedIconColor: Colors.black54,
                  title: Text(
                    '${entry.key + 1}. $title',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        fullText,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.black87,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildEstimasiAnggaran(List<String> paragraphs) {
    if (paragraphs.isEmpty) return const SizedBox();
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFD6E4FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF90B4F8), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF4285F4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.account_balance_wallet, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF4285F4).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'PROYEKSI BIAYA',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1967D2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Estimasi Anggaran',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          ...paragraphs.map((p) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline, color: Color(0xFF4285F4), size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        p,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: Colors.black87,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final assessmentState = ref.watch(assessmentControllerProvider);
    final response = assessmentState.latestAssessment;

    if (response == null ||
        response.assessment.potentialSolutionAI == null ||
        response.assessment.potentialSolutionAI!.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFFFAF9F6),
        appBar: AppBar(title: const Text('Analisis Potensi Desa')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Data analisis potensi AI tidak ditemukan.'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/assessment'),
                child: const Text('Lakukan Asesmen'),
              ),
            ],
          ),
        ),
      );
    }

    final parsed = _parseAiOutput(response.assessment.potentialSolutionAI!);

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF9F6),
        elevation: 0,
        titleSpacing: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 20.0, top: 8, bottom: 8),
          child: InkWell(
            onTap: () => context.go('/scenarios'),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.arrow_back, color: Colors.black87, size: 20),
            ),
          ),
        ),
        title: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Text(
            'Analisis Potensi Desa',
            style: GoogleFonts.plusJakartaSans(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Icon(Icons.adjust, color: Color(0xFF5E8B3D), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Fokus Permasalahan',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (response.assessment.potentialProblem != null &&
                  response.assessment.potentialProblem!.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.withOpacity(0.3)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '”',
                        style: TextStyle(
                          fontSize: 48,
                          height: 0.8,
                          fontWeight: FontWeight.w900,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            '"${response.assessment.potentialProblem!}"',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: Colors.black54,
                              fontStyle: FontStyle.italic,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              _buildGagasanUtama(parsed['ide']!),
              _buildLangkahPenerapan(parsed['langkah']!),
              _buildEstimasiAnggaran(parsed['anggaran']!),

              ElevatedButton(
                onPressed: () => context.go('/future-builder'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5E8B3D),
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: Text(
                  'Lanjutkan Simulasi Program (Future Builder)',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
