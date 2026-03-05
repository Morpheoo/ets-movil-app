import '../../domain/entities/user_entity.dart';

abstract class AuthRemoteDataSource {
  Future<UserEntity> login(String email, String password);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  @override
  Future<UserEntity> login(String email, String password) async {
    // Mock implementation
    await Future.delayed(const Duration(seconds: 1));
    if (email == 'admin@test.com' && password == '123456') {
      return const UserEntity(
        id: '1',
        email: 'admin@test.com',
        name: 'Admin User',
        role: 'admin',
      );
    } else if (email == 'student@test.com' && password == '123456') {
      return const UserEntity(
        id: '2',
        email: 'student@test.com',
        name: 'Student User',
        role: 'student',
      );
    } else {
      throw Exception('Invalid credentials');
    }
  }
}
