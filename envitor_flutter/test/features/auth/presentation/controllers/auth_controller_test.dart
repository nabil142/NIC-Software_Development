import 'package:flutter_test/flutter_test.dart';
import 'package:ecosim_flutter/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ecosim_flutter/features/auth/presentation/controllers/auth_controller.dart';
import 'package:ecosim_flutter/features/auth/domain/repositories/auth_repository.dart';
import 'package:ecosim_flutter/features/auth/data/models/user_model.dart';

class MockAuthRepository implements AuthRepository {
  @override
  Future<UserModel> login(String email, String password) async {
    if (email == 'test@example.com' && password == 'password') {
      return UserModel(id: '1', email: email);
    }
    throw Exception('Invalid credentials');
  }

  @override
  Future<UserModel> register(String email, String password) async {
    return UserModel(id: '2', email: email);
  }


  @override
  Future<UserModel> loginWithApple(String email, String displayName, String appleId) async {
    return UserModel(id: '4', email: email);
  }
  @override
  Future<void> deleteAccount() async {}

  @override
  Future<void> logout() async {}

  @override
  Future<UserModel?> getCachedUser() async {
    return null;
  }
  @override
  Future<UserModel> loginWithGoogle(String email, String displayName, String googleId) async {
    if (email == 'google@example.com') {
      return UserModel(id: googleId, email: email);
    }
    throw Exception('Google Sign-In failed');
  }
}

void main() {
  group('AuthController Tests', () {
    test('Login success updates state to data', () async {
      final mockRepo = MockAuthRepository();
      final container = ProviderContainer(
        overrides: [authRepositoryProvider.overrideWithValue(mockRepo)],
      );

      final controller = container.read(authControllerProvider.notifier);
      await controller.login('test@example.com', 'password');

      final state = container.read(authControllerProvider);
      expect(state.user, isNotNull);
      expect(state.user?.email, 'test@example.com');
    });

    test('Google Login success updates state to data', () async {
      final mockRepo = MockAuthRepository();
      final container = ProviderContainer(
        overrides: [authRepositoryProvider.overrideWithValue(mockRepo)],
      );

      final controller = container.read(authControllerProvider.notifier);
      final success = await controller.loginWithGoogle('google@example.com', 'Google User', 'g123');

      final state = container.read(authControllerProvider);
      expect(success, isTrue);
      expect(state.user, isNotNull);
      expect(state.user?.email, 'google@example.com');
      expect(state.user?.id, 'g123');
    });
  });
}
