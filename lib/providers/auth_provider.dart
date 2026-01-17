import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wefam/data/services/auth_service.dart';
import 'package:wefam/data/database/database_helper.dart';
import 'package:wefam/data/models/family.dart' as model;
import 'package:wefam/providers/onboarding_provider.dart';
import 'api_provider.dart';

final databaseHelperProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper.instance;
});

final authServiceProvider = Provider<AuthService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final databaseHelper = ref.watch(databaseHelperProvider);
  final storage = ref.watch(secureStorageProvider);
  return AuthService(apiClient, databaseHelper, storage);
});

final authStateProvider = StateNotifierProvider<AuthNotifier, AsyncValue<model.Family?>>((ref) {
  return AuthNotifier(ref.watch(authServiceProvider), ref);
});

class AuthNotifier extends StateNotifier<AsyncValue<model.Family?>> {
  final AuthService _authService;
  final Ref _ref;

  AuthNotifier(this._authService, this._ref) : super(const AsyncValue.loading()) {
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    try {
      final family = await _authService.checkAuthStatus();
      state = AsyncValue.data(family);
    } catch (e, st) {
      // If there's an error checking auth, treat as not logged in
      state = const AsyncValue.data(null);
    }
  }

  Future<bool> login(String username, String password) async {
    state = const AsyncValue.loading();
    final result = await _authService.login(username, password);
    if (result['success'] == true) {
      state = AsyncValue.data(result['family'] as model.Family);
      return true;
    } else {
      state = AsyncValue.error(result['error'], StackTrace.current);
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    // Reset onboarding so user sees it again after logout
    await _ref.read(onboardingProvider.notifier).resetOnboarding();
    state = const AsyncValue.data(null);
  }
}
