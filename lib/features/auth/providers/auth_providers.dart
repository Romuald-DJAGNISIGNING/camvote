import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/role_theme.dart';
import '../../../core/network/worker_client.dart';
import '../../../core/firebase/firebase_bootstrap.dart';
import '../../../core/firebase/firebase_auth_scope.dart';
import '../data/auth_repository.dart';
import '../data/biometric_login_store.dart';
import '../models/auth_error_codes.dart';
import '../models/auth_user.dart';
import '../models/auth_session.dart';
import '../utils/auth_error_utils.dart';

enum AuthStatus { unknown, unauthenticated, authenticated }

class AuthState {
  final AuthStatus status;
  final AuthUser? user;
  final String? errorCode;
  final String? errorMessage;

  const AuthState({
    required this.status,
    this.user,
    this.errorCode,
    this.errorMessage,
  });

  bool get isAuthenticated =>
      status == AuthStatus.authenticated && user != null;
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final biometricLoginStoreProvider = Provider<BiometricLoginStore>(
  (ref) => BiometricLoginStore(),
);

final biometricLoginEnabledProvider = FutureProvider<bool>((ref) async {
  final store = ref.read(biometricLoginStoreProvider);
  return store.isEnabled();
});

final biometricLoginProfileProvider = FutureProvider<BiometricLoginProfile?>((
  ref,
) async {
  final store = ref.read(biometricLoginStoreProvider);
  return store.readProfile();
});

final authControllerProvider = AsyncNotifierProvider<AuthController, AuthState>(
  AuthController.new,
);

class AuthController extends AsyncNotifier<AuthState> {
  @override
  Future<AuthState> build() async {
    await ensureFirebaseInitialized();
    if (Firebase.apps.isEmpty) {
      return const AuthState(status: AuthStatus.unauthenticated);
    }
    final auth = _authForScope(resolveWebAuthScope());
    await _ensureWebLocalPersistence(auth);

    final currentUser = auth.currentUser;
    if (currentUser == null) {
      return const AuthState(status: AuthStatus.unauthenticated);
    }

    try {
      final repo = _repoForAuth(auth);
      final user = await repo.me();
      ref.read(currentRoleProvider.notifier).setRole(user.role);
      return AuthState(status: AuthStatus.authenticated, user: user);
    } catch (e) {
      await auth.signOut();
      final code = _resolveErrorCode(e);
      return AuthState(
        status: AuthStatus.unauthenticated,
        errorCode: code,
        errorMessage: _resolveErrorMessage(e, code),
      );
    }
  }

  Future<void> login({
    required String identifier,
    required String password,
    required AppRole role,
  }) async {
    final auth = _authForScope(_scopeForRole(role));
    await _ensureWebLocalPersistence(auth);
    state = const AsyncLoading();
    try {
      final repo = _repoForAuth(auth);
      final AuthSession session = await repo.login(
        identifier: identifier,
        password: password,
        role: role,
      );

      ref.read(currentRoleProvider.notifier).setRole(session.user.role);

      state = AsyncData(
        AuthState(status: AuthStatus.authenticated, user: session.user),
      );
    } catch (e) {
      final code = _resolveErrorCode(e);
      state = AsyncData(
        AuthState(
          status: AuthStatus.unauthenticated,
          errorCode: code,
          errorMessage: _resolveErrorMessage(e, code),
        ),
      );
    }
  }

  Future<void> logout() async {
    final auth = _authForAuthenticatedRole();
    final repo = _repoForAuth(auth);
    final biometricStore = ref.read(biometricLoginStoreProvider);
    await repo.logout();
    await biometricStore.disable();
    ref.read(currentRoleProvider.notifier).setRole(AppRole.public);
    state = const AsyncData(AuthState(status: AuthStatus.unauthenticated));
  }

  Future<void> requestPasswordReset(String identifier, {AppRole? role}) async {
    final auth = _authForScope(
      role == null ? resolveWebAuthScope() : _scopeForRole(role),
    );
    await _ensureWebLocalPersistence(auth);
    final repo = _repoForAuth(auth);
    await repo.requestPasswordReset(identifier);
  }

  Future<void> deleteAccount() async {
    final auth = _authForAuthenticatedRole();
    final repo = _repoForAuth(auth);
    final biometricStore = ref.read(biometricLoginStoreProvider);
    await repo.deleteAccount();
    await biometricStore.disable();
    ref.read(currentRoleProvider.notifier).setRole(AppRole.public);
    state = const AsyncData(AuthState(status: AuthStatus.unauthenticated));
  }

  void clearError() {
    final current = state.asData?.value;
    if (current == null) return;
    state = AsyncData(AuthState(status: current.status, user: current.user));
  }

  String? _resolveErrorCode(Object error) {
    return authErrorCodeFromException(error);
  }

  String _resolveErrorMessage(Object _, String? code) {
    return code ?? AuthErrorCodes.unknown;
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
    final auth = _authForAuthenticatedRole();
    final currentUser = auth.currentUser;
    if (currentUser == null) {
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
      final repo = _repoForAuth(auth);
      final user = await repo.me();
      ref.read(currentRoleProvider.notifier).setRole(user.role);
      return AuthState(status: AuthStatus.authenticated, user: user);
    });
  }

  Future<void> completeFirstLoginPasswordChange(String newPassword) async {
    final auth = _authForAuthenticatedRole();
    final currentUser = auth.currentUser;
    if (currentUser == null) {
      state = const AsyncData(
        AuthState(
          status: AuthStatus.unauthenticated,
          errorCode: AuthErrorCodes.invalidCredentials,
          errorMessage: AuthErrorCodes.invalidCredentials,
        ),
      );
      return;
    }

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await currentUser.updatePassword(newPassword);
      final repo = _repoForAuth(auth);
      await repo.completeFirstLoginPasswordChange();
      final user = await repo.me();
      ref.read(currentRoleProvider.notifier).setRole(user.role);
      return AuthState(status: AuthStatus.authenticated, user: user);
    });
  }

  WebAuthScope _scopeForRole(AppRole role) {
    return role == AppRole.admin ? WebAuthScope.admin : WebAuthScope.general;
  }

  FirebaseAuth _authForScope(WebAuthScope scope) {
    if (!kIsWeb) return FirebaseAuth.instance;
    final app = resolveFirebaseAppForScope(scope);
    return FirebaseAuth.instanceFor(app: app);
  }

  FirebaseAuth _authForAuthenticatedRole() {
    final role = state.asData?.value.user?.role;
    if (role != null) {
      return _authForScope(_scopeForRole(role));
    }
    return _authForScope(resolveWebAuthScope());
  }

  AuthRepository _repoForAuth(FirebaseAuth auth) {
    return AuthRepository(
      auth: auth,
      workerClient: WorkerClient(auth: auth),
    );
  }
}

final Set<String> _webLocalPersistenceReady = <String>{};
final Map<String, Future<void>> _webLocalPersistenceInflight =
    <String, Future<void>>{};

Future<void> _ensureWebLocalPersistence(FirebaseAuth auth) {
  if (!kIsWeb) {
    return Future<void>.value();
  }
  final appName = auth.app.name;
  if (_webLocalPersistenceReady.contains(appName)) {
    return Future<void>.value();
  }
  final inFlight = _webLocalPersistenceInflight[appName];
  if (inFlight != null) return inFlight;

  final future = () async {
    try {
      await auth.setPersistence(Persistence.LOCAL);
      _webLocalPersistenceReady.add(appName);
    } catch (e, st) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('Firebase session persistence fallback: $e');
        // ignore: avoid_print
        print(st);
      }
    }
  }();

  _webLocalPersistenceInflight[appName] = future;
  return future;
}
