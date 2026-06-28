import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../features/auth/presentation/controllers/auth_controller.dart';
import '../controllers/village_controller.dart';
import '../../../assessment/presentation/controllers/assessment_controller.dart';

class VillageProfilePage extends ConsumerStatefulWidget {
  const VillageProfilePage({super.key});

  @override
  ConsumerState<VillageProfilePage> createState() => _VillageProfilePageState();
}

class _VillageProfilePageState extends ConsumerState<VillageProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _populationController = TextEditingController();
  final _areaController = TextEditingController();
  final _agriAreaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Prepopulate form if profile already exists
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final village = ref.read(villageControllerProvider).activeVillage;
      if (village != null) {
        _nameController.text = village.villageName;
        _populationController.text = village.population.toString();
        _areaController.text = village.areaKm2.toString();
        _agriAreaController.text = village.agriculturalAreaKm2.toString();
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _populationController.dispose();
    _areaController.dispose();
    _agriAreaController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(villageControllerProvider.notifier).saveProfile(
      villageName: _nameController.text.trim(),
      population: int.parse(_populationController.text.trim()),
      areaKm2: double.parse(_areaController.text.trim()),
      agriculturalAreaKm2: double.parse(_agriAreaController.text.trim()),
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil desa berhasil disimpan!'),
          backgroundColor: AppTheme.excellentColor,
        ),
      );
      // Route onwards to the assessment questionnaire page
      context.go('/assessment');
    }
  }

  @override
  Widget build(BuildContext context) {
    final villageState = ref.watch(villageControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Geografis Desa'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authControllerProvider.notifier).logout();
              ref.read(villageControllerProvider.notifier).clear();
              ref.read(assessmentControllerProvider.notifier).clear();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Konfigurasi Parameter Desa',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Parameter ini digunakan oleh AI EcoSim untuk menghitung kebutuhan anggaran kerja, kelayakan program, dan memproyeksikan kapasitas adaptasi lingkungan secara spesifik.',
                    style: TextStyle(color: AppTheme.textMedium, height: 1.4),
                  ),
                  const SizedBox(height: 30),

                  // Form
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              children: [
                                // Name
                                TextFormField(
                                  controller: _nameController,
                                  decoration: const InputDecoration(
                                    labelText: 'Nama Desa',
                                    prefixIcon: Icon(Icons.home_outlined),
                                  ),
                                  validator: (val) {
                                    if (val == null || val.isEmpty) {
                                      return 'Nama desa wajib diisi.';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),

                                // Population
                                TextFormField(
                                  controller: _populationController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'Jumlah Penduduk (Jiwa)',
                                    prefixIcon: Icon(Icons.people_outline),
                                  ),
                                  validator: (val) {
                                    if (val == null || val.isEmpty) {
                                      return 'Jumlah penduduk wajib diisi.';
                                    }
                                    if (int.tryParse(val) == null) {
                                      return 'Masukkan angka bulat positif.';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),

                                // Total Area
                                TextFormField(
                                  controller: _areaController,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  decoration: const InputDecoration(
                                    labelText: 'Luas Wilayah (Km²)',
                                    prefixIcon: Icon(Icons.map_outlined),
                                  ),
                                  validator: (val) {
                                    if (val == null || val.isEmpty) {
                                      return 'Luas wilayah wajib diisi.';
                                    }
                                    if (double.tryParse(val) == null) {
                                      return 'Masukkan angka desimal yang valid.';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),

                                // Agricultural Area
                                TextFormField(
                                  controller: _agriAreaController,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  decoration: const InputDecoration(
                                    labelText: 'Luas Pertanian/Sawah (Km²)',
                                    prefixIcon: Icon(Icons.agriculture_outlined),
                                  ),
                                  validator: (val) {
                                    if (val == null || val.isEmpty) {
                                      return 'Luas sawah wajib diisi.';
                                    }
                                    final doubleVal = double.tryParse(val);
                                    if (doubleVal == null) {
                                      return 'Masukkan angka desimal yang valid.';
                                    }
                                    final areaVal = double.tryParse(_areaController.text);
                                    if (areaVal != null && doubleVal > areaVal) {
                                      return 'Luas sawah tidak boleh melebihi luas wilayah.';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),

                        if (villageState.errorMessage != null) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.poorColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              villageState.errorMessage!,
                              style: const TextStyle(color: AppTheme.poorColor),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],

                        ElevatedButton(
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
                              : const Text('Simpan & Lanjutkan'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Bottom Navigation Bar matching design style (only visible if profile exists)
          if (villageState.activeVillage != null)
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
    );
  }

  Widget _buildNavItem(int index, IconData outline, IconData solid) {
    const int currentNavIndex = 3; // Active on Profile/Settings (Person icon)
    final isActive = currentNavIndex == index;
    final color = isActive ? const Color(0xFF3E6D4E) : Colors.grey;

    return GestureDetector(
      onTap: () {
        if (index == 0) {
          context.go('/scenarios');
        } else if (index == 1) {
          context.go('/future-builder');
        } else if (index == 2) {
          context.go('/policy-analyst');
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
