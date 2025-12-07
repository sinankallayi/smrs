import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../features/auth/auth_provider.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/dashboard/dashboard_screen.dart';

part 'router.g.dart';

final _key = GlobalKey<NavigatorState>();

@riverpod
GoRouter router(RouterRef ref) {
  final authState = ref.watch(authControllerProvider);

  return GoRouter(
    navigatorKey: _key,
    initialLocation: '/',
    redirect: (context, state) {
      final isLoading = authState.isLoading;
      final hasError = authState.hasError;
      final isAuthenticated = authState.valueOrNull != null;

      final isLogin = state.uri.toString() == '/login';
      final isRegister = state.uri.toString() == '/register';

      if (isLoading || hasError) return null;

      if (!isAuthenticated && !isLogin && !isRegister) {
        return '/login';
      }

      if (isAuthenticated && (isLogin || isRegister)) {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const DashboardScreen(),
        routes: [
          // Add child routes here later (e.g. settings, requests)
        ],
      ),
    ],
  );
}
