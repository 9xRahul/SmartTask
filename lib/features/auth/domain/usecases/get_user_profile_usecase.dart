import '../entities/user_profile_entity.dart';
import '../repositories/auth_repository.dart';

class GetUserProfileUseCase {
  final AuthRepository repository;

  GetUserProfileUseCase({required this.repository});

  Future<UserProfileEntity> call(String userId) async {
    return await repository.getUserProfile(userId);
  }
}
