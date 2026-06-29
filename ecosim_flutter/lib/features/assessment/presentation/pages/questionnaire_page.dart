import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../village/presentation/controllers/village_controller.dart';
import '../controllers/assessment_controller.dart';

class QuestionnairePage extends ConsumerStatefulWidget {
  const QuestionnairePage({super.key});

  @override
  ConsumerState<QuestionnairePage> createState() => _QuestionnairePageState();
}

class _QuestionnairePageState extends ConsumerState<QuestionnairePage> {
  final _formKey = GlobalKey<FormState>();

  String? _wasteManagement;
  int? _wasteLevel;
  int? _waterQuality;
  bool? _riverContaminated;
  int? _greenSpace;
  int? _floodRisk;

  final TextEditingController _potentialController = TextEditingController();

  @override
  void dispose() {
    _potentialController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_wasteManagement == null ||
        _wasteLevel == null ||
        _waterQuality == null ||
        _riverContaminated == null ||
        _greenSpace == null ||
        _floodRisk == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap jawab semua pertanyaan asesmen!')),
      );
      return;
    }

    final village = ref.read(villageControllerProvider).activeVillage;
    if (village == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profil desa belum diset!')));
      context.go('/village-profile');
      return;
    }

    final success = await ref
        .read(assessmentControllerProvider.notifier)
        .submitAssessment(
          villageId: village.id,
          wasteLevel: _wasteLevel!,
          wasteManagement: _wasteManagement!,
          waterQuality: _waterQuality!,
          riverContaminated: _riverContaminated!,
          greenSpace: _greenSpace!,
          floodRisk: _floodRisk!,
          existingPrograms: [],
          potentialProblem: _potentialController.text.trim(),
        );

    if (success && mounted) {
      context.go('/dna-result');
    }
  }

  Widget _buildSectionCard({
    required int number,
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AppTheme.primaryColor, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '$number. $title',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSubtext(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Text(
        text,
        style: GoogleFonts.inter(fontSize: 12, color: Colors.black54),
      ),
    );
  }

  Widget _buildOptionButton<T>({
    required String text,
    required T value,
    required T? groupValue,
    required ValueChanged<T?> onChanged,
  }) {
    final isSelected = value == groupValue;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? AppTheme.primaryColor.withValues(alpha: 0.05)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color:
                isSelected
                    ? AppTheme.primaryColor
                    : Colors.grey.withValues(alpha: 0.3),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 13,
            color: isSelected ? AppTheme.primaryColor : Colors.black87,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  String? _selectedRiverContaminatedLabel;
  Widget _buildRiverOptionButton({required String text, required bool value}) {
    final isSelected = _selectedRiverContaminatedLabel == text;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRiverContaminatedLabel = text;
          _riverContaminated = value;
        });
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? AppTheme.primaryColor.withValues(alpha: 0.05)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color:
                isSelected
                    ? AppTheme.primaryColor
                    : Colors.grey.withValues(alpha: 0.3),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 13,
            color: isSelected ? AppTheme.primaryColor : Colors.black87,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final assessmentState = ref.watch(assessmentControllerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F4),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.black87),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Asesmen Lingkungan',
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Jawab beberapa pertanyaan untuk membantu kami memahami kondisi desa anda',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.black54,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),

                _buildSectionCard(
                  number: 1,
                  title: 'Manajemen Sampah',
                  icon: Icons.restore_from_trash_outlined,
                  children: [
                    _buildSubtext(
                      'Bagaimana sistem pengelolaan sampah di desa anda?',
                    ),
                    _buildOptionButton<String>(
                      text: 'Tidak Ada / Dibakar / Dibuang Sembarangan',
                      value: 'none',
                      groupValue: _wasteManagement,
                      onChanged:
                          (val) => setState(() => _wasteManagement = val),
                    ),
                    _buildOptionButton<String>(
                      text: 'TPS Terdekat (Tempat Pembuangan Sementara)',
                      value: 'tps',
                      groupValue: _wasteManagement,
                      onChanged:
                          (val) => setState(() => _wasteManagement = val),
                    ),
                    _buildOptionButton<String>(
                      text: 'Sistem Komposter Rumah Tangga / Komunal',
                      value: 'komposter',
                      groupValue: _wasteManagement,
                      onChanged:
                          (val) => setState(() => _wasteManagement = val),
                    ),
                    _buildOptionButton<String>(
                      text: 'Bank Sampah Komunitas',
                      value: 'bank_sampah',
                      groupValue: _wasteManagement,
                      onChanged:
                          (val) => setState(() => _wasteManagement = val),
                    ),
                    const SizedBox(height: 8),
                    _buildSubtext(
                      'Kondisi sampah tidak terkelola (Timbulan sampah liar)',
                    ),
                    _buildOptionButton<int>(
                      text: 'Rendah (Hampir tidak ada sampah liar berserakan)',
                      value: 1,
                      groupValue: _wasteLevel,
                      onChanged: (val) => setState(() => _wasteLevel = val),
                    ),
                    _buildOptionButton<int>(
                      text:
                          'Sedang (Ada tumpukan sampah liar di beberapa lokasi)',
                      value: 5,
                      groupValue: _wasteLevel,
                      onChanged: (val) => setState(() => _wasteLevel = val),
                    ),
                    _buildOptionButton<int>(
                      text:
                          'Tinggi (Tumpukan sampah liar berserakan di banyak tempat)',
                      value: 10,
                      groupValue: _wasteLevel,
                      onChanged: (val) => setState(() => _wasteLevel = val),
                    ),
                  ],
                ),

                _buildSectionCard(
                  number: 2,
                  title: 'Kualitas Air & Sanitasi Sungai',
                  icon: Icons.water_drop_outlined,
                  children: [
                    _buildSubtext('Kondisi sumber air bersih utama warga'),
                    _buildOptionButton<int>(
                      text:
                          'Jernih, tidak berwarna, dan tidak berbau sepanjang tahun',
                      value: 10,
                      groupValue: _waterQuality,
                      onChanged: (val) => setState(() => _waterQuality = val),
                    ),
                    _buildOptionButton<int>(
                      text: 'Kadang keruh atau berbau, terutama di musim hujan',
                      value: 5,
                      groupValue: _waterQuality,
                      onChanged: (val) => setState(() => _waterQuality = val),
                    ),
                    _buildOptionButton<int>(
                      text:
                          'Sering keruh, berbau, atau tidak layak digunakan sehari-hari',
                      value: 1,
                      groupValue: _waterQuality,
                      onChanged: (val) => setState(() => _waterQuality = val),
                    ),
                    const SizedBox(height: 8),
                    _buildSubtext('Kondisi sungai terdekat'),
                    _buildRiverOptionButton(
                      text: 'Bersih dan aliran lancar',
                      value: false,
                    ),
                    _buildRiverOptionButton(
                      text: 'Ada sedikit sampah hanyut',
                      value: true,
                    ),
                    _buildRiverOptionButton(
                      text: 'Banyak sampah / limbah',
                      value: true,
                    ),
                  ],
                ),

                _buildSectionCard(
                  number: 3,
                  title: 'Konservasi & Penghijauan',
                  icon: Icons.park_outlined,
                  children: [
                    _buildSubtext('Keberadaan program penghijauan desa'),
                    _buildOptionButton<int>(
                      text: 'Tidak ada (Belum pernah ada program penghijauan)',
                      value: 0,
                      groupValue: _greenSpace,
                      onChanged: (val) => setState(() => _greenSpace = val),
                    ),
                    _buildOptionButton<int>(
                      text: 'Terbatas (Penghijauan hanya di area terbatas)',
                      value: 5,
                      groupValue: _greenSpace,
                      onChanged: (val) => setState(() => _greenSpace = val),
                    ),
                    _buildOptionButton<int>(
                      text:
                          'Aktif dan Rutin (Penghijauan berkala di seluruh wilayah desa)',
                      value: 10,
                      groupValue: _greenSpace,
                      onChanged: (val) => setState(() => _greenSpace = val),
                    ),
                  ],
                ),

                _buildSectionCard(
                  number: 4,
                  title: 'Ketahanan Risiko Bencana',
                  icon: Icons.shield_outlined,
                  children: [
                    _buildSubtext('Frekuensi kejadian banjir di lingkungan'),
                    _buildOptionButton<int>(
                      text: 'Tidak Pernah (Desa aman dan bebas banjir)',
                      value: 1,
                      groupValue: _floodRisk,
                      onChanged: (val) => setState(() => _floodRisk = val),
                    ),
                    _buildOptionButton<int>(
                      text: 'Jarang (1-2 kali kejadian pertahun)',
                      value: 5,
                      groupValue: _floodRisk,
                      onChanged: (val) => setState(() => _floodRisk = val),
                    ),
                    _buildOptionButton<int>(
                      text: 'Sering (Lebih dari 2 kali kejadian pertahun)',
                      value: 10,
                      groupValue: _floodRisk,
                      onChanged: (val) => setState(() => _floodRisk = val),
                    ),
                  ],
                ),

                _buildSectionCard(
                  number: 5,
                  title: 'Potensi Desa',
                  icon: Icons.groups_outlined,
                  children: [
                    _buildSubtext(
                      'Jelaskan permasalahan potensi yang desa anda miliki',
                    ),
                    TextFormField(
                      controller: _potentialController,
                      maxLines: 4,
                      minLines: 2,
                      decoration: InputDecoration(
                        hintText: 'Ketik Disini...',
                        hintStyle: GoogleFonts.inter(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                        contentPadding: const EdgeInsets.all(16),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFF7CD28E),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: AppTheme.primaryColor,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                if (assessmentState.errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.poorColor.withValues(alpha: 0.1),
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

                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: assessmentState.isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child:
                        assessmentState.isLoading
                            ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                            : Text(
                              'Simpan & Analisis DNA Desa',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
