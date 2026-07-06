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
        data: {'email': email, 'password': password},
      );

      final data = response.data as Map<String, dynamic>;
      final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
      final token = data['token'] as String;

      return {'user': user, 'token': token};
    } on DioException catch (e) {
      final message =
          e.response?.data?['error'] ??
          e.message ??
          'Gagal masuk sistem. Silakan periksa kredensial Anda.';
      throw Exception(message);
    } catch (e) {
      throw Exception(
        'Terjadi kesalahan tidak terduga saat masuk sistem. Silakan coba lagi nanti.',
      );
    }
  }

  Future<Map<String, dynamic>> register(String email, String password) async {
    try {
      final response = await _dioClient.dio.post(
        ApiEndpoints.register,
        data: {'email': email, 'password': password},
      );

      final data = response.data as Map<String, dynamic>;
      final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
      final token = data['token'] as String;

      return {'user': user, 'token': token};
    } on DioException catch (e) {
      final message =
          e.response?.data?['error'] ??
          e.message ??
          'Gagal mendaftarkan akun. Silakan periksa kembali data Anda.';
      throw Exception(message);
    } catch (e) {
      throw Exception(
        'Terjadi kesalahan tidak terduga saat registrasi. Silakan coba lagi nanti.',
      );
    }
  }

  Future<Map<String, dynamic>> loginWithGoogle(String email, String displayName, String googleId) async {
    try {
      try {
        final response = await _dioClient.dio.post(
          ApiEndpoints.login,
          data: {'email': email, 'password': 'google_sso_$googleId'},
        );
        final data = response.data as Map<String, dynamic>;
        final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
        final token = data['token'] as String;
        return {'user': user, 'token': token};
      } catch (e) {
        final registerResponse = await _dioClient.dio.post(
          ApiEndpoints.register,
          data: {'email': email, 'password': 'google_sso_$googleId'},
        );
        final data = registerResponse.data as Map<String, dynamic>;
        final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
        final token = data['token'] as String;
        return {'user': user, 'token': token};
      }
    } on DioException catch (e) {
      final message =
          e.response?.data?['error'] ??
          e.message ??
          'Gagal sinkronisasi akun Google. Silakan coba lagi.';
      throw Exception(message);
    } catch (e) {
      throw Exception(
        'Terjadi kesalahan tidak terduga saat Google Sign-In. Silakan coba lagi nanti.',
      );
    }
  }

  Future<Map<String, dynamic>> loginWithApple(String email, String displayName, String appleId) async {
    try {
      // 1. Coba login (jika akun sudah ada)
      try {
        final loginResponse = await _dioClient.dio.post(
          ApiEndpoints.login,
          data: {'email': email, 'password': 'apple_sso_$appleId'},
        );
        final data = loginResponse.data as Map<String, dynamic>;
        final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
        final token = data['token'] as String;
        return {'user': user, 'token': token};
      } on DioException catch (e) {
        // Hanya lanjut ke register jika 401 (belum terdaftar) atau 404
        if (e.response?.statusCode != 401 && e.response?.statusCode != 404) {
          rethrow;
        }
      }

      // 2. Jika belum terdaftar, lakukan register
      final registerResponse = await _dioClient.dio.post(
        ApiEndpoints.register,
        data: {'email': email, 'password': 'apple_sso_$appleId'},
      );
      final data = registerResponse.data as Map<String, dynamic>;
      final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
      final token = data['token'] as String;
      return {'user': user, 'token': token};

    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['error'] ?? 'Gagal sinkronisasi akun Apple. Silakan coba lagi.',
      );
    } catch (e) {
      throw Exception(
        'Terjadi kesalahan tidak terduga saat Apple Sign-In. Silakan coba lagi nanti.',
      );
    }
  }

  Future<void> deleteAccount() async {
    try {
      await _dioClient.dio.delete('/api/auth/account');
    } on DioException catch (e) {
      throw Exception(e.response?.data['error'] ?? 'Gagal menghapus akun.');
    } catch (e) {
      throw Exception('Terjadi kesalahan tidak terduga saat menghapus akun.');
    }
  }
}

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return AuthRemoteDataSource(dioClient);
});
