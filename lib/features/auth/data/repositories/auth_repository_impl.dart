import '../../../../core/errors/app_exception.dart';
import '../../../../core/services/local_storage_service.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/user_profile_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final LocalStorageService localStorageService;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localStorageService,
  });

  @override
  Future<UserProfileEntity> login({
    required String email,
    required String password,
  }) async {
    try {
      final model = await remoteDataSource.loginWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Cache user details locally
      await localStorageService.saveCachedUser(userId: model.id, name: model.name);
      await localStorageService.saveThemeMode(model.themeMode);

      return model;
    } on AppException {
      rethrow;
    } catch (e) {
      throw ServerException(message: 'Failed to complete login: $e');
    }
  }

  @override
  Future<UserProfileEntity> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final model = await remoteDataSource.registerWithEmailAndPassword(
        name: name,
        email: email,
        password: password,
      );

      // Cache user details locally
      await localStorageService.saveCachedUser(userId: model.id, name: model.name);
      await localStorageService.saveThemeMode(model.themeMode);

      return model;
    } on AppException {
      rethrow;
    } catch (e) {
      throw ServerException(message: 'Failed to complete registration: $e');
    }
  }

  @override
  Future<UserProfileEntity?> getCurrentUser() async {
    try {
      final model = await remoteDataSource.getCurrentUserProfile();
      if (model != null) {
        await localStorageService.saveCachedUser(userId: model.id, name: model.name);
        await localStorageService.saveThemeMode(model.themeMode);
      }
      return model;
    } catch (_) {
      // Fallback: check local storage cached user
      final cachedId = localStorageService.getCachedUserId();
      final cachedName = localStorageService.getCachedUserName();
      if (cachedId != null && cachedName != null) {
        return UserProfileEntity(
          id: cachedId,
          name: cachedName,
          email: '',
          createdAt: DateTime.now(),
        );
      }
      return null;
    }
  }

  @override
  Future<UserProfileEntity> getUserProfile(String userId) async {
    try {
      final model = await remoteDataSource.getUserProfile(userId);
      await localStorageService.saveCachedUser(userId: model.id, name: model.name);
      await localStorageService.saveThemeMode(model.themeMode);
      return model;
    } on AppException {
      rethrow;
    } catch (e) {
      throw ServerException(message: 'Failed to fetch user profile: $e');
    }
  }

  @override
  Future<UserProfileEntity> updateUserProfile(UserProfileEntity profile) async {
    try {
      final model = UserProfileModel.fromEntity(profile);
      final updatedModel = await remoteDataSource.updateUserProfile(model);

      await localStorageService.saveCachedUser(userId: updatedModel.id, name: updatedModel.name);
      await localStorageService.saveThemeMode(updatedModel.themeMode);

      return updatedModel;
    } on AppException {
      rethrow;
    } catch (e) {
      throw ServerException(message: 'Failed to update user profile: $e');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await remoteDataSource.logout();
      await localStorageService.clearUserCache();
    } on AppException {
      rethrow;
    } catch (e) {
      throw ServerException(message: 'Failed to logout: $e');
    }
  }
}
