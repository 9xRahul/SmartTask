import '../entities/user_profile_entity.dart';
import '../repositories/auth_repository.dart';

class GetCurrentUserUseCase {
  final AuthRepository repository;

  GetCurrentUserUseCase({required this.repository});

  Future<UserProfileEntity?> call() async {
    return await repository.getCurrentUser();
  }
}
