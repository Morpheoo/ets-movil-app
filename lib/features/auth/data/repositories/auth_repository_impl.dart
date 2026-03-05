
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<UserEntity> login(String email, String password) async {
    try {
      return await remoteDataSource.login(email, password);
    } catch (e) {
      throw Exception(e.toString()); // Simple error handling for now
    }
  }

  @override
  Future<void> logout() async {
    // Clear local storage if needed
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    // Start with null for mock
    return null;
  }
}
