import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../../core/firebase/firebase_auth_scope.dart';
import '../../../core/theme/role_theme.dart';
import '../../../core/network/worker_client.dart';
import '../models/auth_error_codes.dart';
import '../models/auth_session.dart';
import '../models/auth_tokens.dart';
import '../models/auth_user.dart';

const _accountArchivedError = 'account_archived';

class AuthRepository {
  AuthRepository({FirebaseAuth? auth, WorkerClient? workerClient})
    : _authOverride = auth,
      _workerClientOverride = workerClient;

  final FirebaseAuth? _authOverride;
  final WorkerClient? _workerClientOverride;

  FirebaseAuth get _auth {
    final override = _authOverride;
    if (override != null) return override;
    if (!kIsWeb) return FirebaseAuth.instance;
    final app = resolveFirebaseAppForScope();
    return FirebaseAuth.instanceFor(app: app);
  }

  WorkerClient get _workerClient =>
      _workerClientOverride ?? WorkerClient(auth: _auth);

  Future<AuthSession> login({
    required String identifier,
    required String password,
    required AppRole role,
  }) async {
    final email = await _resolveEmail(identifier.trim());
    UserCredential credential;
    try {
      credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw StateError(AuthErrorCodes.accountNotFound);
      }
      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        throw StateError(AuthErrorCodes.invalidCredentials);
      }
      if (e.code == 'too-many-requests') {
        throw StateError(AuthErrorCodes.tooManyRequests);
      }
      if (e.code == 'network-request-failed') {
        throw StateError(AuthErrorCodes.networkError);
      }
      rethrow;
    }
    final firebaseUser = credential.user;
    if (firebaseUser == null) {
      throw StateError('Authentication failed.');
    }
    await firebaseUser.getIdToken(true);

    await _bootstrapUser(firebaseUser);
    final user = await _fetchUser(firebaseUser.uid);
    if (user.role != role) {
      await _auth.signOut();
      throw StateError('Role mismatch.');
    }

    return AuthSession(
      user: user,
      tokens: const AuthTokens(
        accessToken: '',
        refreshToken: '',
        expiresAt: null,
      ),
    );
  }

  Future<AuthTokens> refresh(String refreshToken) async {
    return const AuthTokens(accessToken: '', refreshToken: '', expiresAt: null);
  }

  Future<AuthUser> me() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) {
      throw StateError('Not authenticated.');
    }
    await _bootstrapUser(firebaseUser);
    return _fetchUser(firebaseUser.uid);
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<void> requestPasswordReset(String emailOrId) async {
    final email = await _resolveEmail(emailOrId.trim());
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw StateError(AuthErrorCodes.accountNotFound);
      }
      if (e.code == 'too-many-requests') {
        throw StateError(AuthErrorCodes.tooManyRequests);
      }
      if (e.code == 'network-request-failed') {
        throw StateError(AuthErrorCodes.networkError);
      }
      rethrow;
    }
  }

  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) return;
    await _workerClient.post('/v1/account/delete');
    await _auth.signOut();
  }

  Future<void> completeFirstLoginPasswordChange() async {
    await _workerClient.post(
      '/v1/user/profile/upsert',
      data: {
        'mustChangePassword': false,
        'passwordChangedAt': DateTime.now().toIso8601String(),
      },
      allowOfflineQueue: true,
      queueType: 'user_profile_upsert',
    );
  }

  Future<String> _resolveEmail(String identifier) async {
    if (identifier.contains('@')) return identifier;

    final response = await _workerClient.get(
      '/v1/auth/resolve-identifier',
      queryParameters: {'identifier': identifier},
      authRequired: false,
    );
    final email = response['email']?.toString() ?? '';
    if (email.isEmpty) {
      throw StateError(AuthErrorCodes.accountNotFound);
    }
    return email;
  }

  Future<AuthUser> _fetchUser(String uid) async {
    final response = await _workerClient.get('/v1/user/profile');
    final data = (response['data'] as Map?)?.cast<String, dynamic>() ?? {};
    final status = (data['status'] as String?)?.toLowerCase();
    if (status == 'archived' || data['deletedAt'] != null) {
      await _auth.signOut();
      throw StateError(_accountArchivedError);
    }
    final role = AppRoleX.fromApi(data['role'] as String?) ?? AppRole.public;
    final mustChangePasswordFlag = _asBool(data['mustChangePassword']);
    final temporaryPasswordIssuedAt = _parseDate(
      data['observerTemporaryPasswordIssuedAt'],
    );
    final passwordChangedAt = _parseDate(data['passwordChangedAt']);
    final observerNeedsPasswordChange =
        role == AppRole.observer &&
        temporaryPasswordIssuedAt != null &&
        (passwordChangedAt == null ||
            passwordChangedAt.isBefore(temporaryPasswordIssuedAt));
    return AuthUser(
      id: uid,
      fullName: (data['fullName'] as String?) ?? '',
      email: (data['email'] as String?) ?? '',
      role: role,
      voterId: data['voterId'] as String?,
      verified: (data['verified'] as bool?) ?? false,
      mustChangePassword: mustChangePasswordFlag || observerNeedsPasswordChange,
    );
  }

  Future<void> _bootstrapUser(User firebaseUser) async {
    try {
      await _workerClient.post(
        '/v1/user/bootstrap',
        data: {
          'email': firebaseUser.email ?? '',
          'fullName': firebaseUser.displayName ?? '',
        },
        allowOfflineQueue: true,
        queueType: 'user_bootstrap',
      );
    } catch (_) {
      // Best-effort; Firestore fetch below will surface issues if any.
    }
  }

  bool _asBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    final raw = value?.toString().trim().toLowerCase() ?? '';
    return raw == 'true' || raw == '1' || raw == 'yes';
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    final raw = value.toString().trim();
    if (raw.isEmpty) return null;
    return DateTime.tryParse(raw);
  }
}
