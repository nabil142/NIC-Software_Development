import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/knowledge_base.dart';
import '../../../village/presentation/controllers/village_controller.dart';
import '../../../assessment/presentation/controllers/assessment_controller.dart';
import '../controllers/scenario_controller.dart';

class SummaryReportPage extends ConsumerWidget {
  const SummaryReportPage({super.key});

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
        return AppTheme.poorColor;
      case 'fair':
        return AppTheme.fairColor;
      case 'good':
        return AppTheme.goodColor;
      case 'excellent':
        return AppTheme.excellentColor;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final village = ref.watch(villageControllerProvider).activeVillage;
    final assessmentState = ref.watch(assessmentControllerProvider);
    final scenarioState = ref.watch(scenarioControllerProvider);
    final activeScenario = scenarioState.activeScenario;

    if (village == null || assessmentState.latestAssessment == null || activeScenario == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Rangkuman Laporan')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Data tidak lengkap untuk menyusun laporan.'),
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

    final assessment = assessmentState.latestAssessment!.assessment;
    final baseDna = assessmentState.latestAssessment!.dnaScores;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rangkuman Laporan Akhir'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/scenarios'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title Header
            Text(
              'Rangkuman Rencana Aksi Desa',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              'Desa ${village.villageName} | Sistem Informasi EcoSim',
              style: const TextStyle(fontSize: 12, color: AppTheme.textMedium),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Section 1: Village Profile details
            _buildSectionHeader('1. Profil Geografis Desa'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildRowDetail('Nama Desa', 'Desa ${village.villageName}'),
                    const Divider(height: 12),
                    _buildRowDetail('Jumlah Penduduk', '${village.population} Jiwa'),
                    const Divider(height: 12),
                    _buildRowDetail('Luas Wilayah', '${village.areaKm2} Km²'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Section 2: Initial environmental assessment answers
            _buildSectionHeader('2. Hasil Jawaban Asesmen Awal'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildRowDetail('Tingkat Volume Sampah', '${assessment.wasteLevel}/10'),
                    const Divider(height: 12),
                    _buildRowDetail('Fasilitas Sampah Utama', assessment.wasteManagement.toUpperCase()),
                    const Divider(height: 12),
                    _buildRowDetail('Kualitas Air Bersih', '${assessment.waterQuality}/10'),
                    const Divider(height: 12),
                    _buildRowDetail('Kontaminasi Sungai', assessment.riverContaminated ? 'YA (Tercemar)' : 'TIDAK'),
                    const Divider(height: 12),
                    _buildRowDetail('Cakupan Lahan Hijau', '${assessment.greenSpace}/10'),
                    const Divider(height: 12),
                    _buildRowDetail('Kerawanan Banjir', '${assessment.floodRisk}/10'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Section 3: DNA comparison
            _buildSectionHeader('3. Proyeksi Peningkatan DNA Lingkungan'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildDnaComparisonRow(
                      'Sanitasi & Sampah',
                      baseDna.wasteHealth,
                      _valToStatus(activeScenario.projectedWasteHealth),
                    ),
                    const Divider(height: 16),
                    _buildDnaComparisonRow(
                      'Kualitas Air',
                      baseDna.waterHealth,
                      _valToStatus(activeScenario.projectedWaterHealth),
                    ),
                    const Divider(height: 16),
                    _buildDnaComparisonRow(
                      'Kelestarian Hijau',
                      baseDna.greenHealth,
                      _valToStatus(activeScenario.projectedGreenHealth),
                    ),
                    const Divider(height: 16),
                    _buildDnaComparisonRow(
                      'Mitigasi Bencana',
                      baseDna.resilience,
                      _valToStatus(activeScenario.projectedResilience),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Section 4: Selected programs
            _buildSectionHeader('4. Rencana Program Kerja Terpilih'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: activeScenario.selectedPrograms.map((pId) {
                    final prog = getProgramById(pId);
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        children: [
                          Text(prog?.icon ?? '🌱', style: const TextStyle(fontSize: 16)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              prog?.name ?? pId,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ),
                          Text(
                            '${prog?.months ?? 0} Bln',
                            style: const TextStyle(fontSize: 12, color: AppTheme.textLight),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Home dashboard navigation button
            ElevatedButton(
              onPressed: () => context.go('/scenarios'),
              child: const Text('Selesai & Kembali ke Dashboard'),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.primaryColor),
      ),
    );
  }

  Widget _buildRowDetail(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: AppTheme.textMedium)),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
      ],
    );
  }

  Widget _buildDnaComparisonRow(String dimension, String base, String proj) {
    final baseColor = _getStatusColor(base);
    final projColor = _getStatusColor(proj);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(dimension, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        Row(
          children: [
            Text(
              _translateStatus(base),
              style: TextStyle(color: baseColor, fontWeight: FontWeight.bold, fontSize: 12),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward, size: 14, color: Colors.grey),
            const SizedBox(width: 8),
            Text(
              _translateStatus(proj),
              style: TextStyle(color: projColor, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ],
        ),
      ],
    );
  }

  String _valToStatus(int val) {
    if (val <= 1) return 'Poor';
    if (val == 2) return 'Fair';
    if (val == 3) return 'Good';
    return 'Excellent';
  }
}
