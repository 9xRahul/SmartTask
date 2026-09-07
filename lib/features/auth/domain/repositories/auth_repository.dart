import '../entities/user_profile_entity.dart';

/// Domain contract for authentication and profile management.
abstract class AuthRepository {
  Future<UserProfileEntity> login({
    required String email,
    required String password,
  });

  Future<UserProfileEntity> register({
    required String name,
    required String email,
    required String password,
  });

  Future<UserProfileEntity?> getCurrentUser();

  Future<UserProfileEntity> getUserProfile(String userId);

  Future<UserProfileEntity> updateUserProfile(UserProfileEntity profile);

  Future<void> logout();
}
