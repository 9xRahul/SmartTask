import '../entities/user_profile_entity.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase({required this.repository});

  Future<UserProfileEntity> call({
    required String email,
    required String password,
  }) async {
    return await repository.login(email: email, password: password);
  }
}
