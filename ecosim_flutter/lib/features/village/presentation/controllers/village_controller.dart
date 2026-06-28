import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/village_model.dart';
import '../../domain/repositories/village_repository.dart';
import '../../data/repositories/village_repository_impl.dart';

class VillageState {
  final VillageModel? activeVillage;
  final bool isLoading;
  final String? errorMessage;
  final bool isInitialized;

  VillageState({
    this.activeVillage,
    this.isLoading = false,
    this.errorMessage,
    this.isInitialized = false,
  });

  VillageState copyWith({
    VillageModel? activeVillage,
    bool? isLoading,
    String? errorMessage,
    bool? isInitialized,
    bool clearVillage = false,
  }) {
    return VillageState(
      activeVillage: clearVillage ? null : (activeVillage ?? this.activeVillage),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }
}

class VillageNotifier extends StateNotifier<VillageState> {
  final VillageRepository _villageRepository;

  VillageNotifier(this._villageRepository) : super(VillageState()) {
    loadActiveVillage();
  }

  Future<void> loadActiveVillage() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token == null) {
      // Not logged in yet, so do not perform the API call to avoid 401 errors
      state = state.copyWith(isLoading: false, isInitialized: true, errorMessage: null);
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final village = await _villageRepository.getActiveVillage();
      state = state.copyWith(activeVillage: village, isLoading: false, isInitialized: true);
    } catch (e) {
      final errStr = e.toString().replaceAll('Exception: ', '');
      state = state.copyWith(
        isLoading: false,
        isInitialized: true,
        errorMessage: errStr.contains('belum dikonfigurasi') ? null : errStr,
      );
    }
  }

  Future<bool> saveProfile({
    required String villageName,
    required int population,
    required double areaKm2,
    String? districtName,
    String? cityName,
    String? potential,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final village = await _villageRepository.createOrUpdateVillage(
        villageName: villageName,
        population: population,
        areaKm2: areaKm2,
        districtName: districtName,
        cityName: cityName,
        potential: potential,
      );
      state = state.copyWith(activeVillage: village, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  void clear() {
    state = VillageState(isInitialized: true);
  }
}

// Provider
final villageControllerProvider = StateNotifierProvider<VillageNotifier, VillageState>((ref) {
  final repository = ref.watch(villageRepositoryProvider);
  return VillageNotifier(repository);
});
