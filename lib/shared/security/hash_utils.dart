import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';

class HashUtils {
  const HashUtils._();

  static const _uuid = Uuid();

  static String sha256Hex(String input) {
    final bytes = utf8.encode(input);
    return sha256.convert(bytes).toString();
  }

  static String saltedHash(String input) {
    final salt = _uuid.v4();
    return sha256Hex('$input|$salt');
  }

  static String auditToken({
    required String electionId,
    required String candidateId,
  }) {
    final nonce = _uuid.v4();
    final now = DateTime.now().toIso8601String();
    return sha256Hex('$electionId|$candidateId|$now|$nonce');
  }
}
