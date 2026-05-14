import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ets_movil/core/error/failures.dart';
import 'package:ets_movil/features/auth/domain/entities/user_entity.dart';
import 'package:ets_movil/features/auth/domain/repositories/auth_repository.dart';
import 'package:ets_movil/features/auth/presentation/providers/auth_provider.dart';

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({this.user});
  final UserEntity? user;
  Object? errorToThrow;

  @override
  Future<UserEntity> login(String email, String password) async {
    if (errorToThrow != null) throw errorToThrow!;
    return user!;
  }

  @override
  Future<void> logout() async {}

  @override
  Future<UserEntity?> getCurrentUser() async => null;
}

ProviderContainer _containerWith(AuthRepository repo) {
  final container = ProviderContainer(
    overrides: [authRepositoryProvider.overrideWithValue(repo)],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  group('AuthNotifier', () {
    test('estado inicial es AsyncData(null)', () async {
      final container = _containerWith(_FakeAuthRepository());
      final initial = await container.read(authProvider.future);
      expect(initial, isNull);
    });

    test('login exitoso emite AsyncData con el UserEntity', () async {
      const user = UserEntity(
        id: '2',
        email: 'student@test.com',
        name: 'Student User',
        role: 'student',
      );
      final container = _containerWith(_FakeAuthRepository(user: user));
      await container.read(authProvider.future);

      await container.read(authProvider.notifier).login('student@test.com', '123456');

      final state = container.read(authProvider);
      expect(state.hasValue, isTrue);
      expect(state.value, isNotNull);
      expect(state.value!.role, 'student');
    });

    test('login con credenciales inválidas emite UnauthorizedFailure', () async {
      final repo = _FakeAuthRepository()
        ..errorToThrow = const UnauthorizedFailure('Credenciales incorrectas');
      final container = _containerWith(repo);
      await container.read(authProvider.future);

      await container.read(authProvider.notifier).login('bad@test.com', 'bad');

      final state = container.read(authProvider);
      expect(state.hasError, isTrue);
      expect(state.error, isA<UnauthorizedFailure>());
    });

    test('login con timeout emite TimeoutFailure', () async {
      final repo = _FakeAuthRepository()
        ..errorToThrow = const TimeoutFailure('timeout');
      final container = _containerWith(repo);
      await container.read(authProvider.future);

      await container.read(authProvider.notifier).login('a@b.com', '123');

      final state = container.read(authProvider);
      expect(state.hasError, isTrue);
      expect(state.error, isA<TimeoutFailure>());
    });

    test('logout deja el estado en AsyncData(null)', () async {
      const user = UserEntity(id: '1', email: 'a@b.com', name: 'A', role: 'admin');
      final container = _containerWith(_FakeAuthRepository(user: user));
      await container.read(authProvider.future);

      await container.read(authProvider.notifier).login('a@b.com', '123');
      expect(container.read(authProvider).value, isNotNull);

      await container.read(authProvider.notifier).logout();
      final state = container.read(authProvider);
      expect(state.hasValue, isTrue);
      expect(state.value, isNull);
    });
  });
}
