import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/user_model.dart';

class AuthRemoteDataSource {
  final DioClient _dioClient;

  AuthRemoteDataSource(this._dioClient);

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dioClient.dio.post(
        ApiEndpoints.login,
        data: {
          'email': email,
          'password': password,
        },
      );
      
      final data = response.data as Map<String, dynamic>;
      final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
      final token = data['token'] as String;

      return {
        'user': user,
        'token': token,
      };
    } on DioException catch (e) {
      final message = e.response?.data?['error'] ?? 'Gagal masuk sistem.';
      throw Exception(message);
    } catch (e) {
      throw Exception('Kesalahan tidak terduga saat masuk sistem: $e');
    }
  }

  Future<Map<String, dynamic>> register(String email, String password) async {
    try {
      final response = await _dioClient.dio.post(
        ApiEndpoints.register,
        data: {
          'email': email,
          'password': password,
        },
      );
      
      final data = response.data as Map<String, dynamic>;
      final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
      final token = data['token'] as String;

      return {
        'user': user,
        'token': token,
      };
    } on DioException catch (e) {
      final message = e.response?.data?['error'] ?? 'Gagal mendaftarkan akun.';
      throw Exception(message);
    } catch (e) {
      throw Exception('Kesalahan tidak terduga saat registrasi: $e');
    }
  }
}

// Provider
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return AuthRemoteDataSource(dioClient);
});
