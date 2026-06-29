import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/repositories/assessment_repository.dart';
import '../models/assessment_model.dart';

class AssessmentRepositoryImpl implements AssessmentRepository {
  final DioClient _dioClient;

  AssessmentRepositoryImpl(this._dioClient);

  @override
  Future<AssessmentResponseModel> createAssessment({
    required String villageId,
    required int wasteLevel,
    required String wasteManagement,
    required int waterQuality,
    required bool riverContaminated,
    required int greenSpace,
    required int floodRisk,
    required List<String> existingPrograms,
    String? potentialProblem,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        ApiEndpoints.assessments,
        data: {
          'villageId': villageId,
          'wasteLevel': wasteLevel,
          'wasteManagement': wasteManagement,
          'waterQuality': waterQuality,
          'riverContaminated': riverContaminated,
          'greenSpace': greenSpace,
          'floodRisk': floodRisk,
          'existingPrograms': existingPrograms,
          'potentialProblem': potentialProblem,
        },
      );
      final data = response.data as Map<String, dynamic>;
      return AssessmentResponseModel.fromJson(data);
    } on DioException catch (e) {
      final message =
          e.response?.data?['error'] ?? 'Gagal mengirim data asesmen.';
      throw Exception(message);
    } catch (e) {
      throw Exception('Kesalahan tidak terduga saat mengirim asesmen: $e');
    }
  }

  @override
  Future<AssessmentResponseModel?> getLatestAssessment(String villageId) async {
    try {
      final response = await _dioClient.dio.get(
        ApiEndpoints.latestAssessment,
        queryParameters: {'villageId': villageId},
      );
      final data = response.data as Map<String, dynamic>;
      return AssessmentResponseModel.fromJson(data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null;
      }
      final message =
          e.response?.data?['error'] ?? 'Gagal memuat asesmen terbaru.';
      throw Exception(message);
    } catch (e) {
      throw Exception(
        'Kesalahan tidak terduga saat memuat asesmen terbaru: $e',
      );
    }
  }
}

final assessmentRepositoryProvider = Provider<AssessmentRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return AssessmentRepositoryImpl(dioClient);
});
