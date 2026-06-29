import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/knowledge_base.dart';
import '../../../../core/visualizations/radar_chart.dart';
import '../../../village/presentation/controllers/village_controller.dart';
import '../../../assessment/presentation/controllers/assessment_controller.dart';
import '../controllers/scenario_controller.dart';

class FutureBuilderPage extends ConsumerStatefulWidget {
  const FutureBuilderPage({super.key});

  @override
  ConsumerState<FutureBuilderPage> createState() => _FutureBuilderPageState();
}

class _FutureBuilderPageState extends ConsumerState<FutureBuilderPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final List<String> _selectedPrograms = [];

  int _baseWaste = 1;
  int _baseWater = 1;
  int _baseGreen = 1;
  int _baseRes = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final assessment =
          ref.read(assessmentControllerProvider).latestAssessment;
      if (assessment != null) {
        setState(() {
          _baseWaste = _statusToVal(assessment.dnaScores.wasteHealth);
          _baseWater = _statusToVal(assessment.dnaScores.waterHealth);
          _baseGreen = _statusToVal(assessment.dnaScores.greenHealth);
          _baseRes = _statusToVal(assessment.dnaScores.resilience);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Anda harus menyelesaikan asesmen awal terlebih dahulu.',
            ),
          ),
        );
        context.go('/scenarios');
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  int _statusToVal(String status) {
    switch (status.toLowerCase()) {
      case 'poor':
      case 'kurang':
        return 1;
      case 'fair':
      case 'cukup':
        return 2;
      case 'good':
      case 'baik':
        return 3;
      case 'excellent':
      case 'sangat baik':
        return 4;
      default:
        return 1;
    }
  }

  Map<String, int> _simulateProjection() {
    int waste = _baseWaste;
    int water = _baseWater;
    int green = _baseGreen;
    int res = _baseRes;

    for (final pId in _selectedPrograms) {
      final prog = getProgramById(pId);
      if (prog == null) continue;

      if (prog.impacts['waste_health'] == 'Strong') waste += 2;
      if (prog.impacts['waste_health'] == 'Moderate') waste += 1;

      if (prog.impacts['water_health'] == 'Strong') water += 2;
      if (prog.impacts['water_health'] == 'Moderate') water += 1;

      if (prog.impacts['green_health'] == 'Strong') green += 2;
      if (prog.impacts['green_health'] == 'Moderate') green += 1;

      if (prog.impacts['resilience'] == 'Strong') res += 2;
      if (prog.impacts['resilience'] == 'Moderate') res += 1;
    }

    return {
      'waste_health': waste.clamp(1, 4),
      'water_health': water.clamp(1, 4),
      'green_health': green.clamp(1, 4),
      'resilience': res.clamp(1, 4),
    };
  }

  String? _getRecommendationLabel(InterventionProgram prog) {
    final assessmentState = ref.watch(assessmentControllerProvider);
    final assessmentRes = assessmentState.latestAssessment;
    if (assessmentRes == null) return null;

    String score = 'Good';
    if (prog.category == 'waste') {
      score = assessmentRes.dnaScores.wasteHealth;
    } else if (prog.category == 'water') {
      score = assessmentRes.dnaScores.waterHealth;
    } else if (prog.category == 'green') {
      score = assessmentRes.dnaScores.greenHealth;
    } else if (prog.category == 'resilience') {
      score = assessmentRes.dnaScores.resilience;
    }

    if (score == 'Poor') {
      return 'Sangat Dibutuhkan';
    } else if (score == 'Fair') {
      return 'Direkomendasikan';
    }
    return null;
  }

  Widget _buildCostBadge(String cost) {
    Color bgColor;
    String text;

    if (cost == 'rendah') {
      text = 'Biaya Rendah';
      bgColor = const Color(0xFF144D37);
    } else if (cost == 'sedang') {
      text = 'Biaya Sedang';
      bgColor = const Color(0xFF7A4F01);
    } else {
      text = 'Biaya Tinggi';
      bgColor = const Color(0xFF7F1D1D);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 7.5,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildRecBadge(String label) {
    Color bgColor = const Color(0xFFDBEAFE);
    Color textColor = const Color(0xFF1D4ED8);
    if (label == 'Sangat Dibutuhkan') {
      bgColor = const Color(0xFFFEE2E2);
      textColor = const Color(0xFFEF4444);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 7.5,
          color: textColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Future<void> _saveScenario() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPrograms.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih minimal satu program kerja intervensi.'),
          backgroundColor: AppTheme.poorColor,
        ),
      );
      return;
    }

    final village = ref.read(villageControllerProvider).activeVillage;
    if (village == null) return;

    final scenario = await ref
        .read(scenarioControllerProvider.notifier)
        .createNewScenario(
          villageId: village.id,
          scenarioName: _nameController.text.trim(),
          selectedPrograms: _selectedPrograms,
        );

    if (scenario != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Skenario simulasi berhasil disimpan!'),
          backgroundColor: AppTheme.excellentColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scenarioState = ref.watch(scenarioControllerProvider);
    final projected = _simulateProjection();

    List<double> baselineRadar = [
      _baseWaste.toDouble(),
      _baseWater.toDouble(),
      _baseGreen.toDouble(),
      _baseRes.toDouble(),
    ];

    List<double> projectedRadar = [
      projected['waste_health']!.toDouble(),
      projected['water_health']!.toDouble(),
      projected['green_health']!.toDouble(),
      projected['resilience']!.toDouble(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF6F5EF),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Future Builder',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color: AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Bangun Skenario Desa yang Lebih Baik',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppTheme.textLight,
                        ),
                      ),
                      const SizedBox(height: 16),

                      Center(
                        child: SizedBox(
                          width: double.infinity,
                          height: 180,
                          child: ClipPath(
                            clipper: _StatsCardClipper(),
                            child: Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFF567B50),
                                    Color(0xFF68C15B),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: Stack(
                                children: [
                                  Positioned(
                                    right: -10,
                                    bottom: -15,
                                    top: 15,
                                    width: 220,
                                    child: Image.asset(
                                      'assets/images/future_builder_header.png',
                                      fit: BoxFit.contain,
                                      alignment: Alignment.bottomRight,
                                      errorBuilder: (
                                        context,
                                        error,
                                        stackTrace,
                                      ) {
                                        return const SizedBox();
                                      },
                                    ),
                                  ),

                                  Positioned(
                                    left: 16,
                                    top: 16,
                                    bottom: 16,
                                    right: 150,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                              top: 8.0,
                                            ),
                                            child: Text(
                                              'Rencanakan program lingkungan untuk mewujudkan desa yang berkelanjutan',
                                              style: GoogleFonts.inter(
                                                color: Colors.white,
                                                fontSize: 11,
                                                fontWeight: FontWeight.w500,
                                                height: 1.4,
                                              ),
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(
                                              0.95,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(
                                                  0.05,
                                                ),
                                                blurRadius: 4,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(
                                                  4,
                                                ),
                                                decoration: const BoxDecoration(
                                                  color: Color(0xFFE9F0E6),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(
                                                  Icons.gps_fixed_rounded,
                                                  color: Color(0xFF4C8C5A),
                                                  size: 16,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    'Target Status',
                                                    style:
                                                        GoogleFonts.plusJakartaSans(
                                                          fontSize: 9,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color:
                                                              AppTheme.textDark,
                                                        ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Row(
                                                    children: [
                                                      Text(
                                                        'Fair',
                                                        style:
                                                            GoogleFonts.inter(
                                                              color:
                                                                  const Color(
                                                                    0xFFD6A024,
                                                                  ),
                                                              fontSize: 10,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                      ),
                                                      Text(
                                                        ' ➔ ',
                                                        style:
                                                            GoogleFonts.inter(
                                                              color:
                                                                  Colors.grey,
                                                              fontSize: 10,
                                                            ),
                                                      ),
                                                      Text(
                                                        'Good',
                                                        style:
                                                            GoogleFonts.inter(
                                                              color:
                                                                  const Color(
                                                                    0xFF4C8C5A,
                                                                  ),
                                                              fontSize: 10,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
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
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE9F0E6),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Program Rekomendasi',
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: AppTheme.textDark,
                              ),
                            ),
                            const SizedBox(height: 16),
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: programsCatalog.length,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 10,
                                    mainAxisSpacing: 12,
                                    childAspectRatio: 0.73,
                                  ),
                              itemBuilder: (context, index) {
                                final prog = programsCatalog[index];
                                final isSelected = _selectedPrograms.contains(
                                  prog.id,
                                );
                                final recLabel = _getRecommendationLabel(prog);

                                return Card(
                                  color: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    side: BorderSide(
                                      color:
                                          isSelected
                                              ? const Color(0xFF568A50)
                                              : Colors.transparent,
                                      width: isSelected ? 1.5 : 0,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Container(
                                              width: 44,
                                              height: 44,
                                              decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Color(0xFF568A50),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  prog.icon,
                                                  style: const TextStyle(
                                                    fontSize: 20,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    prog.name,
                                                    style:
                                                        GoogleFonts.plusJakartaSans(
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color:
                                                              AppTheme.textDark,
                                                        ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(height: 4),
                                                  _buildCostBadge(prog.cost),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        if (recLabel != null) ...[
                                          _buildRecBadge(recLabel),
                                          const SizedBox(height: 6),
                                        ],
                                        Expanded(
                                          child: Text(
                                            prog.description,
                                            style: GoogleFonts.inter(
                                              fontSize: 9,
                                              color: AppTheme.textMedium,
                                              height: 1.3,
                                            ),
                                            maxLines: 3,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        InkWell(
                                          onTap: () {
                                            setState(() {
                                              if (isSelected) {
                                                _selectedPrograms.remove(
                                                  prog.id,
                                                );
                                              } else {
                                                _selectedPrograms.add(prog.id);
                                              }
                                            });
                                          },
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          child: Container(
                                            height: 32,
                                            decoration: BoxDecoration(
                                              color:
                                                  isSelected
                                                      ? const Color(0xFF144D37)
                                                      : const Color(0xFF568A50),
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            child: Center(
                                              child: Text(
                                                isSelected
                                                    ? 'Terpilih'
                                                    : '+ Tambahkan',
                                                style: GoogleFonts.inter(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      if (_selectedPrograms.isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE9F0E6),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.assignment_turned_in_outlined,
                                    color: AppTheme.primaryColor,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Program Dipilih (${_selectedPrograms.length})',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: AppTheme.textDark,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  ..._selectedPrograms.map((pId) {
                                    final prog = getProgramById(pId);
                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: Colors.grey.withOpacity(0.2),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            prog?.icon ?? '🌱',
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            prog?.name ?? pId,
                                            style: GoogleFonts.inter(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: AppTheme.textDark,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: Colors.grey.withOpacity(0.2),
                                      ),
                                    ),
                                    child: Text(
                                      '+ Tambah Program',
                                      style: GoogleFonts.inter(
                                        fontSize: 10,
                                        color: AppTheme.textMedium,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE9F0E6),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.show_chart_rounded,
                                  color: AppTheme.primaryColor,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Preview Dampak',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: AppTheme.textDark,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            EcosimRadarChart(
                              values: baselineRadar,
                              projectedValues: projectedRadar,
                              baselineColor: AppTheme.primaryColor,
                              projectedColor: const Color(0xFF0D6EFD),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 32,
                                  height: 4,
                                  color: AppTheme.primaryColor,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Saat Ini',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textDark,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 32,
                                  height: 4,
                                  color: const Color(0xFF0D6EFD),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Setelah Simulasi',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textDark,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE9F0E6),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _nameController,
                                decoration: InputDecoration(
                                  hintText: 'Nama Skenario',
                                  hintStyle: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: AppTheme.textLight,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                validator: (val) {
                                  if (val == null || val.isEmpty) {
                                    return 'Ketik nama skenario.';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton(
                              onPressed:
                                  scenarioState.isLoading
                                      ? null
                                      : _saveScenario,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF558B55),
                                minimumSize: const Size(120, 48),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: const Text(
                                'Simpan Skenario',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      if (scenarioState.errorMessage != null) ...[
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.poorColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            scenarioState.errorMessage!,
                            style: const TextStyle(
                              color: AppTheme.poorColor,
                              fontSize: 13,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(
                    color: Colors.grey.withOpacity(0.15),
                    width: 1,
                  ),
                ),
              ),
              child: SafeArea(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(0, Icons.home_outlined, Icons.home),
                    _buildNavItem(1, Icons.settings_outlined, Icons.settings),
                    _buildNavItem(
                      2,
                      Icons.auto_awesome_outlined,
                      Icons.auto_awesome,
                    ),
                    _buildNavItem(3, Icons.person_outline, Icons.person),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData outline, IconData solid) {
    const int currentNavIndex = 1;
    final isActive = currentNavIndex == index;
    final color = isActive ? const Color(0xFF3E6D4E) : Colors.grey;

    return GestureDetector(
      onTap: () {
        if (index == 0) {
          context.go('/scenarios');
        } else if (index == 1) {
          context.go('/future-builder');
        } else if (index == 2) {
          final activeScenario =
              ref.read(scenarioControllerProvider).activeScenario;
          if (activeScenario == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Buat skenario di Future Builder terlebih dahulu.',
                ),
                backgroundColor: AppTheme.poorColor,
              ),
            );
            context.go('/future-builder');
          } else {
            context.go('/policy-analyst');
          }
        } else if (index == 3) {
          context.go('/village-profile');
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: const BoxDecoration(color: Colors.transparent),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(isActive ? solid : outline, color: color, size: 28),
            if (isActive) ...[
              const SizedBox(height: 4),
              Container(
                width: 16,
                height: 3,
                decoration: BoxDecoration(
                  color: const Color(0xFF3E6D4E),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatsCardClipper extends CustomClipper<Path> {
  final double radius;

  _StatsCardClipper({this.radius = 16.0});

  @override
  Path getClip(Size size) {
    final path = Path();
    final w = size.width;
    final h = size.height;

    const topYLeft = 0.0;
    const topYRight = 32.0;

    path.moveTo(radius, topYLeft);

    final transitionStart = w * 0.45;
    final transitionEnd = w * 0.65;

    path.lineTo(transitionStart, topYLeft);

    path.cubicTo(
      (transitionStart + transitionEnd) / 2,
      topYLeft,
      (transitionStart + transitionEnd) / 2,
      topYRight,
      transitionEnd,
      topYRight,
    );

    path.lineTo(w - radius, topYRight);
    path.arcToPoint(
      Offset(w, topYRight + radius),
      radius: Radius.circular(radius),
      clockwise: true,
    );

    path.lineTo(w, h - radius);
    path.arcToPoint(
      Offset(w - radius, h),
      radius: Radius.circular(radius),
      clockwise: true,
    );

    path.lineTo(radius, h);
    path.arcToPoint(
      Offset(w * 0.0, h - radius),
      radius: Radius.circular(radius),
      clockwise: true,
    );

    path.lineTo(0.0, topYLeft + radius);
    path.arcToPoint(
      Offset(radius, topYLeft),
      radius: Radius.circular(radius),
      clockwise: true,
    );

    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
