import '../entities/user_profile_entity.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase({required this.repository});

  Future<UserProfileEntity> call({
    required String name,
    required String email,
    required String password,
  }) async {
    return await repository.register(name: name, email: email, password: password);
  }
}
