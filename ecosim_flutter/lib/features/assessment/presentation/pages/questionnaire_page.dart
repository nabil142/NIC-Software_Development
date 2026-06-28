import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/knowledge_base.dart';
import '../../../village/presentation/controllers/village_controller.dart';
import '../controllers/assessment_controller.dart';

class QuestionnairePage extends ConsumerStatefulWidget {
  const QuestionnairePage({super.key});

  @override
  ConsumerState<QuestionnairePage> createState() => _QuestionnairePageState();
}

class _QuestionnairePageState extends ConsumerState<QuestionnairePage> {
  final _formKey = GlobalKey<FormState>();

  // Form values
  double _wasteLevel = 5.0;
  String _wasteManagement = 'none';
  double _waterQuality = 5.0;
  bool _riverContaminated = false;
  double _greenSpace = 5.0;
  double _floodRisk = 3.0;
  final List<String> _selectedExistingPrograms = [];

  final List<Map<String, String>> _wasteManagementOptions = [
    {'value': 'none', 'label': 'Tidak ada pengelolaan (Dibuang sembarangan / dibakar)'},
    {'value': 'tps', 'label': 'TPS (Tempat Pembuangan Sementara - diangkut berkala)'},
    {'value': 'bank_sampah', 'label': 'Bank Sampah (Pilah & daur ulang aktif)'},
    {'value': 'komposter', 'label': 'Komposter Rumah Tangga / Kelompok Tani'},
  ];

  Future<void> _submit() async {
    final village = ref.read(villageControllerProvider).activeVillage;
    if (village == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil desa belum diset!')),
      );
      context.go('/village-profile');
      return;
    }

    final success = await ref.read(assessmentControllerProvider.notifier).submitAssessment(
      villageId: village.id,
      wasteLevel: _wasteLevel.round(),
      wasteManagement: _wasteManagement,
      waterQuality: _waterQuality.round(),
      riverContaminated: _riverContaminated,
      greenSpace: _greenSpace.round(),
      floodRisk: _floodRisk.round(),
      existingPrograms: _selectedExistingPrograms,
    );

    if (success && mounted) {
      context.go('/dna-result');
    }
  }

  Widget _buildSliderCard({
    required String title,
    required String subtitle,
    required double value,
    required ValueChanged<double> onChanged,
    required double min,
    required double max,
    required String minLabel,
    required String maxLabel,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text(subtitle, style: const TextStyle(fontSize: 12, color: AppTheme.textLight)),
                    ],
                  ),
                ),
                Text(
                  value.round().toString(),
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Slider(
              value: value,
              min: min,
              max: max,
              divisions: (max - min).round(),
              activeColor: color,
              onChanged: onChanged,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      minLabel,
                      style: const TextStyle(fontSize: 11, color: AppTheme.textLight),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      maxLabel,
                      textAlign: TextAlign.end,
                      style: const TextStyle(fontSize: 11, color: AppTheme.textLight),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final assessmentState = ref.watch(assessmentControllerProvider);
    final village = ref.watch(villageControllerProvider).activeVillage;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Asesmen Lingkungan Desa'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Kuesioner PODES Desa ${village?.villageName ?? ""}',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Jawab pertanyaan kualitatif berikut sesuai kondisi lapangan riil di desa untuk memetakan indikator DNA lingkungan hidup saat ini.',
                style: TextStyle(color: AppTheme.textMedium, height: 1.4),
              ),
              const SizedBox(height: 24),

              // 1. Waste Volume Level
              _buildSliderCard(
                title: 'Volume Sampah Harian',
                subtitle: 'Seberapa besar volume timbulan sampah harian di desa?',
                value: _wasteLevel,
                onChanged: (val) => setState(() => _wasteLevel = val),
                min: 1,
                max: 10,
                minLabel: 'Sangat Sedikit',
                maxLabel: 'Sangat Banyak (Menumpuk)',
                icon: Icons.delete_outline,
                color: AppTheme.poorColor,
              ),
              const SizedBox(height: 16),

              // 2. Waste Management Facilities
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.restore_from_trash_outlined, color: AppTheme.accentColor, size: 28),
                          SizedBox(width: 12),
                          Text(
                            'Fasilitas Pengelolaan Sampah',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Pilih fasilitas pengelolaan sampah utama yang aktif berjalan di desa saat ini:',
                        style: TextStyle(fontSize: 12, color: AppTheme.textLight),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _wasteManagement,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: _wasteManagementOptions.map((opt) {
                          return DropdownMenuItem<String>(
                            value: opt['value'],
                            child: Text(opt['label']!, style: const TextStyle(fontSize: 13)),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _wasteManagement = val);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 3. Water Quality Level
              _buildSliderCard(
                title: 'Kualitas Air Konsumsi',
                subtitle: 'Kondisi air sumur/mata air untuk kebutuhan konsumsi penduduk desa.',
                value: _waterQuality,
                onChanged: (val) => setState(() => _waterQuality = val),
                min: 1,
                max: 10,
                minLabel: 'Keruh/Berbau/Tercemar',
                maxLabel: 'Sangat Jernih & Layak',
                icon: Icons.water_drop_outlined,
                color: AppTheme.goodColor,
              ),
              const SizedBox(height: 16),

              // 4. River contamination
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Icon(Icons.waves, color: Colors.blueAccent, size: 28),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Sungai Desa Tercemar?',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Apakah ada sungai yang melewati desa tersumbat sampah / terkontaminasi?',
                              style: TextStyle(fontSize: 12, color: AppTheme.textLight),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _riverContaminated,
                        activeColor: AppTheme.primaryColor,
                        onChanged: (val) => setState(() => _riverContaminated = val),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 5. Green Space Level
              _buildSliderCard(
                title: 'Luas Ruang Terbuka Hijau',
                subtitle: 'Cakupan area hutan desa, taman, atau daerah reboisasi vegetasi aktif.',
                value: _greenSpace,
                onChanged: (val) => setState(() => _greenSpace = val),
                min: 1,
                max: 10,
                minLabel: 'Gundul/Lahan Kering',
                maxLabel: 'Sangat Rimbun/Banyak Hutan',
                icon: Icons.park_outlined,
                color: AppTheme.excellentColor,
              ),
              const SizedBox(height: 16),

              // 6. Flood Risk Level
              _buildSliderCard(
                title: 'Tingkat Kerawanan Banjir',
                subtitle: 'Seberapa sering terjadi luapan banjir saat curah hujan tinggi?',
                value: _floodRisk,
                onChanged: (val) => setState(() => _floodRisk = val),
                min: 1,
                max: 10,
                minLabel: 'Tidak Pernah Banjir',
                maxLabel: 'Banjir Tahunan Parah',
                icon: Icons.warning_amber_outlined,
                color: AppTheme.fairColor,
              ),
              const SizedBox(height: 16),

              // 7. Existing Programs Checklist
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.assignment_outlined, color: AppTheme.primaryColor, size: 28),
                          SizedBox(width: 12),
                          Text(
                            'Program Kerja Saat Ini',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Pilih program kerja lingkungan yang sudah berjalan aktif di desa Anda saat ini:',
                        style: TextStyle(fontSize: 12, color: AppTheme.textLight),
                      ),
                      const SizedBox(height: 12),
                      ...programsCatalog.map((program) {
                        return CheckboxListTile(
                          title: Text(program.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                          subtitle: Text(program.description, style: const TextStyle(fontSize: 11)),
                          value: _selectedExistingPrograms.contains(program.id),
                          activeColor: AppTheme.primaryColor,
                          dense: true,
                          onChanged: (val) {
                            setState(() {
                              if (val == true) {
                                _selectedExistingPrograms.add(program.id);
                              } else {
                                _selectedExistingPrograms.remove(program.id);
                              }
                            });
                          },
                        );
                      }),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),

              if (assessmentState.errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.poorColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    assessmentState.errorMessage!,
                    style: const TextStyle(color: AppTheme.poorColor),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20),
              ],

              ElevatedButton(
                onPressed: assessmentState.isLoading ? null : _submit,
                child: assessmentState.isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Simpan & Analisis DNA Desa'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
