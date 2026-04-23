import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_error_handler.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/user_entity.dart';
import '../models/user_model.dart';
import 'package:injectable/injectable.dart';

abstract class AuthRemoteDataSource {
  Future<UserEntity> login(String email, String password);
}

// Implementación real: usa Dio + UserModel.fromJson.
// Activar cuando el backend esté disponible (quitar @LazySingleton del Mock).
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient _dioClient;

  AuthRemoteDataSourceImpl(this._dioClient);

  @override
  Future<UserEntity> login(String email, String password) async {
    try {
      final response = await _dioClient.dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      return UserModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }
}

// Implementación mock para desarrollo.
// Los datos pasan por UserModel.fromJson para demostrar la capa de modelo.
@LazySingleton(as: AuthRemoteDataSource)
class AuthRemoteDataSourceMock implements AuthRemoteDataSource {
  @override
  Future<UserEntity> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));

    if (email == 'admin@test.com' && password == '123456') {
      return UserModel.fromJson({
        'id': '1',
        'email': email,
        'name': 'Admin User',
        'role': 'admin',
      });
    }

    if (email == 'student@test.com' && password == '123456') {
      return UserModel.fromJson({
        'id': '2',
        'email': email,
        'name': 'Student User',
        'role': 'student',
      });
    }

    throw const UnauthorizedException();
  }
}
