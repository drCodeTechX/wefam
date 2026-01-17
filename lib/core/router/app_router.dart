import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wefam/providers/auth_provider.dart';
import 'package:wefam/providers/onboarding_provider.dart';
import 'package:wefam/features/auth/presentation/login_screen.dart';
import 'package:wefam/features/onboarding/presentation/onboarding_screen.dart';
import 'package:wefam/features/dashboard/presentation/dashboard_screen.dart';
import 'package:wefam/core/router/scaffold_with_nav_bar.dart';
import 'package:wefam/features/profile/presentation/profile_screen.dart';
import 'package:wefam/core/theme/colors.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final onboardingState = ref.watch(onboardingProvider);
  final rootNavigatorKey = GlobalKey<NavigatorState>();

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',
    refreshListenable: ValueNotifier(authState),
    redirect: (context, state) {
      final isLoggedIn = authState.asData?.value != null;
      final hasSeenOnboarding = onboardingState.asData?.value ?? false;
      final isAuthLoading = authState is AsyncLoading;
      final isOnboardingLoading = onboardingState is AsyncLoading;

      final currentPath = state.uri.toString();
      final isOnOnboarding = currentPath == '/onboarding';
      final isOnLogin = currentPath == '/login';
      final isOnSplash = currentPath == '/splash';

      // Still loading - show splash
      if (isAuthLoading || isOnboardingLoading) {
        if (!isOnSplash) return '/splash';
        return null;
      }

      // Not seen onboarding yet - show onboarding
      if (!hasSeenOnboarding) {
        if (!isOnOnboarding) return '/onboarding';
        return null;
      }

      // Seen onboarding but not logged in - show login
      if (!isLoggedIn) {
        if (!isOnLogin) return '/login';
        return null;
      }

      // Logged in - go to home if on auth pages
      if (isOnOnboarding || isOnLogin || isOnSplash) {
        return '/';
      }

      return null;
    },
    routes: [
      // Splash/loading screen
      GoRoute(
        path: '/splash',
        builder: (context, state) => const _SplashScreen(),
      ),
      // Onboarding route
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      // Login route
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      // Main app routes with bottom navigation
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

/// Simple splash screen shown while loading auth/onboarding state
class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(
                Icons.family_restroom,
                size: 50,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'WeFam',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
