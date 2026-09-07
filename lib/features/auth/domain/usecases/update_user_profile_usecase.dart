import '../entities/user_profile_entity.dart';
import '../repositories/auth_repository.dart';

class UpdateUserProfileUseCase {
  final AuthRepository repository;

  UpdateUserProfileUseCase({required this.repository});

  Future<UserProfileEntity> call(UserProfileEntity profile) async {
    return await repository.updateUserProfile(profile);
  }
}
