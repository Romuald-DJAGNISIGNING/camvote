import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/role_theme.dart';
import '../../../core/config/app_config.dart';
import '../data/auth_repository.dart';
import '../data/biometric_login_store.dart';
import '../models/auth_user.dart';
import '../models/auth_session.dart';

enum AuthStatus { unknown, unauthenticated, authenticated }

class AuthState {
  final AuthStatus status;
  final AuthUser? user;
  final String? errorMessage;

  const AuthState({
    required this.status,
    this.user,
    this.errorMessage,
  });

  bool get isAuthenticated => status == AuthStatus.authenticated && user != null;
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return AuthRepository(dio);
});

final biometricLoginStoreProvider =
    Provider<BiometricLoginStore>((ref) => BiometricLoginStore());

final biometricLoginEnabledProvider = FutureProvider<bool>((ref) async {
  final store = ref.read(biometricLoginStoreProvider);
  return store.isEnabled();
});

final biometricLoginProfileProvider =
    FutureProvider<BiometricLoginProfile?>((ref) async {
  final store = ref.read(biometricLoginStoreProvider);
  return store.readProfile();
});

final authControllerProvider =
    AsyncNotifierProvider<AuthController, AuthState>(AuthController.new);

class AuthController extends AsyncNotifier<AuthState> {
  @override
  Future<AuthState> build() async {
    final tokenStore = ref.read(authTokenStoreProvider);
    final access = await tokenStore.readAccessToken();

    if (access == null || access.isEmpty) {
      return const AuthState(status: AuthStatus.unauthenticated);
    }

    try {
      final repo = ref.read(authRepositoryProvider);
      final user = await repo.me();
      ref.read(currentRoleProvider.notifier).setRole(user.role);
      return AuthState(status: AuthStatus.authenticated, user: user);
    } catch (e) {
      await tokenStore.clear();
      return AuthState(status: AuthStatus.unauthenticated, errorMessage: '$e');
    }
  }

  Future<void> login({
    required String identifier,
    required String password,
    required AppRole role,
  }) async {
    if (!AppConfig.hasApiBaseUrl) {
      state = const AsyncData(
        AuthState(
          status: AuthStatus.unauthenticated,
          errorMessage: 'API base URL is not configured.',
        ),
      );
      return;
    }
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(authRepositoryProvider);
      final tokenStore = ref.read(authTokenStoreProvider);

      final AuthSession session = await repo.login(
        identifier: identifier,
        password: password,
        role: role,
      );

      await tokenStore.saveTokens(session.tokens);
      ref.read(currentRoleProvider.notifier).setRole(session.user.role);

      return AuthState(
        status: AuthStatus.authenticated,
        user: session.user,
      );
    });
  }

  Future<void> logout() async {
    final repo = ref.read(authRepositoryProvider);
    final tokenStore = ref.read(authTokenStoreProvider);
    final biometricStore = ref.read(biometricLoginStoreProvider);
    await repo.logout();
    await tokenStore.clear();
    await biometricStore.disable();
    ref.read(currentRoleProvider.notifier).setRole(AppRole.public);
    state = const AsyncData(AuthState(status: AuthStatus.unauthenticated));
  }

  Future<void> requestPasswordReset(String identifier) async {
    final repo = ref.read(authRepositoryProvider);
    await repo.requestPasswordReset(identifier);
  }

  Future<void> deleteAccount() async {
    final repo = ref.read(authRepositoryProvider);
    final tokenStore = ref.read(authTokenStoreProvider);
    final biometricStore = ref.read(biometricLoginStoreProvider);
    await repo.deleteAccount();
    await tokenStore.clear();
    await biometricStore.disable();
    ref.read(currentRoleProvider.notifier).setRole(AppRole.public);
    state = const AsyncData(AuthState(status: AuthStatus.unauthenticated));
  }

  Future<void> enableBiometricLogin() async {
    final auth = state.asData?.value;
    final user = auth?.user;
    if (user == null) return;
    final store = ref.read(biometricLoginStoreProvider);
    await store.enableProfile(
      BiometricLoginProfile(
        userId: user.id,
        displayName: user.fullName,
        role: user.role.apiValue,
      ),
    );
  }

  Future<void> disableBiometricLogin() async {
    final store = ref.read(biometricLoginStoreProvider);
    await store.disable();
  }

  Future<void> biometricLogin() async {
    if (!AppConfig.hasApiBaseUrl) {
      state = const AsyncData(
        AuthState(
          status: AuthStatus.unauthenticated,
          errorMessage: 'API base URL is not configured.',
        ),
      );
      return;
    }

    final tokenStore = ref.read(authTokenStoreProvider);
    final refresh = await tokenStore.readRefreshToken();
    if (refresh == null || refresh.isEmpty) {
      state = const AsyncData(
        AuthState(
          status: AuthStatus.unauthenticated,
          errorMessage: 'Biometric login is not configured on this device.',
        ),
      );
      return;
    }

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(authRepositoryProvider);
      final tokens = await repo.refresh(refresh);
      await tokenStore.saveTokens(tokens);
      final user = await repo.me();
      ref.read(currentRoleProvider.notifier).setRole(user.role);
      return AuthState(status: AuthStatus.authenticated, user: user);
    });
  }
}
