import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource datasource;

  AuthRepositoryImpl(this.datasource);

  @override
  Future<UserEntity> login({
    required String email,
    required String password,
  }) =>
      datasource.login(email: email, password: password);

  @override
  Future<UserEntity> register({
    required String email,
    required String password,
    required String fullName,
    required String phone,
  }) =>
      datasource.register(
        email: email,
        password: password,
        fullName: fullName,
        phone: phone,
      );

  @override
  Future<void> signOut() => datasource.signOut();

  @override
  UserEntity? getCurrentUser() => datasource.getCurrentUser();
}