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

  Widget _buildHorizontalStructuredCard({
    required Color cardBg,
    required Color iconBg,
    required IconData iconData,
    required String tagText,
    required Color tagBg,
    required Color tagTextColor,
    required String title,
    required Widget content,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(28),
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(iconData, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: tagBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    tagText,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: tagTextColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                content,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStructuredCards(String rawText) {
    final parsed = _parseAiOutput(rawText);

    final ideParagraphs = parsed['ide']!;
    final langkahBullets = parsed['langkah']!;
    final anggaranParagraphs = parsed['anggaran']!;

    return Column(
      children: [
        if (ideParagraphs.isNotEmpty)
          _buildHorizontalStructuredCard(
            cardBg: const Color(0xFFFFF4D4),
            iconBg: const Color(0xFFFBBF24),
            iconData: Icons.emoji_events,
            tagText: 'SOLUSI INOVATIF',
            tagBg: const Color(0xFFFFF0C2),
            tagTextColor: const Color(0xFFD97706),
            title: 'Gagasan Utama',
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:
                  ideParagraphs
                      .map(
                        (p) => Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            p,
                            style: GoogleFonts.inter(
                              fontSize: 11.5,
                              color: AppTheme.textMedium,
                              height: 1.4,
                            ),
                          ),
                        ),
                      )
                      .toList(),
            ),
          ),

        if (langkahBullets.isNotEmpty)
          _buildHorizontalStructuredCard(
            cardBg: const Color(0xFFE9F5E6),
            iconBg: const Color(0xFF4C8C5A),
            iconData: Icons.format_list_numbered,
            tagText: 'TAHAP AWAL',
            tagBg: const Color(0xFFD1FAE5),
            tagTextColor: const Color(0xFF065F46),
            title: 'Langkah Penerapan',
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:
                  langkahBullets.asMap().entries.map((entry) {
                    int idx = entry.key;
                    String bullet = entry.value;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 18,
                            height: 18,
                            margin: const EdgeInsets.only(top: 2, right: 8),
                            decoration: const BoxDecoration(
                              color: Color(0xFF4C8C5A),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${idx + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              bullet,
                              style: GoogleFonts.inter(
                                fontSize: 11.5,
                                color: AppTheme.textMedium,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
            ),
          ),

        if (anggaranParagraphs.isNotEmpty)
          _buildHorizontalStructuredCard(
            cardBg: const Color(0xFFE5F0FF),
            iconBg: const Color(0xFF3B82F6),
            iconData: Icons.account_balance_wallet,
            tagText: 'PROYEKSI BIAYA',
            tagBg: const Color(0xFFDBEAFE),
            tagTextColor: const Color(0xFF1D4ED8),
            title: 'Estimasi Anggaran',
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:
                  anggaranParagraphs
                      .map(
                        (p) => Padding(
                          padding: const EdgeInsets.only(bottom: 6.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.info_outline,
                                color: Color(0xFF3B82F6),
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  p,
                                  style: GoogleFonts.inter(
                                    fontSize: 11.5,
                                    color: AppTheme.textMedium,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
            ),
          ),
      ],
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
        backgroundColor: const Color(0xFFF6F5EF),
        appBar: AppBar(title: const Text('Analisis Potensi Desa AI')),
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

    return Scaffold(
      backgroundColor: const Color(0xFFF6F5EF),
      appBar: AppBar(
        title: Text(
          'Analisis Potensi Desa AI',
          style: GoogleFonts.plusJakartaSans(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/scenarios'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                color: AppTheme.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      const Text('✨', style: TextStyle(fontSize: 48)),
                      const SizedBox(height: 10),
                      Text(
                        'Analisis Potensi Selesai!',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'AI telah merancang strategi inovatif, langkah penerapan, dan estimasi anggaran khusus untuk permasalahan desa Anda.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              if (response.assessment.potentialProblem != null &&
                  response.assessment.potentialProblem!.isNotEmpty) ...[
                Text(
                  'Fokus Permasalahan:',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textMedium,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.withOpacity(0.2)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.format_quote,
                        color: AppTheme.primaryColor,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '"${response.assessment.potentialProblem!}"',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            color: Colors.black87,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              _buildStructuredCards(response.assessment.potentialSolutionAI!),

              const SizedBox(height: 12),
              ElevatedButton.icon(
                icon: const Icon(
                  Icons.rocket_launch,
                  color: Colors.white,
                  size: 20,
                ),
                label: Text(
                  'Lanjut Simulasikan Program (Future Builder)',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () => context.go('/future-builder'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  side: BorderSide(color: Colors.grey.withOpacity(0.3)),
                ),
                onPressed: () => context.go('/scenarios'),
                child: Text(
                  'Kembali ke Dashboard',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
