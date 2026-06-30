import '../../data/models/user_model.dart';

abstract class AuthRepository {
  Future<UserModel> login(String email, String password);
  Future<UserModel> register(String email, String password);
  Future<UserModel> loginWithGoogle(String email, String displayName, String googleId);
  Future<void> logout();
  Future<UserModel?> getCachedUser();
}
