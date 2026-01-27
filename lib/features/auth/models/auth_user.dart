import 'package:flutter/foundation.dart';
import '../../../core/theme/role_theme.dart';

@immutable
class AuthUser {
  final String id;
  final String fullName;
  final String email;
  final AppRole role;
  final String? voterId;
  final bool verified;

  const AuthUser({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    required this.voterId,
    required this.verified,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: (json['id'] as String?) ?? '',
      fullName: (json['full_name'] as String?) ?? '',
      email: (json['email'] as String?) ?? '',
      role: AppRoleX.fromApi(json['role'] as String?) ?? AppRole.public,
      voterId: json['voter_id'] as String?,
      verified: (json['verified'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'full_name': fullName,
        'email': email,
        'role': role.apiValue,
        'voter_id': voterId,
        'verified': verified,
      };
}
