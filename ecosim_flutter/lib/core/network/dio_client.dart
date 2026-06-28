import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_endpoints.dart';

class DioClient {
  final Dio _dio;

  DioClient() : _dio = Dio(
    BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: const Duration(seconds: 30), // 30s to allow Gemini AI processing
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('auth_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          // Handle common HTTP errors or log them
          print('API Error [${e.response?.statusCode}]: ${e.response?.data ?? e.message}');
          return handler.next(e);
        },
      ),
    );
  }

  Dio get dio => _dio;
}

// Provider for DioClient
final dioClientProvider = Provider<DioClient>((ref) {
  return DioClient();
});
