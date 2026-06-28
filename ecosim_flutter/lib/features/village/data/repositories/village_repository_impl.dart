import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/repositories/village_repository.dart';
import '../models/village_model.dart';

class VillageRepositoryImpl implements VillageRepository {
  final DioClient _dioClient;

  VillageRepositoryImpl(this._dioClient);

  @override
  Future<VillageModel> createOrUpdateVillage({
    required String villageName,
    required int population,
    required double areaKm2,
    String? districtName,
    String? cityName,
    String? potential,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        ApiEndpoints.villages,
        data: {
          'villageName': villageName,
          'population': population,
          'areaKm2': areaKm2,
          'districtName': districtName,
          'cityName': cityName,
          'potential': potential,
        },
      );
      final data = response.data as Map<String, dynamic>;
      return VillageModel.fromJson(data['village'] as Map<String, dynamic>);
    } on DioException catch (e) {
      final message = e.response?.data?['error'] ?? 'Gagal menyimpan profil desa.';
      throw Exception(message);
    } catch (e) {
      throw Exception('Kesalahan tidak terduga saat menyimpan profil desa: $e');
    }
  }

  @override
  Future<VillageModel?> getActiveVillage() async {
    try {
      final response = await _dioClient.dio.get(ApiEndpoints.activeVillage);
      final data = response.data as Map<String, dynamic>;
      if (data['village'] == null) return null;
      return VillageModel.fromJson(data['village'] as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null; // Profile not configured yet
      }
      final message = e.response?.data?['error'] ?? 'Gagal memuat profil desa.';
      throw Exception(message);
    } catch (e) {
      throw Exception('Kesalahan tidak terduga saat memuat profil desa: $e');
    }
  }
}

// Provider
final villageRepositoryProvider = Provider<VillageRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return VillageRepositoryImpl(dioClient);
});
