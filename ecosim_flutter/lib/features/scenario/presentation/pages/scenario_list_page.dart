import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/visualizations/radar_chart.dart';
import '../../../village/presentation/controllers/village_controller.dart';
import '../../../assessment/presentation/controllers/assessment_controller.dart';
import '../controllers/scenario_controller.dart';

class ScenarioListPage extends ConsumerStatefulWidget {
  const ScenarioListPage({super.key});

  @override
  ConsumerState<ScenarioListPage> createState() => _ScenarioListPageState();
}

class _ScenarioListPageState extends ConsumerState<ScenarioListPage> {
  int _currentNavIndex = 0; // 0: Home, 1: Settings, 2: Future Builder, 3: Account

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final villageState = ref.read(villageControllerProvider);
    if (villageState.activeVillage == null) {
      await ref.read(villageControllerProvider.notifier).loadActiveVillage();
    }
    
    final village = ref.read(villageControllerProvider).activeVillage;
    if (village != null) {
      ref.read(assessmentControllerProvider.notifier).loadLatestAssessment(village.id);
      ref.read(scenarioControllerProvider.notifier).loadScenarios(village.id);
    } else {
      context.go('/village-profile');
    }
  }

  String _translateStatus(String status) {
    switch (status.toLowerCase()) {
      case 'poor':
        return 'Poor';
      case 'fair':
        return 'Fair';
      case 'good':
        return 'Good';
      case 'excellent':
        return 'Excellent';
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

  int _statusToVal(String status) {
    switch (status.toLowerCase()) {
      case 'poor':
        return 1;
      case 'fair':
        return 2;
      case 'good':
        return 3;
      case 'excellent':
        return 4;
      default:
        return 1;
    }
  }

  Widget _buildPreviewRow({
    required String label,
    required String status,
    required IconData icon,
    required Color color,
  }) {
    final displayStatus = _translateStatus(status);
    final val = _statusToVal(status);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              // Progress Bar Track
              Expanded(
                child: Container(
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white, // Solid white background track matching mockup
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Stack(
                    children: [
                      // Filled portion
                      FractionallySizedBox(
                        widthFactor: val / 4.0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                      // Text Status inside bar
                      Positioned(
                        left: 14,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: Text(
                            displayStatus,
                            style: GoogleFonts.inter(
                              color: val >= 3 ? Colors.white : AppTheme.textDark,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Circular icon container
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white, // Solid white background
                  shape: BoxShape.circle,
                  border: Border.all(color: color, width: 1.5),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final villageState = ref.watch(villageControllerProvider);
    final assessmentState = ref.watch(assessmentControllerProvider);
    final village = villageState.activeVillage;
    final assessmentRes = assessmentState.latestAssessment;

    // Fetch values for radar chart
    List<double> radarValues = [2.0, 2.0, 2.0, 2.0];
    String overallStatus = 'Fair';
    if (assessmentRes != null) {
      radarValues = [
        _statusToVal(assessmentRes.dnaScores.wasteHealth).toDouble(),
        _statusToVal(assessmentRes.dnaScores.waterHealth).toDouble(),
        _statusToVal(assessmentRes.dnaScores.greenHealth).toDouble(),
        _statusToVal(assessmentRes.dnaScores.resilience).toDouble(),
      ];
      // calculate general average status
      double avg = radarValues.reduce((a, b) => a + b) / 4.0;
      if (avg <= 1.5) {
        overallStatus = 'Poor';
      } else if (avg <= 2.5) {
        overallStatus = 'Fair';
      } else if (avg <= 3.5) {
        overallStatus = 'Good';
      } else {
        overallStatus = 'Excellent';
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F4), // Warm off-white background matching mockup
      appBar: null, // Transparent full-screen look, no app bar
      body: Stack(
        children: [
          // 1. Fading Mountain Background Image at top
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 250,
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
                'assets/images/village_header.png',
                fit: BoxFit.cover,
                alignment: const Alignment(0, -0.95), // Align to mountain ridge top area
              ),
            ),
          ),

          // 2. Scrollable Body Content
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _loadData,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 12),
                          // Header Section
                          Text(
                            'Selamat Pagi',
                            style: GoogleFonts.inter(
                              color: AppTheme.textMedium,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Desa ${village?.villageName ?? 'Sukamaju'}',
                            style: GoogleFonts.plusJakartaSans(
                              color: AppTheme.textDark,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on, 
                                color: Color(0xFF4C8C5A), 
                                size: 15,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Kecamatan ${village?.villageName ?? 'Sukamaju'}, Kab. Jaya',
                                style: GoogleFonts.inter(
                                  color: AppTheme.textMedium,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Dark Green Village Stats Card (Centered, Size: 311 x 168)
                          Center(
                            child: SizedBox(
                              width: 311,
                              height: 168,
                              child: ClipPath(
                                clipper: StatsCardClipper(),
                                child: Container(
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xFF567B50), // Left: Dark Green
                                        Color(0xFF68C15B), // Right: Light Green
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                  child: Stack(
                                    children: [
                                      // Village Island Image on Right (Restricted inside shorter portion)
                                      Positioned(
                                        right: -15,
                                        bottom: -15,
                                        top: 15, // Expanded top-wise for larger appearance
                                        width: 225, // Enlarged width from 195
                                        child: Image.asset(
                                          'assets/images/village_header.png',
                                          fit: BoxFit.contain,
                                          alignment: Alignment.bottomRight,
                                        ),
                                      ),

                                      // Stats badges/pills on Left (within the taller left portion)
                                      Positioned(
                                        left: 12, // Shifted left to make room
                                        bottom: 0,
                                        top: 0, // Uses full height since left top boundary is y=0.0
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            // Population Badge
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF1E442B), // Dark green pill matching mockup
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(Icons.eco_outlined, color: Color(0xFF7CD28E), size: 12), // Eco/community icon (scaled down)
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    village != null ? 'Penduduk ${village.population} jiwa' : 'Penduduk 3.520 jiwa',
                                                    style: GoogleFonts.inter(
                                                      color: Colors.white,
                                                      fontSize: 8.5, // Scaled down from 9.5
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            // Area Badge
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF1E442B), // Dark green pill matching mockup
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(Icons.crop_free, color: Color(0xFF7CD28E), size: 12), // Target crop-free icon (scaled down)
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    village != null ? 'Luas Wilayah ${village.areaKm2} km²' : 'Luas Wilayah 15.5 km²',
                                                    style: GoogleFonts.inter(
                                                      color: Colors.white,
                                                      fontSize: 8.5, // Scaled down from 9.5
                                                      fontWeight: FontWeight.bold,
                                                    ),
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

                          // Section Title: Preview Desa
                          Text(
                            'Preview Desa',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: AppTheme.textDark,
                            ),
                          ),
                          const SizedBox(height: 10),

                          if (assessmentRes == null) ...[
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFE9F0E6),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                children: [
                                  const Icon(Icons.assignment_outlined, color: AppTheme.accentColor, size: 42),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Lakukan asesmen untuk memuat data desa.',
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      color: AppTheme.textMedium,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF3E6D4E),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    onPressed: () => context.go('/assessment'),
                                    child: const Text('Ambil Asesmen Awal'),
                                  ),
                                ],
                              ),
                            ),
                          ] else ...[
                             Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFE3EED0), // Light sage green container background
                                borderRadius: BorderRadius.circular(24),
                              ),
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                children: [
                                  _buildPreviewRow(
                                    label: 'Pengelolaan Limbah',
                                    status: assessmentRes.dnaScores.wasteHealth,
                                    icon: Icons.recycling_outlined,
                                    color: _getStatusColor(assessmentRes.dnaScores.wasteHealth),
                                  ),
                                  _buildPreviewRow(
                                    label: 'Kualitas Air',
                                    status: assessmentRes.dnaScores.waterHealth,
                                    icon: Icons.water_drop_outlined,
                                    color: _getStatusColor(assessmentRes.dnaScores.waterHealth),
                                  ),
                                  _buildPreviewRow(
                                    label: 'Pengelolaan Lingkungan',
                                    status: assessmentRes.dnaScores.greenHealth,
                                    icon: Icons.park_outlined,
                                    color: _getStatusColor(assessmentRes.dnaScores.greenHealth),
                                  ),
                                  _buildPreviewRow(
                                    label: 'Ketahanan Bencana',
                                    status: assessmentRes.dnaScores.resilience,
                                    icon: Icons.shield_outlined,
                                    color: _getStatusColor(assessmentRes.dnaScores.resilience),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 24),

                          // Section: Status Keseluruhan
                          if (assessmentRes != null) ...[
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFE3EED0), // Same light green tint background
                                borderRadius: BorderRadius.circular(24),
                              ),
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Status Keseluruhan',
                                              style: GoogleFonts.plusJakartaSans(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: AppTheme.textDark,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              _translateStatus(overallStatus),
                                              style: GoogleFonts.playfairDisplay(
                                                fontSize: 38,
                                                fontWeight: FontWeight.bold,
                                                color: _getStatusColor(overallStatus),
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              'Kondisi rata-rata seluruh indeks lingkungan desa',
                                              style: GoogleFonts.inter(
                                                fontSize: 11,
                                                color: AppTheme.textMedium,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      const Icon(
                                        Icons.eco, 
                                        color: Color(0xFF67B05C), 
                                        size: 34,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  // Center Radar Chart
                                  Center(
                                    child: EcosimRadarChart(
                                      values: radarValues,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                // Bottom Navigation Bar matching design style
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.15), width: 1)),
                  ),
                  child: SafeArea(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildNavItem(0, Icons.home_outlined, Icons.home),
                        _buildNavItem(1, Icons.settings_outlined, Icons.settings),
                        _buildNavItem(2, Icons.auto_awesome_outlined, Icons.auto_awesome),
                        _buildNavItem(3, Icons.person_outline, Icons.person),
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

  Widget _buildNavItem(int index, IconData outline, IconData solid) {
    final isActive = _currentNavIndex == index;
    final color = isActive ? const Color(0xFF3E6D4E) : Colors.grey;

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentNavIndex = index;
        });
        if (index == 0) {
          context.go('/scenarios');
        } else if (index == 1) {
          context.go('/future-builder');
        } else if (index == 2) {
          final activeScenario = ref.read(scenarioControllerProvider).activeScenario;
          if (activeScenario == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Buat skenario di Future Builder terlebih dahulu.'),
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
        decoration: const BoxDecoration(
          color: Colors.transparent,
        ),
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

class StatsCardClipper extends CustomClipper<Path> {
  final double radius;

  StatsCardClipper({this.radius = 28.0});

  @override
  Path getClip(Size size) {
    final path = Path();
    final w = size.width;
    final h = size.height;
    
    // Left top edge is higher, right top edge is lower (matching flipped direction in mockup)
    const topYLeft = 0.0;
    const topYRight = 32.0;
    
    // Start at top-left, after the corner radius
    path.moveTo(radius, topYLeft);
    
    // Transition starts at 45% and ends at 65% of the card width
    final transitionStart = w * 0.45;
    final transitionEnd = w * 0.65;
    
    path.lineTo(transitionStart, topYLeft);
    
    // Smooth S-curve transition to the shorter right side
    path.cubicTo(
      (transitionStart + transitionEnd) / 2, topYLeft,
      (transitionStart + transitionEnd) / 2, topYRight,
      transitionEnd, topYRight,
    );
    
    // Top-right corner
    path.lineTo(w - radius, topYRight);
    path.arcToPoint(
      Offset(w, topYRight + radius),
      radius: Radius.circular(radius),
      clockwise: true,
    );
    
    // Bottom-right corner
    path.lineTo(w, h - radius);
    path.arcToPoint(
      Offset(w - radius, h),
      radius: Radius.circular(radius),
      clockwise: true,
    );
    
    // Bottom-left corner
    path.lineTo(radius, h);
    path.arcToPoint(
      Offset(w * 0.0, h - radius),
      radius: Radius.circular(radius),
      clockwise: true,
    );
    
    // Back to top-left corner
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
