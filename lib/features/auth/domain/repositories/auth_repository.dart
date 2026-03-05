
import '../entities/user_entity.dart';

// Actually, since I didn't add dartz to pubspec, I should probably add it or use a simple class.
// For now, let's assume I'll add dartz or use a simple sealed class. 
// I'll add dartz to pubspec later if needed, but for now I'll use a specific return type or Future<UserEntity> and throw exceptions caught by repository.
// Wait, clean architecture usually uses Either.
// Let's us a simple Record for now (Dart 3) or just Future<UserEntity> and custom Result class.
// I'll use a custom Result type alias for simplicity if I don't have dartz.
// But let's verify if I added dartz. No I didn't.
// I'll Implement a simple Result class in core.

abstract class AuthRepository {
  Future<UserEntity> login(String email, String password);
  Future<void> logout();
  Future<UserEntity?> getCurrentUser();
}
