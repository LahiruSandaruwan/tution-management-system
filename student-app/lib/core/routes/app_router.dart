import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/auth/screens/reset_password_screen.dart';
import '../../features/notifications/screens/notifications_screen.dart';
import '../../features/grades/screens/grades_screen.dart';
import '../widgets/main_layout.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isAuthenticated = authState.isAuthenticated;
      final isLoginRoute = state.matchedLocation == '/login';
      final isForgotPasswordRoute = state.matchedLocation == '/forgot-password';
      final isResetPasswordRoute = state.matchedLocation == '/reset-password';
      final isPublicRoute = isLoginRoute || isForgotPasswordRoute || isResetPasswordRoute;

      // Redirect to login if not authenticated and not on a public route
      if (!isAuthenticated && !isPublicRoute) {
        return '/login';
      }

      // Redirect to home if authenticated and on a public route
      if (isAuthenticated && isPublicRoute) {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/reset-password',
        builder: (context, state) {
          final email = state.uri.queryParameters['email'];
          return ResetPasswordScreen(email: email);
        },
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const MainLayout(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/grades',
        builder: (context, state) => const GradesScreen(),
      ),
    ],
  );
});
