import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/repositories/scenario_repository.dart';
import '../models/scenario_model.dart';

class ScenarioRepositoryImpl implements ScenarioRepository {
  final DioClient _dioClient;

  ScenarioRepositoryImpl(this._dioClient);

  @override
  Future<ScenarioModel> createScenario({
    required String villageId,
    required String scenarioName,
    required List<String> selectedPrograms,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        ApiEndpoints.scenarios,
        data: {
          'villageId': villageId,
          'scenarioName': scenarioName,
          'selectedPrograms': selectedPrograms,
        },
      );
      final data = response.data as Map<String, dynamic>;
      return ScenarioModel.fromJson(data['scenario'] as Map<String, dynamic>);
    } on DioException catch (e) {
      final message = e.response?.data?['error'] ?? 'Gagal membuat skenario.';
      throw Exception(message);
    } catch (e) {
      throw Exception('Kesalahan tidak terduga saat membuat skenario: $e');
    }
  }

  @override
  Future<List<ScenarioModel>> getScenarios(String villageId) async {
    try {
      final response = await _dioClient.dio.get(
        ApiEndpoints.scenarios,
        queryParameters: {'villageId': villageId},
      );
      final data = response.data as Map<String, dynamic>;
      final list = data['scenarios'] as List;
      return list
          .map((item) => ScenarioModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      final message =
          e.response?.data?['error'] ?? 'Gagal memuat daftar skenario.';
      throw Exception(message);
    } catch (e) {
      throw Exception('Kesalahan tidak terduga saat memuat skenario: $e');
    }
  }

  @override
  Future<String> runScenarioAnalysis(String scenarioId) async {
    try {
      final response = await _dioClient.dio.post(
        ApiEndpoints.runAnalyst(scenarioId),
      );
      final data = response.data as Map<String, dynamic>;
      return data['result'] as String;
    } on DioException catch (e) {
      final message =
          e.response?.data?['error'] ?? 'Gagal menjalankan analisis AI.';
      throw Exception(message);
    } catch (e) {
      throw Exception('Kesalahan tidak terduga saat analisis AI: $e');
    }
  }

  @override
  Future<String> runScenarioBlueprint(String scenarioId) async {
    try {
      final response = await _dioClient.dio.post(
        ApiEndpoints.runBlueprint(scenarioId),
      );
      final data = response.data as Map<String, dynamic>;
      return data['result'] as String;
    } on DioException catch (e) {
      final message =
          e.response?.data?['error'] ?? 'Gagal menyusun cetak biru AI.';
      throw Exception(message);
    } catch (e) {
      throw Exception('Kesalahan tidak terduga saat cetak biru AI: $e');
    }
  }
}

final scenarioRepositoryProvider = Provider<ScenarioRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return ScenarioRepositoryImpl(dioClient);
});
