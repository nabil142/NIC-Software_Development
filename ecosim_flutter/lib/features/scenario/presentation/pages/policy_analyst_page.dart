import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/visualizations/radar_chart.dart';
import '../../../../core/widgets/shared_bottom_nav_bar.dart';
import '../controllers/scenario_controller.dart';
import '../../data/models/scenario_model.dart';

class PolicyAnalystPage extends ConsumerStatefulWidget {
  const PolicyAnalystPage({super.key});

  @override
  ConsumerState<PolicyAnalystPage> createState() => _PolicyAnalystPageState();
}

class _PolicyAnalystPageState extends ConsumerState<PolicyAnalystPage> {
  int _carouselIndex = 0;
  final Set<String> _selectedScenarioIds = {};

  final List<Color> _distinctColors = const [
    Color(0xFF0D6EFD),
    Color(0xFFEBB629),
    Color(0xFF198754),
    Color(0xFFDC3545),
    Color(0xFF6F42C1),
    Color(0xFFFD7E14),
    Color(0xFF0DCAF0),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final active = ref.read(scenarioControllerProvider).activeScenario;
      final scenarios = ref.read(scenarioControllerProvider).scenarios;
      if (active == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pilih skenario aktif terlebih dahulu.'),
          ),
        );
        context.go('/scenarios');
        return;
      }

      setState(() {
        _selectedScenarioIds.clear();
        _selectedScenarioIds.add(active.id);

        final otherScenarios =
            scenarios.where((s) => s.id != active.id).toList();
        for (var i = 0; i < math.min(2, otherScenarios.length); i++) {
          _selectedScenarioIds.add(otherScenarios[i].id);
        }
      });

      if (active.aiAnalysis == null) {
        ref.read(scenarioControllerProvider.notifier).runAIAnalysis();
      }
    });
  }

  Map<String, List<String>> _parseAiOutput(String rawText) {
    final Map<String, List<String>> parsed = {
      'rec': [],
      'risk': [],
      'insight': [],
    };

    final lines = rawText.split('\n');
    String currentSection = '';

    for (var line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;

      final lower = trimmed.toLowerCase();

      if (lower.startsWith('### rekomendasi terbaik')) {
        currentSection = 'rec_title';
        continue;
      } else if (lower.startsWith('### alasan rekomendasi') ||
          lower.startsWith('### kelebihan skenario terbaik')) {
        currentSection = 'rec';
        continue;
      } else if (lower.startsWith('### risiko & hambatan') ||
          lower.startsWith('### risiko') ||
          lower.startsWith('### hambatan')) {
        currentSection = 'risk';
        continue;
      } else if (lower.startsWith('### ringkasan perbandingan') ||
          lower.startsWith('### ringkasan') ||
          lower.contains('insight') ||
          lower.contains('kesimpulan')) {
        currentSection = 'insight';
        continue;
      } else if (trimmed.startsWith('## ')) {
        continue;
      }

      if (currentSection == 'rec' || currentSection == 'rec_title') {
        final clean = trimmed.replaceAll(RegExp(r'^[\*\-\✓\d\.\s]+'), '');
        if (clean.isNotEmpty) {
          parsed['rec']!.add(clean);
        }
      } else if (currentSection == 'risk') {
        final clean = trimmed.replaceAll(RegExp(r'^[\*\-\✓\d\.\s]+'), '');
        if (clean.isNotEmpty) {
          parsed['risk']!.add(clean);
        }
      } else if (currentSection == 'insight') {
        final clean = trimmed.replaceAll(RegExp(r'^[\*\-\✓\d\.\s]+'), '');
        if (clean.isNotEmpty) {
          parsed['insight']!.add(clean);
        }
      }
    }

    if (parsed['rec']!.isEmpty &&
        parsed['risk']!.isEmpty &&
        parsed['insight']!.isEmpty) {
      parsed['insight'] = [rawText];
    }

    return parsed;
  }

  @override
  Widget build(BuildContext context) {
    final scenarioState = ref.watch(scenarioControllerProvider);
    final scenarios = scenarioState.scenarios;
    final active = scenarioState.activeScenario;

    if (active == null || scenarios.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('AI Sustainability Analyst')),
        body: const Center(child: Text('Belum ada skenario yang dibuat.')),
      );
    }

    final List<List<double>> datasets = [
      [
        active.baselineWasteHealth.toDouble(),
        active.baselineWaterHealth.toDouble(),
        active.baselineGreenHealth.toDouble(),
        active.baselineResilience.toDouble(),
      ],
    ];
    final List<Color> selectedColors = [const Color(0xFFEBB629)];

    int colorIdx = 0;
    final List<ScenarioModel> selectedScenarios = [];

    if (_selectedScenarioIds.contains(active.id)) {
      selectedScenarios.add(active);
      selectedColors.add(_distinctColors[colorIdx % _distinctColors.length]);
      colorIdx++;
    }

    for (final s in scenarios) {
      if (s.id != active.id && _selectedScenarioIds.contains(s.id)) {
        selectedScenarios.add(s);
        selectedColors.add(_distinctColors[colorIdx % _distinctColors.length]);
        colorIdx++;
      }
    }

    if (selectedScenarios.isEmpty) {
      selectedScenarios.add(active);
      selectedColors.add(_distinctColors[0]);
    }

    for (final s in selectedScenarios) {
      datasets.add([
        s.projectedWasteHealth.toDouble(),
        s.projectedWaterHealth.toDouble(),
        s.projectedGreenHealth.toDouble(),
        s.projectedResilience.toDouble(),
      ]);
    }

    final List<MapEntry<String, Color>> legendItems = [
      const MapEntry('Baseline (Awal)', Color(0xFFEBB629)),
      ...List.generate(selectedScenarios.length, (idx) {
        final s = selectedScenarios[idx];
        final color = selectedColors[idx + 1];
        return MapEntry(s.scenarioName, color);
      }),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF6F5EF),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'AI Sustainability Analyst',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'AI membandingkan seluruh skenario pembangunan desa untuk mencari alternatif terbaik secara holistik',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppTheme.textLight,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 16),

                    Text(
                      'Pilih Skenario untuk Dibandingkan:',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textMedium,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children:
                          scenarios.map((s) {
                            final isSelected = _selectedScenarioIds.contains(
                              s.id,
                            );
                            return FilterChip(
                              label: Text(
                                s.scenarioName,
                                style: GoogleFonts.inter(fontSize: 10),
                              ),
                              selected: isSelected,
                              selectedColor: const Color(0xFFE9F0E6),
                              checkmarkColor: const Color(0xFF4C8C5A),
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(
                                  color: Colors.grey.withOpacity(0.15),
                                ),
                              ),
                              onSelected: (checked) {
                                setState(() {
                                  if (checked) {
                                    _selectedScenarioIds.add(s.id);
                                  } else {
                                    if (_selectedScenarioIds.length > 1) {
                                      _selectedScenarioIds.remove(s.id);
                                    }
                                  }
                                  if (_carouselIndex >=
                                      selectedScenarios.length) {
                                    _carouselIndex = 0;
                                  }
                                });
                              },
                            );
                          }).toList(),
                    ),
                    const SizedBox(height: 16),

                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFE9F0E6),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Spacer(),
                                  EnvitorRadarChart(
                                    multipleDatasets: datasets,
                                    multipleColors: selectedColors,
                                    size: 125,
                                  ),
                                  const Spacer(),

                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 4,
                                    alignment: WrapAlignment.center,
                                    children:
                                        legendItems.map((entry) {
                                          return Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                width: 8,
                                                height: 8,
                                                color: entry.value,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                entry.key,
                                                style: GoogleFonts.inter(
                                                  fontSize: 7.5,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppTheme.textMedium,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          );
                                        }).toList(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),

                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFE9F0E6),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              padding: const EdgeInsets.only(
                                left: 16.0,
                                top: 16.0,
                                bottom: 16.0,
                                right: 12.0,
                              ),
                              child: Stack(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(right: 25.0),
                                    child: Builder(
                                      builder: (context) {
                                        final currentIdx =
                                            _carouselIndex %
                                            selectedScenarios.length;
                                        final s = selectedScenarios[currentIdx];

                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              s.scenarioName,
                                              style:
                                                  GoogleFonts.plusJakartaSans(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.bold,
                                                    color: AppTheme.textDark,
                                                  ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 8),
                                            _buildIndicatorRow(
                                              label: 'Pengelolaan Limbah',
                                              scoreVal: s.projectedWasteHealth,
                                              icon: Icons.recycling_outlined,
                                            ),
                                            _buildIndicatorRow(
                                              label: 'Kualitas Air',
                                              scoreVal: s.projectedWaterHealth,
                                              icon: Icons.water_drop_outlined,
                                            ),
                                            _buildIndicatorRow(
                                              label: 'Pengelolaan Lingkungan',
                                              scoreVal: s.projectedGreenHealth,
                                              icon: Icons.park_outlined,
                                            ),
                                            _buildIndicatorRow(
                                              label: 'Ketahanan Bencana',
                                              scoreVal: s.projectedResilience,
                                              icon: Icons.shield_outlined,
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  ),

                                  Positioned(
                                    right: -8,
                                    top: 0,
                                    bottom: 0,
                                    child: Center(
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _carouselIndex =
                                                (_carouselIndex + 1) %
                                                selectedScenarios.length;
                                          });
                                        },
                                        child: const Icon(
                                          Icons.chevron_right,
                                          size: 22,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    if (scenarioState.isLoading) ...[
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40.0),
                        child: Column(
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text(
                              'Gemini AI sedang menghitung kecocokan skenario...',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.textLight,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else if (active.aiAnalysis == null) ...[
                      const Card(
                        child: Padding(
                          padding: EdgeInsets.all(24.0),
                          child: Text(
                            'Gagal terhubung dengan AI. Silakan coba kembali.',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ] else ...[
                      _buildStructuredCards(
                        active.scenarioName,
                        active.aiAnalysis!,
                      ),
                      const SizedBox(height: 20),

                      ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                title: Text(
                                  'Pilih Skenario untuk Blueprint',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                content: SingleChildScrollView(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children:
                                        scenarios.map((s) {
                                          return ListTile(
                                            title: Text(
                                              s.scenarioName,
                                              style: GoogleFonts.inter(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            trailing: const Icon(
                                              Icons.arrow_forward_ios,
                                              size: 16,
                                            ),
                                            onTap: () {
                                              ref
                                                  .read(
                                                    scenarioControllerProvider
                                                        .notifier,
                                                  )
                                                  .selectActiveScenario(s);
                                              Navigator.pop(context);
                                              context.go('/blueprint');
                                            },
                                          );
                                        }).toList(),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4C8C5A),
                          minimumSize: const Size(double.infinity, 52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Lihat Blueprint ',
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Colors.white,
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward,
                              size: 16,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ],
                ),
              ),
            ),

            const SharedBottomNavBar(currentIndex: 2),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicatorRow({
    required String label,
    required int scoreVal,
    required IconData icon,
  }) {
    final statusText = _valToStatusText(scoreVal);
    final statusColor = _getStatusColor(scoreVal);
    final fillPercent = scoreVal / 4.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 8.5,
              fontWeight: FontWeight.bold,
              color: AppTheme.textMedium,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 22,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Stack(
                    children: [
                      FractionallySizedBox(
                        widthFactor: fillPercent,
                        child: Container(
                          decoration: BoxDecoration(
                            color: statusColor,
                            borderRadius: BorderRadius.circular(11),
                          ),
                        ),
                      ),

                      Positioned(
                        left: 10,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: Text(
                            statusText,
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),

              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(
                    color: statusColor.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Icon(icon, color: statusColor, size: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _valToStatusText(int val) {
    switch (val) {
      case 1:
        return 'Poor';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      case 4:
        return 'Excellent';
      default:
        return 'Poor';
    }
  }

  Color _getStatusColor(int val) {
    switch (val) {
      case 1:
        return const Color(0xFFEE5D5D);
      case 2:
        return const Color(0xFFEBB629);
      case 3:
        return const Color(0xFF6FAF4F);
      case 4:
        return const Color(0xFF3E6D4E);
      default:
        return const Color(0xFFEE5D5D);
    }
  }

  Widget _buildHorizontalStructuredCard({
    required Color cardBg,
    required Color iconBg,
    required IconData iconData,
    required Color iconColor,
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

  Widget _buildStructuredCards(String scenarioName, String rawText) {
    final parsed = _parseAiOutput(rawText);

    final recBullets = List<String>.from(parsed['rec']!);
    String recommendedScenarioName = scenarioName;
    if (recBullets.isNotEmpty &&
        recBullets[0].toLowerCase().contains('skenario')) {
      recommendedScenarioName = recBullets.removeAt(0);
    }

    final riskBullets = parsed['risk']!;
    final insightParagraphs = parsed['insight']!;

    return Column(
      children: [
        _buildHorizontalStructuredCard(
          cardBg: const Color(0xFFFFF4D4),
          iconBg: const Color(0xFFFBBF24),
          iconData: Icons.emoji_events,
          iconColor: Colors.white,
          tagText: 'REKOMENDASI TERBAIK AI',
          tagBg: const Color(0xFFFFF0C2),
          tagTextColor: const Color(0xFFD97706),
          title: recommendedScenarioName,
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (recBullets.isNotEmpty) ...[
                Text(
                  '$recommendedScenarioName memberikan peningkatan paling optimal dan seimbang di seluruh indikator keberlanjutan desa.',
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    color: AppTheme.textMedium,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 10),
                ...recBullets.map(
                  (bullet) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Color(0xFF6FAF4F),
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            bullet,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: AppTheme.textMedium,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ] else
                const Text(
                  'AI memproyeksikan peningkatan seimbang di seluruh aspek lingkungan.',
                  style: TextStyle(fontSize: 11),
                ),
            ],
          ),
        ),

        _buildHorizontalStructuredCard(
          cardBg: const Color(0xFFFFEBEB),
          iconBg: const Color(0xFFF87171),
          iconData: Icons.gpp_maybe,
          iconColor: Colors.white,
          tagText: 'RESIKO DAN HAMBATAN',
          tagBg: const Color(0xFFFEE2E2),
          tagTextColor: const Color(0xFFEF4444),
          title: recommendedScenarioName,
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (riskBullets.isNotEmpty)
                ...riskBullets.map(
                  (bullet) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          margin: const EdgeInsets.only(
                            top: 6,
                            left: 5,
                            right: 10,
                          ),
                          decoration: const BoxDecoration(
                            color: Color(0xFFF87171),
                            shape: BoxShape.circle,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            bullet,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: AppTheme.textMedium,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                const Text(
                  'Tidak ada resiko signifikan yang terdeteksi oleh AI.',
                  style: TextStyle(fontSize: 11),
                ),
            ],
          ),
        ),

        _buildHorizontalStructuredCard(
          cardBg: const Color(0xFFE9F5E6),
          iconBg: const Color(0xFF4C8C5A),
          iconData: Icons.lightbulb_outline,
          iconColor: Colors.white,
          tagText: 'INSIGHT AI',
          tagBg: const Color(0xFFD1FAE5),
          tagTextColor: const Color(0xFF065F46),
          title: recommendedScenarioName,
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...insightParagraphs.map(
                (p) => Padding(
                  padding: const EdgeInsets.only(bottom: 6.0),
                  child: Text(
                    p,
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      color: AppTheme.textMedium,
                      height: 1.4,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

}
