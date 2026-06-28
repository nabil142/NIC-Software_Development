import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/knowledge_base.dart';
import '../controllers/scenario_controller.dart';

class BlueprintPage extends ConsumerStatefulWidget {
  const BlueprintPage({super.key});

  @override
  ConsumerState<BlueprintPage> createState() => _BlueprintPageState();
}

class _BlueprintPageState extends ConsumerState<BlueprintPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final active = ref.read(scenarioControllerProvider).activeScenario;
      if (active == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pilih skenario aktif terlebih dahulu.')),
        );
        context.go('/scenarios');
        return;
      }
      
      if (active.narrativeText == null) {
        ref.read(scenarioControllerProvider.notifier).runAIBlueprint();
      }
    });
  }

  // Calculate budgets dynamically based on program cost categories
  Map<String, String> _calculateDynamicBudgets(List<String> selectedProgramIds) {
    int minCost = 0;
    int maxCost = 0;

    for (final pId in selectedProgramIds) {
      final prog = getProgramById(pId);
      if (prog == null) continue;

      if (prog.cost == 'rendah') {
        minCost += 10000000;
        maxCost += 25000000;
      } else if (prog.cost == 'sedang') {
        minCost += 30000000;
        maxCost += 75000000;
      } else if (prog.cost == 'tinggi') {
        minCost += 100000000;
        maxCost += 200000000;
      }
    }

    // Default fallback if no programs selected
    if (minCost == 0) {
      minCost = 110000000;
      maxCost = 170000000;
    }

    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);
    return {
      'minCostText': formatter.format(minCost),
      'maxCostText': formatter.format(maxCost),
      'range': '${formatter.format(minCost)} - ${formatter.format(maxCost)}',
      'duration': '12 Bulan',
      'q1': '${formatter.format((minCost * 0.25).round())} - ${formatter.format((maxCost * 0.25).round())}',
      'q2': '${formatter.format((minCost * 0.45).round())} - ${formatter.format((maxCost * 0.45).round())}',
      'q3': '${formatter.format((minCost * 0.15).round())} - ${formatter.format((maxCost * 0.15).round())}',
      'q4': '${formatter.format((minCost * 0.15).round())} - ${formatter.format((maxCost * 0.15).round())}',
    };
  }

  Widget _buildQuarterBar({
    required IconData icon,
    required String quarter,
    required String label,
    required String subtitle,
    required String value,
    required double percentage,
    required String percentageText,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon on left
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: Color(0xFFE9F0E6),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF4C8C5A), size: 16),
          ),
          const SizedBox(width: 10),
          // Middle content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$quarter-$label',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 8,
                    color: AppTheme.textLight,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  height: 6,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: percentage,
                    child: Container(
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textMedium,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Percentage pill on right
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFE9F0E6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              percentageText,
              style: GoogleFonts.inter(
                fontSize: 8.5,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF4C8C5A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineStepper() {
    final steps = ['Q1', 'Q2', 'Q3', 'Q4'];
    final labels = ['Persiapan', 'Implementasi', 'Monitoring', 'Optimalisasi'];
    final months = ['Bulan 1-3', 'Bulan 4-6', 'Bulan 7-9', 'Bulan 10-12'];
    final icons = [
      Icons.eco_outlined,
      Icons.spa_outlined,
      Icons.search_rounded,
      Icons.emoji_events_outlined,
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(4, (index) {
        return Expanded(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: index == 0
                        ? const SizedBox()
                        : Container(
                            height: 2,
                            color: const Color(0xFF4C8C5A),
                          ),
                  ),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: Color(0xFF4C8C5A),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        icons[index],
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                  Expanded(
                    child: index == 3
                        ? const SizedBox()
                        : Container(
                            height: 2,
                            color: const Color(0xFF4C8C5A),
                          ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                steps[index],
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                labels[index],
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                months[index],
                style: GoogleFonts.inter(
                  fontSize: 7.5,
                  color: AppTheme.textLight,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildAktivitasCard({
    required String quarterTitle,
    required String durationText,
    required List<String> tasks,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE9F0E6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Color(0xFF4C8C5A),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 16),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      quarterTitle,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    Text(
                      durationText,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: AppTheme.textLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...tasks.map((task) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check_circle, color: Color(0xFF4C8C5A), size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        task,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppTheme.textMedium,
                          fontWeight: FontWeight.w500,
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
    final scenarioState = ref.watch(scenarioControllerProvider);
    final active = scenarioState.activeScenario;
    final calculations = _calculateDynamicBudgets(active?.selectedPrograms ?? []);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F5EF),
      body: Stack(
        children: [
          // 1. Fading background image at top
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 280,
            child: ShaderMask(
              shaderCallback: (rect) {
                return const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black, Colors.transparent],
                ).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
              },
              blendMode: BlendMode.dstIn,
              child: Image.asset(
                'assets/images/blueprint_background.png',
                fit: BoxFit.cover,
                alignment: const Alignment(0, -0.5),
              ),
            ),
          ),

          // 2. Scrollable Content
          SafeArea(
            child: Column(
              children: [
                // Custom back button
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0, top: 4.0),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: AppTheme.textDark),
                      onPressed: () => context.go('/policy-analyst'),
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Title Info Header
                        Text(
                          'Blueprint AI',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                            color: AppTheme.textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Roadmap implementasi selama 12 bulan berdasarkan skenario ${active?.scenarioName ?? "A"}',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppTheme.textMedium,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 20),

                        if (scenarioState.isLoading) ...[
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 60.0),
                              child: Column(
                                children: [
                                  CircularProgressIndicator(),
                                  SizedBox(height: 16),
                                  Text(
                                    'Gemini AI sedang memformulasikan Rencana Kerja APBDes...',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.textMedium,
                                      fontStyle: FontStyle.italic,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ] else if (active?.narrativeText == null) ...[
                          const Card(
                            child: Padding(
                              padding: EdgeInsets.all(24.0),
                              child: Text(
                                'Gagal memuat blueprint AI. Silakan coba kembali.',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ] else ...[
                          // Total Investment & Duration Card
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                              border: Border.all(color: Colors.grey.withOpacity(0.12)),
                            ),
                            child: Row(
                              children: [
                                // Total Investasi Program Column
                                Expanded(
                                  flex: 7,
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 44,
                                        height: 44,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFE9F0E6),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Center(
                                          child: Icon(
                                            Icons.account_balance_wallet,
                                            color: Color(0xFF568A50),
                                            size: 22,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              'Total Investasi',
                                              style: GoogleFonts.plusJakartaSans(
                                                color: AppTheme.textDark,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              '${calculations['minCostText']!} -\n${calculations['maxCostText']!}',
                                              style: GoogleFonts.plusJakartaSans(
                                                color: AppTheme.textDark,
                                                fontSize: 13.5,
                                                fontWeight: FontWeight.bold,
                                                height: 1.2,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              'Estimasi anggaran 12 bln',
                                              style: GoogleFonts.inter(
                                                color: AppTheme.textLight,
                                                fontSize: 7,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Divider
                                Container(
                                  height: 60,
                                  width: 1,
                                  color: Colors.grey.withOpacity(0.15),
                                  margin: const EdgeInsets.symmetric(horizontal: 8),
                                ),
                                // Durasi Program Column
                                Expanded(
                                  flex: 5,
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 44,
                                        height: 44,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFE9F0E6),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Center(
                                          child: Icon(
                                            Icons.calendar_today_rounded,
                                            color: Color(0xFF568A50),
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              'Durasi Program',
                                              style: GoogleFonts.plusJakartaSans(
                                                color: AppTheme.textDark,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              '12 Bulan',
                                              style: GoogleFonts.plusJakartaSans(
                                                color: AppTheme.textDark,
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              '4 kuartal implementasi',
                                              style: GoogleFonts.inter(
                                                color: AppTheme.textLight,
                                                fontSize: 7,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Section: Estimasi Anggaran per Kuartal
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                              border: Border.all(color: Colors.grey.withOpacity(0.1)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Estimasi Anggaran per Kuartal (APBDes)',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: AppTheme.textDark,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _buildQuarterBar(
                                  icon: Icons.eco_outlined,
                                  quarter: 'Q1',
                                  label: 'Persiapan',
                                  subtitle: '1-3 Bulan',
                                  value: calculations['q1']!,
                                  percentage: 0.25,
                                  percentageText: '25%',
                                  color: const Color(0xFF4C8C5A),
                                ),
                                const Divider(height: 24),
                                _buildQuarterBar(
                                  icon: Icons.spa_outlined,
                                  quarter: 'Q2',
                                  label: 'Implementasi',
                                  subtitle: '4-6 Bulan',
                                  value: calculations['q2']!,
                                  percentage: 0.45,
                                  percentageText: '45%',
                                  color: const Color(0xFF4C8C5A),
                                ),
                                const Divider(height: 24),
                                _buildQuarterBar(
                                  icon: Icons.search_rounded,
                                  quarter: 'Q3',
                                  label: 'Monitoring',
                                  subtitle: '7-9 Bulan',
                                  value: calculations['q3']!,
                                  percentage: 0.15,
                                  percentageText: '15%',
                                  color: const Color(0xFF4C8C5A),
                                ),
                                const Divider(height: 24),
                                _buildQuarterBar(
                                  icon: Icons.emoji_events_outlined,
                                  quarter: 'Q4',
                                  label: 'Optimalisasi',
                                  subtitle: '10-12 Bulan',
                                  value: calculations['q4']!,
                                  percentage: 0.15,
                                  percentageText: '15%',
                                  color: const Color(0xFF4C8C5A),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Section: Roadmap Implementasi 12 Bulan (Horizontal Stepper)
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                              border: Border.all(color: Colors.grey.withOpacity(0.1)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Roadmap Implementasi 12 Bulan',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: AppTheme.textDark,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                _buildTimelineStepper(),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Section: Timeline Aktivitas Utama
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                              border: Border.all(color: Colors.grey.withOpacity(0.1)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  'Timeline Aktivitas Utama',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: AppTheme.textDark,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _buildAktivitasCard(
                                  quarterTitle: 'Q1-Persiapan',
                                  durationText: '1-3 Bulan',
                                  icon: Icons.eco_outlined,
                                  color: const Color(0xFF4C8C5A),
                                  tasks: [
                                    'Sosialisasi program kepada warga',
                                    'Pembentukan tim pelaksana',
                                    'Identifikasi lokasi',
                                  ],
                                ),
                                const SizedBox(height: 12),
                                _buildAktivitasCard(
                                  quarterTitle: 'Q2-Implementasi',
                                  durationText: '4-6 Bulan',
                                  icon: Icons.spa_outlined,
                                  color: const Color(0xFF4C8C5A),
                                  tasks: [
                                    'Rancangan teknis sumur dan sungai',
                                    'Pengadaan material dan bibit',
                                    'Lakukan pelatihan teknis dasar',
                                  ],
                                ),
                                const SizedBox(height: 12),
                                _buildAktivitasCard(
                                  quarterTitle: 'Q3-Monitoring',
                                  durationText: '7-9 Bulan',
                                  icon: Icons.search_rounded,
                                  color: const Color(0xFF4C8C5A),
                                  tasks: [
                                    'Bangun sumur resapan serentak',
                                    'Bersihkan dan tanam tepi sungai',
                                    'Libatkan warga dalam kerja bakti masal',
                                  ],
                                ),
                                const SizedBox(height: 12),
                                _buildAktivitasCard(
                                  quarterTitle: 'Q4-Optimalisasi',
                                  durationText: '10-12 bulan',
                                  icon: Icons.emoji_events_outlined,
                                  color: const Color(0xFF4C8C5A),
                                  tasks: [
                                    'Uji fungsi sumur dan sungai',
                                    'Bentuk tim pemeliharaan warga',
                                    'Lakukan monitoring dan evaluasi',
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          ElevatedButton.icon(
                            icon: const Icon(Icons.check_circle_outline, color: Colors.white),
                            label: const Text('Selesaikan Laporan Akhir', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            onPressed: () => context.go('/summary-report'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4C8C5A),
                              minimumSize: const Size(double.infinity, 52),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ],
                    ),
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
