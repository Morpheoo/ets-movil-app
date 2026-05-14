import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:ets_movil/core/config/app_theme.dart';
import 'package:ets_movil/features/auth/domain/entities/user_entity.dart';
import 'package:ets_movil/features/auth/domain/repositories/auth_repository.dart';
import 'package:ets_movil/features/auth/presentation/login_screen.dart';
import 'package:ets_movil/features/auth/presentation/providers/auth_provider.dart';

class _FakeAuthRepository implements AuthRepository {
  @override
  Future<UserEntity> login(String email, String password) async =>
      const UserEntity(id: '1', email: 'a@b.com', name: 'A', role: 'student');

  @override
  Future<void> logout() async {}

  @override
  Future<UserEntity?> getCurrentUser() async => null;
}

void main() {
  testWidgets('LoginScreen renderiza inputs y botón de Login', (tester) async {
    final router = GoRouter(
      initialLocation: '/login',
      routes: [
        GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
        GoRoute(path: '/home', builder: (_, __) => const Scaffold()),
        GoRoute(path: '/admin', builder: (_, __) => const Scaffold()),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(_FakeAuthRepository()),
        ],
        child: MaterialApp.router(
          theme: AppTheme.lightTheme,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('ESCOM'), findsOneWidget);
    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
  });
}
