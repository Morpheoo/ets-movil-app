import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<UserEntity> login(String email, String password) async {
    try {
      return await remoteDataSource.login(email, password);
    } on UnauthorizedException {
      throw const UnauthorizedFailure('Credenciales incorrectas. Verifica tu email y contraseña.');
    } on NetworkException {
      throw const NetworkFailure('Sin conexión a internet. Verifica tu red e intenta de nuevo.');
    } on RequestTimeoutException {
      throw const TimeoutFailure('La solicitud tardó demasiado. Intenta de nuevo.');
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  @override
  Future<void> logout() async {
    // Sin estado de sesión remota por ahora — limpiar datos locales si aplica.
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    return null;
  }
}
