import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class RegisterUsecase {
  final AuthRepository repository;

  const RegisterUsecase(this.repository);

  Future<UserEntity> call({
    required String email,
    required String password,
    required String fullName,
    required String phone,
  }) {
    return repository.register(
      email: email,
      password: password,
      fullName: fullName,
      phone: phone,
    );
  }
}