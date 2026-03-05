import 'package:go_router/go_router.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/home/presentation/home_shell.dart';
import '../../features/ets/presentation/ets_detail_screen.dart';
import '../../features/ets/presentation/favorites_screen.dart';
import '../../features/ets/domain/entities/ets_entity.dart';
import '../../features/admin/presentation/admin_shell.dart';
import '../../features/admin/presentation/manage_ets_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeShell(),
    ),
    GoRoute(
      path: '/ets-detail',
      builder: (context, state) {
        final ets = state.extra as EtsEntity;
        return EtsDetailScreen(ets: ets);
      },
    ),
    GoRoute(
      path: '/favorites',
      builder: (context, state) => const FavoritesScreen(),
    ),
    GoRoute(
      path: '/admin',
      builder: (context, state) => const AdminShell(),
    ),
    GoRoute(
      path: '/manage-ets',
      builder: (context, state) {
        final ets = state.extra as EtsEntity?;
        return ManageEtsScreen(ets: ets);
      },
    ),
  ],
);
