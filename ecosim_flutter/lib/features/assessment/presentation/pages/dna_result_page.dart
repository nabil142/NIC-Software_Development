import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../controllers/assessment_controller.dart';

class DnaResultPage extends ConsumerWidget {
  const DnaResultPage({super.key});

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'poor':
      case 'kurang':
        return AppTheme.poorColor;
      case 'fair':
      case 'cukup':
        return AppTheme.fairColor;
      case 'good':
      case 'baik':
        return AppTheme.goodColor;
      case 'excellent':
      case 'sangat baik':
        return AppTheme.excellentColor;
      default:
        return Colors.grey;
    }
  }

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

  Widget _buildDnaCard(
    BuildContext context, {
    required String title,
    required String status,
    required int score,
    required String explanation,
    required IconData icon,
  }) {
    final statusColor = _getStatusColor(status);
    final displayStatus = _translateStatus(status);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: statusColor.withOpacity(0.1),
                  child: Icon(icon, color: statusColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor, width: 1),
                  ),
                  child: Text(
                    displayStatus,
                    style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              explanation,
              style: const TextStyle(fontSize: 13, color: AppTheme.textMedium, height: 1.4),
            ),
            const SizedBox(height: 12),
            // Linear Progress Indicator representing 1 to 4 score
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: score / 4.0,
                      backgroundColor: Colors.grey.withOpacity(0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                      minHeight: 8,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '$score/4',
                  style: TextStyle(fontWeight: FontWeight.bold, color: statusColor),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assessmentState = ref.watch(assessmentControllerProvider);
    final response = assessmentState.latestAssessment;

    if (response == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('DNA Lingkungan Desa')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Data DNA tidak ditemukan.'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/assessment'),
                child: const Text('Mulai Asesmen Baru'),
              ),
            ],
          ),
        ),
      );
    }

    final dnaDetails = response.dnaDetails;
    final insights = response.dnaInsights;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hasil DNA Lingkungan Desa'),
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
            // Header card
            Card(
              color: AppTheme.primaryColor,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const Text(
                      '🧬',
                      style: TextStyle(fontSize: 48),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Profil DNA Lingkungan Terbentuk!',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Sistem telah memetakan 4 parameter fundamental keberlanjutan desa Anda.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            Text(
              'Detail 4 Dimensi Keberlanjutan',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Dimension Cards
            _buildDnaCard(
              context,
              title: 'Sanitasi & Pengelolaan Sampah',
              status: dnaDetails.wasteHealth.status,
              score: dnaDetails.wasteHealth.score,
              explanation: dnaDetails.wasteHealth.explanation,
              icon: Icons.delete_outline,
            ),
            const SizedBox(height: 12),
            _buildDnaCard(
              context,
              title: 'Kualitas Air Konsumsi',
              status: dnaDetails.waterHealth.status,
              score: dnaDetails.waterHealth.score,
              explanation: dnaDetails.waterHealth.explanation,
              icon: Icons.water_drop_outlined,
            ),
            const SizedBox(height: 12),
            _buildDnaCard(
              context,
              title: 'Kelestarian Hijau & Keanekaragaman',
              status: dnaDetails.greenHealth.status,
              score: dnaDetails.greenHealth.score,
              explanation: dnaDetails.greenHealth.explanation,
              icon: Icons.park_outlined,
            ),
            const SizedBox(height: 12),
            _buildDnaCard(
              context,
              title: 'Mitigasi Bencana & Resiliensi',
              status: dnaDetails.resilience.status,
              score: dnaDetails.resilience.score,
              explanation: dnaDetails.resilience.explanation,
              icon: Icons.shield_outlined,
            ),
            const SizedBox(height: 24),

            // Insights section
            Text(
              'Rekomendasi Prioritas AI',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Insight cards
            ...insights.map((insight) {
              final priorityColor = insight.priority.toLowerCase() == 'high' 
                  ? AppTheme.poorColor 
                  : (insight.priority.toLowerCase() == 'medium' ? AppTheme.fairColor : AppTheme.goodColor);

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            insight.dimension,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: priorityColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Prioritas: ${insight.priority}',
                              style: TextStyle(color: priorityColor, fontWeight: FontWeight.bold, fontSize: 10),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        insight.insight,
                        style: const TextStyle(fontSize: 12.5, color: AppTheme.textMedium, height: 1.4),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 30),

            ElevatedButton.icon(
              icon: const Icon(Icons.rocket_launch),
              label: const Text('Lanjut Simulasikan Program (Future Builder)'),
              onPressed: () => context.go('/future-builder'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => context.go('/scenarios'),
              child: const Text('Kembali ke Dashboard'),
            ),
          ],
        ),
      ),
    );
  }
}
