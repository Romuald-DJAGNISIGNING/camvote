import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DeviceKeyManager {
  DeviceKeyManager._();

  static const _privateKeyStorageKey = 'device_key_private';
  static const _publicKeyStorageKey = 'device_key_public';

  static final _storage = FlutterSecureStorage();
  static final _algorithm = Ecdsa.p256(Sha256());

  static Future<void> ensureKeyPair() async {
    final keyPairData = await _loadOrCreateKeyPair();
    final expected = base64Encode(_rawPublicKeyBytes(keyPairData.publicKey));
    final stored = await _storage.read(key: _publicKeyStorageKey);
    if (stored == null || stored.isEmpty || stored != expected) {
      await _storage.write(key: _publicKeyStorageKey, value: expected);
    }
  }

  static Future<String> publicKeyBase64() async {
    final keyPairData = await _loadOrCreateKeyPair();
    final expected = base64Encode(_rawPublicKeyBytes(keyPairData.publicKey));
    final stored = await _storage.read(key: _publicKeyStorageKey);
    if (stored != null && stored.isNotEmpty && stored == expected) {
      return stored;
    }
    await _storage.write(key: _publicKeyStorageKey, value: expected);
    return expected;
  }

  static Future<String> signMessage(String message) async {
    final keyPairData = await _loadOrCreateKeyPair();
    final signature = await _algorithm.sign(
      utf8.encode(message),
      keyPair: keyPairData,
    );
    return base64Encode(signature.bytes);
  }

  static String buildVoteMessage({
    required String nonce,
    required String uid,
    required String electionId,
    required String candidateId,
    required String deviceHash,
  }) {
    return '$nonce|$uid|$electionId|$candidateId|$deviceHash';
  }

  static Future<EcKeyPairData> _loadOrCreateKeyPair() async {
    final stored = await _storage.read(key: _privateKeyStorageKey);
    final parsed = stored == null ? null : _decodeKeyPair(stored);
    if (parsed != null) {
      return parsed;
    }

    final keyPair = await _algorithm.newKeyPair();
    final keyPairData = await keyPair.extract();
    await _persistKeyPair(keyPairData);
    return keyPairData;
  }

  static Future<void> _persistKeyPair(EcKeyPairData keyPairData) async {
    await _storage.write(
      key: _privateKeyStorageKey,
      value: _encodeKeyPair(keyPairData),
    );
    final rawPublicKey = _rawPublicKeyBytes(keyPairData.publicKey);
    await _storage.write(
      key: _publicKeyStorageKey,
      value: base64Encode(rawPublicKey),
    );
  }

  static String _encodeKeyPair(EcKeyPairData keyPairData) {
    final length = _coordinateLength(keyPairData.type);
    final d = _padLeft(keyPairData.d, length);
    final x = _padLeft(keyPairData.x, length);
    final y = _padLeft(keyPairData.y, length);
    return jsonEncode({
      'type': keyPairData.type.name,
      'd': base64Encode(d),
      'x': base64Encode(x),
      'y': base64Encode(y),
    });
  }

  static EcKeyPairData? _decodeKeyPair(String encoded) {
    try {
      final decoded = jsonDecode(encoded);
      if (decoded is! Map) return null;
      final typeName = decoded['type']?.toString();
      final type = _typeFromName(typeName);
      final d = base64Decode(decoded['d']?.toString() ?? '');
      final x = base64Decode(decoded['x']?.toString() ?? '');
      final y = base64Decode(decoded['y']?.toString() ?? '');
      if (d.isEmpty || x.isEmpty || y.isEmpty) return null;
      return EcKeyPairData(d: d, x: x, y: y, type: type);
    } catch (_) {
      return null;
    }
  }

  static KeyPairType _typeFromName(String? name) {
    switch (name) {
      case 'p256k':
        return KeyPairType.p256k;
      case 'p384':
        return KeyPairType.p384;
      case 'p521':
        return KeyPairType.p521;
      case 'p256':
      default:
        return KeyPairType.p256;
    }
  }

  static int _coordinateLength(KeyPairType type) =>
      (type.ellipticBits + 7) ~/ 8;

  static Uint8List _padLeft(List<int> bytes, int length) {
    if (bytes.length == length) {
      return Uint8List.fromList(bytes);
    }
    if (bytes.length > length) {
      return Uint8List.fromList(bytes.sublist(bytes.length - length));
    }
    final padded = Uint8List(length);
    padded.setRange(length - bytes.length, length, bytes);
    return padded;
  }

  static Uint8List _rawPublicKeyBytes(EcPublicKey publicKey) {
    final length = _coordinateLength(publicKey.type);
    final x = _padLeft(publicKey.x, length);
    final y = _padLeft(publicKey.y, length);
    final raw = Uint8List(1 + x.length + y.length);
    raw[0] = 0x04;
    raw.setRange(1, 1 + x.length, x);
    raw.setRange(1 + x.length, raw.length, y);
    return raw;
  }
}
