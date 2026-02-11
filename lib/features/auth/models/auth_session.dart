import 'package:flutter/foundation.dart';
import 'auth_user.dart';
import 'auth_tokens.dart';

@immutable
class AuthSession {
  final AuthUser user;
  final AuthTokens tokens;

  const AuthSession({required this.user, required this.tokens});
}
