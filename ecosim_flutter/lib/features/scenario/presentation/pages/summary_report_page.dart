import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../village/presentation/controllers/village_controller.dart';
import '../../../assessment/presentation/controllers/assessment_controller.dart';
import '../controllers/scenario_controller.dart';

class SummaryReportPage extends ConsumerStatefulWidget {
  const SummaryReportPage({super.key});

  @override
  ConsumerState<SummaryReportPage> createState() => _SummaryReportPageState();
}

class _SummaryReportPageState extends ConsumerState<SummaryReportPage> {
  int? _expandedPillarIndex;

  String _translateStatus(String status) {
    switch (status.toLowerCase()) {
      case 'poor':
        return 'Kurang';
      case 'fair':
        return 'Cukup';
      case 'good':
        return 'Baik';
      case 'excellent':
        return 'Sangat Baik';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'poor':
      case 'kurang':
        return const Color(0xFFEE5D5D);
      case 'fair':
      case 'cukup':
        return const Color(0xFFEBB629);
      case 'good':
      case 'baik':
        return const Color(0xFF6FAF4F);
      case 'excellent':
      case 'sangat baik':
        return const Color(0xFF3E6D4E);
      default:
        return Colors.grey;
    }
  }

  Widget _buildCardTitle(IconData icon, String title) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFE3EED0),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF3E6D4E)),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final villageState = ref.watch(villageControllerProvider);
    final assessmentState = ref.watch(assessmentControllerProvider);
    final scenarioState = ref.watch(scenarioControllerProvider);

    final village = villageState.activeVillage;
    final assessment = assessmentState.latestAssessment;
    final activeScenario = scenarioState.activeScenario;

    if (village == null || assessment == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF7F8F4),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Data tidak ditemukan.'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/scenarios'),
                child: const Text('Kembali ke Dashboard'),
              ),
            ],
          ),
        ),
      );
    }

    final baseDna = assessment.dnaScores;
    final displayDna = activeScenario?.projectedDna ?? baseDna;
    final dnaDetails = assessment.dnaDetails;
    final insights = assessment.dnaInsights;

    String introText =
        'Berikut adalah rangkuman hasil analisis menyeluruh untuk Desa ${village.villageName}.\nGunakan insight ini sebagai dasar perencanaan dan pengambilan keputusan';
    if (activeScenario != null) {
      introText =
          'Berikut adalah rangkuman hasil analisis menyeluruh untuk Desa ${village.villageName} berdasarkan skenario "${activeScenario.scenarioName}" yang dipilih.\nGunakan insight ini sebagai dasar perencanaan dan pengambilan keputusan.';
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F4),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => context.go('/scenarios'),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey.withOpacity(0.2)),
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hasil Analisis',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFF6FAF4F),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Rangkuman Laporan',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                introText,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppTheme.textMedium,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),

              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey.withOpacity(0.15)),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildCardTitle(Icons.person_outline, 'Profil Desa'),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildProfilePill('Nama Desa', village.villageName),
                        const SizedBox(width: 8),
                        _buildProfilePill(
                          'Luas Wilayah',
                          '${village.areaKm2} Km²',
                        ),
                        const SizedBox(width: 8),
                        _buildProfilePill(
                          'Jumlah Penduduk',
                          '${village.population} Jiwa',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey.withOpacity(0.15)),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildCardTitle(Icons.show_chart, 'Skor Kinerja Desa'),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildScoreTile(
                          Icons.recycling,
                          'Pengelolaan Sampah',
                          displayDna.wasteHealth,
                        ),
                        _buildScoreTile(
                          Icons.water_drop_outlined,
                          'Sumber Daya Air',
                          displayDna.waterHealth,
                        ),
                        _buildScoreTile(
                          Icons.park_outlined,
                          'Pengelolaan Lingkungan',
                          displayDna.greenHealth,
                        ),
                        _buildScoreTile(
                          Icons.shield_outlined,
                          'Ketahanan Bencana',
                          displayDna.resilience,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey.withOpacity(0.15)),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildCardTitle(
                      Icons.format_list_bulleted,
                      'Ringkasan Per Pilar',
                    ),
                    const SizedBox(height: 16),
                    _buildPillarExpansion(
                      index: 0,
                      number: 1,
                      title: 'Manajemen Lingkungan',
                      status: displayDna.wasteHealth,
                      explanation: dnaDetails.wasteHealth.explanation,
                    ),
                    _buildPillarExpansion(
                      index: 1,
                      number: 2,
                      title: 'Kualitas Air & Sanitasi',
                      status: displayDna.waterHealth,
                      explanation: dnaDetails.waterHealth.explanation,
                    ),
                    _buildPillarExpansion(
                      index: 2,
                      number: 3,
                      title: 'Konservasi & Penghijauan',
                      status: displayDna.greenHealth,
                      explanation: dnaDetails.greenHealth.explanation,
                    ),
                    _buildPillarExpansion(
                      index: 3,
                      number: 4,
                      title: 'Ketahanan Risiko Bencana',
                      status: displayDna.resilience,
                      explanation: dnaDetails.resilience.explanation,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey.withOpacity(0.15)),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildCardTitle(
                      Icons.track_changes,
                      'Rekomendasi Prioritas AI',
                    ),
                    const SizedBox(height: 16),
                    ...insights.asMap().entries.map((entry) {
                      int idx = entry.key;
                      var insight = entry.value;
                      return _buildInsightItem(
                        number: idx + 1,
                        title: insight.dimension,
                        description: insight.insight,
                        priority: insight.priority,
                      );
                    }).toList(),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePill(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F7EB),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF6FAF4F).withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 8,
                color: const Color(0xFF6FAF4F),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF3E6D4E),
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreTile(IconData icon, String label, String status) {
    Color color = _getStatusColor(status);
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.black87, size: 20),
            const SizedBox(height: 12),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 7.5,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              status,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPillarExpansion({
    required int index,
    required int number,
    required String title,
    required String status,
    required String explanation,
  }) {
    bool isExpanded = _expandedPillarIndex == index;
    String displayStatus = _translateStatus(status);
    Color statusColor = _getStatusColor(status);

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isExpanded) {
            _expandedPillarIndex = null;
          } else {
            _expandedPillarIndex = index;
          }
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.change_history,
                    size: 14,
                    color: Color(0xFF6FAF4F),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '$number. $title',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.black87,
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      displayStatus,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (isExpanded) ...[
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  explanation,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppTheme.textMedium,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInsightItem({
    required int number,
    required String title,
    required String description,
    required String priority,
  }) {
    bool isHigh =
        priority.toLowerCase().contains('high') ||
        priority.toLowerCase().contains('tinggi');
    Color badgeColor =
        isHigh ? const Color(0xFF6FAF4F) : const Color(0xFFEBB629);
    String badgeText = isHigh ? 'Dampak Tinggi' : 'Dampak Sedang';

    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: Color(0xFF3E6D4E),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$number',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: badgeColor),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        badgeText,
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: badgeColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppTheme.textMedium,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
