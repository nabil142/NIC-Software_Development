import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/repositories/auth_repository.dart';
import '../data_sources/auth_remote_data_source.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl(this._remoteDataSource);

  @override
  Future<UserModel> login(String email, String password) async {
    final result = await _remoteDataSource.login(email, password);
    final user = result['user'] as UserModel;
    final token = result['token'] as String;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    await prefs.setString('user_id', user.id);
    await prefs.setString('user_email', user.email);

    return user;
  }

  @override
  Future<UserModel> loginWithGoogle(String email, String displayName, String googleId) async {
    final result = await _remoteDataSource.loginWithGoogle(email, displayName, googleId);
    final user = result['user'] as UserModel;
    final token = result['token'] as String;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    await prefs.setString('user_id', user.id);
    await prefs.setString('user_email', user.email);

    return user;
  }

  @override
  Future<UserModel> loginWithApple(String email, String displayName, String appleId) async {
    final result = await _remoteDataSource.loginWithApple(email, displayName, appleId);
    final user = result['user'] as UserModel;
    final token = result['token'] as String;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    await prefs.setString('user_id', user.id);
    await prefs.setString('user_email', user.email);

    return user;
  }

  @override
  Future<UserModel> register(String email, String password) async {
    final result = await _remoteDataSource.register(email, password);
    final user = result['user'] as UserModel;
    final token = result['token'] as String;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    await prefs.setString('user_id', user.id);
    await prefs.setString('user_email', user.email);

    return user;
  }

  @override
  Future<void> deleteAccount() async {
    await _remoteDataSource.deleteAccount();
    await logout();
  }

  @override
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_id');
    await prefs.remove('user_email');
  }

  @override
  Future<UserModel?> getCachedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final id = prefs.getString('user_id');
    final email = prefs.getString('user_email');

    if (token != null && id != null && email != null) {
      return UserModel(id: id, email: email);
    }
    return null;
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final remoteDataSource = ref.watch(authRemoteDataSourceProvider);
  return AuthRepositoryImpl(remoteDataSource);
});
