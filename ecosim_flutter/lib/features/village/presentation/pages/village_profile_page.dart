import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../features/auth/presentation/controllers/auth_controller.dart';
import '../controllers/village_controller.dart';
import '../../../assessment/presentation/controllers/assessment_controller.dart';
import '../../../scenario/presentation/controllers/scenario_controller.dart';

class VillageProfilePage extends ConsumerStatefulWidget {
  const VillageProfilePage({super.key});

  @override
  ConsumerState<VillageProfilePage> createState() => _VillageProfilePageState();
}

class _VillageProfilePageState extends ConsumerState<VillageProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _districtController = TextEditingController();
  final _cityController = TextEditingController();
  final _areaController = TextEditingController();
  final _populationController = TextEditingController();
  final _potentialController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final village = ref.read(villageControllerProvider).activeVillage;
      if (village != null) {
        _nameController.text = village.villageName;
        _populationController.text = village.population.toString();
        _areaController.text = village.areaKm2.toString();
        _districtController.text = village.districtName ?? '';
        _cityController.text = village.cityName ?? '';
        _potentialController.text = village.potential ?? '';
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _districtController.dispose();
    _cityController.dispose();
    _areaController.dispose();
    _populationController.dispose();
    _potentialController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(villageControllerProvider.notifier).saveProfile(
      villageName: _nameController.text.trim(),
      population: int.parse(_populationController.text.trim()),
      areaKm2: double.parse(_areaController.text.trim()),
      districtName: _districtController.text.trim(),
      cityName: _cityController.text.trim(),
      potential: _potentialController.text.trim(),
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil desa berhasil disimpan!'),
          backgroundColor: AppTheme.excellentColor,
        ),
      );
      // Pindah ke dashboard atau asesmen jika berhasil
      final hasAssessment = ref.read(assessmentControllerProvider).latestAssessment != null;
      if (hasAssessment) {
        context.go('/scenarios');
      } else {
        context.go('/assessment');
      }
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String title,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE9F0E6),
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
            ),
            child: Icon(icon, color: AppTheme.textDark, size: 28),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextFormField(
                controller: controller,
                keyboardType: keyboardType,
                decoration: InputDecoration(
                  labelText: title,
                  labelStyle: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMedium),
                  hintText: label,
                  hintStyle: GoogleFonts.inter(fontSize: 15, color: AppTheme.textDark, fontWeight: FontWeight.bold),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                ),
                style: GoogleFonts.inter(fontSize: 15, color: AppTheme.textDark, fontWeight: FontWeight.bold),
                validator: validator,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFE9F0E6),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.edit_outlined, size: 18, color: AppTheme.textDark),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final villageState = ref.watch(villageControllerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F4), // Background dari mockup
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header Area
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Profil Desa',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Konfigurasi parameter desa untuk analisis dan perencanaan yang lebih tepat',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: AppTheme.textDark,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          GestureDetector(
                            onTap: () {
                              ref.read(authControllerProvider.notifier).logout();
                              ref.read(villageControllerProvider.notifier).clear();
                              ref.read(assessmentControllerProvider.notifier).clear();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE3EED0),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  const Icon(Icons.logout, size: 24, color: Colors.black),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Keluar',
                                    style: GoogleFonts.inter(fontSize: 10, color: Colors.black, fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Header Image
                    Image.asset(
                      'assets/images/profile_background.png',
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const SizedBox(height: 160),
                    ),
                    const SizedBox(height: 16),

                    // Form
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            _buildTextField(
                              controller: _nameController,
                              title: 'Nama Desa',
                              label: 'Masukkan nama desa',
                              icon: Icons.home_outlined,
                              validator: (val) => val == null || val.isEmpty ? 'Wajib diisi' : null,
                            ),
                            _buildTextField(
                              controller: _districtController,
                              title: 'Nama Kecamatan',
                              label: 'SukaMaju',
                              icon: Icons.home_outlined,
                            ),
                            _buildTextField(
                              controller: _cityController,
                              title: 'Nama Kabupaten/Kota',
                              label: 'Jaya',
                              icon: Icons.home_outlined,
                            ),
                            _buildTextField(
                              controller: _areaController,
                              title: 'Luas Wilayah (Km²)',
                              label: '3500.0',
                              icon: Icons.zoom_in_map_outlined,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              validator: (val) {
                                if (val == null || val.isEmpty) return 'Wajib diisi';
                                if (double.tryParse(val) == null) return 'Angka tidak valid';
                                return null;
                              },
                            ),
                            _buildTextField(
                              controller: _populationController,
                              title: 'Jumlah Penduduk (Jiwa)',
                              label: '5000',
                              icon: Icons.people_outline,
                              keyboardType: TextInputType.number,
                              validator: (val) {
                                if (val == null || val.isEmpty) return 'Wajib diisi';
                                if (int.tryParse(val) == null) return 'Angka tidak valid';
                                return null;
                              },
                            ),
                            _buildTextField(
                              controller: _potentialController,
                              title: 'Potensi Desa',
                              label: 'Masukkan potensi desa',
                              icon: Icons.water_drop_outlined,
                            ),

                            const SizedBox(height: 16),
                            if (villageState.errorMessage != null) ...[
                              Text(
                                villageState.errorMessage!,
                                style: const TextStyle(color: AppTheme.poorColor),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                            ],

                            // Save Button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF56804A),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                ),
                                onPressed: villageState.isLoading ? null : _save,
                                child: villageState.isLoading
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      )
                                    : Text(
                                        'Simpan Profil',
                                        style: GoogleFonts.inter(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Bottom Navigation Bar
            if (villageState.activeVillage != null)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
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
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData outline, IconData solid) {
    const int currentNavIndex = 3;
    final isActive = currentNavIndex == index;
    final color = isActive ? const Color(0xFF3E6D4E) : Colors.grey;

    return GestureDetector(
      onTap: () {
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
          // Already here
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: Colors.transparent,
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
