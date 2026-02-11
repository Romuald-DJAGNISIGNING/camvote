import 'package:shared_preferences/shared_preferences.dart';

/// Local device policy (prototype):
/// - max 2 identities (accounts) per device install
/// - supports “ban” window (3 months) if backend flags device
///
/// NOTE: True enforcement will be backend + device fingerprint.
/// This local layer is still useful UX + safety.
class DeviceIdentityPolicy {
  static const _kIdentityCount = 'device_identity_count';
  static const _kBannedUntilMs = 'device_banned_until_ms';

  static const int maxIdentitiesPerDevice = 2;

  Future<bool> isBanned() async {
    final p = await SharedPreferences.getInstance();
    final until = p.getInt(_kBannedUntilMs) ?? 0;
    return DateTime.now().millisecondsSinceEpoch < until;
  }

  Future<DateTime?> bannedUntil() async {
    final p = await SharedPreferences.getInstance();
    final until = p.getInt(_kBannedUntilMs);
    if (until == null || until == 0) return null;
    return DateTime.fromMillisecondsSinceEpoch(until);
  }

  Future<int> identityCount() async {
    final p = await SharedPreferences.getInstance();
    return p.getInt(_kIdentityCount) ?? 0;
  }

  Future<bool> canCreateIdentity() async {
    if (await isBanned()) return false;
    final count = await identityCount();
    return count < maxIdentitiesPerDevice;
  }

  /// Call this when a new identity is successfully registered (Bundle 8/9).
  Future<void> registerNewIdentity() async {
    final p = await SharedPreferences.getInstance();
    final count = (p.getInt(_kIdentityCount) ?? 0) + 1;
    await p.setInt(_kIdentityCount, count);
  }

  /// Call when backend flags device (duplicate biometrics etc.)
  Future<void> banForMonths(int months) async {
    final p = await SharedPreferences.getInstance();
    final until = DateTime.now().add(Duration(days: 30 * months));
    await p.setInt(_kBannedUntilMs, until.millisecondsSinceEpoch);
  }
}
