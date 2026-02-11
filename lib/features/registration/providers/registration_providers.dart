import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/registration_draft.dart';
import '../models/registration_enrollment.dart';
import '../../centers/models/voting_center.dart';

/// Device policy: max 2 different accounts per device (local enforcement now).
/// Server enforcement is also applied.
const _kDeviceAccountIdsKey = 'device_account_ids';
const _kRegistrationDraftKey = 'registration_draft_voter';
const _kRegistrationEnrollmentKey = 'registration_enrollment_voter';

final sharedPrefsProvider = FutureProvider<SharedPreferences>((ref) async {
  return SharedPreferences.getInstance();
});

final deviceAccountIdsProvider = FutureProvider<List<String>>((ref) async {
  final prefs = await ref.watch(sharedPrefsProvider.future);
  return prefs.getStringList(_kDeviceAccountIdsKey) ?? <String>[];
});

final deviceAccountPolicyProvider = Provider<DeviceAccountPolicy>((ref) {
  return DeviceAccountPolicy(ref);
});

class DeviceAccountPolicy {
  final Ref _ref;
  DeviceAccountPolicy(this._ref);

  /// Max 2 accounts per device
  Future<bool> canCreateAnotherAccount() async {
    final ids = await _ref.read(deviceAccountIdsProvider.future);
    return ids.length < 2;
  }

  Future<int> count() async {
    final ids = await _ref.read(deviceAccountIdsProvider.future);
    return ids.length;
  }

  /// Call this after a successful registration submission.
  Future<void> addAccountId(String accountId) async {
    final prefs = await _ref.read(sharedPrefsProvider.future);
    final existing = prefs.getStringList(_kDeviceAccountIdsKey) ?? <String>[];
    if (existing.contains(accountId)) return;

    final next = [...existing, accountId];
    await prefs.setStringList(_kDeviceAccountIdsKey, next);
    _ref.invalidate(deviceAccountIdsProvider);
  }
}

/// Registration draft persistence
final voterRegistrationDraftProvider =
    NotifierProvider<VoterRegistrationDraftController, RegistrationDraft>(
      VoterRegistrationDraftController.new,
    );

class VoterRegistrationDraftController extends Notifier<RegistrationDraft> {
  @override
  RegistrationDraft build() {
    // default; then we load from prefs async via loadDraft()
    return const RegistrationDraft.empty();
  }

  Future<void> loadDraft() async {
    final prefs = await ref.read(sharedPrefsProvider.future);
    final raw = prefs.getString(_kRegistrationDraftKey);
    if (raw == null || raw.isEmpty) return;

    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) return;

    state = RegistrationDraft.fromJson(decoded);
  }

  void updateFullName(String value) {
    state = state.copyWith(fullName: value, saved: false);
  }

  void updateRegionCode(String value) {
    state = state.copyWith(regionCode: value, saved: false);
  }

  void updatePlaceOfBirth(String value) {
    state = state.copyWith(placeOfBirth: value, saved: false);
  }

  void updateNationality(String value) {
    state = state.copyWith(nationality: value, saved: false);
  }

  void updateEmail(String value) {
    state = state.copyWith(email: value, saved: false);
  }

  void updatePreferredCenter(VotingCenter? center) {
    state = state.copyWith(preferredCenter: center, saved: false);
  }

  void clearPreferredCenter() {
    state = state.copyWith(clearCenter: true, saved: false);
  }

  void updateDob(DateTime dob) {
    state = state.copyWith(dateOfBirth: dob, saved: false);
  }

  void clearDob() {
    state = state.copyWith(clearDob: true, saved: false);
  }

  Future<void> saveDraft() async {
    final prefs = await ref.read(sharedPrefsProvider.future);
    final saved = state.copyWith(saved: true);
    await prefs.setString(_kRegistrationDraftKey, jsonEncode(saved.toJson()));
    state = saved;
  }

  Future<void> clearDraft() async {
    final prefs = await ref.read(sharedPrefsProvider.future);
    await prefs.remove(_kRegistrationDraftKey);
    state = const RegistrationDraft.empty();
  }
}

/// Biometric + liveness enrollment status
final registrationEnrollmentProvider =
    NotifierProvider<RegistrationEnrollmentController, RegistrationEnrollment>(
      RegistrationEnrollmentController.new,
    );

class RegistrationEnrollmentController
    extends Notifier<RegistrationEnrollment> {
  @override
  RegistrationEnrollment build() {
    return const RegistrationEnrollment.empty();
  }

  Future<void> loadEnrollment() async {
    final prefs = await ref.read(sharedPrefsProvider.future);
    final raw = prefs.getString(_kRegistrationEnrollmentKey);
    if (raw == null || raw.isEmpty) return;

    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) return;

    state = RegistrationEnrollment.fromJson(decoded);
  }

  Future<void> markBiometricEnrolled() async {
    final next = state.copyWith(biometricEnrolled: true);
    await _persist(next);
  }

  Future<void> markLivenessVerified() async {
    final next = state.copyWith(livenessVerified: true);
    await _persist(next);
  }

  Future<void> reset() async {
    final prefs = await ref.read(sharedPrefsProvider.future);
    await prefs.remove(_kRegistrationEnrollmentKey);
    state = const RegistrationEnrollment.empty();
  }

  Future<void> _persist(RegistrationEnrollment next) async {
    final completed =
        next.biometricEnrolled &&
            next.livenessVerified &&
            next.completedAt == null
        ? next.copyWith(completedAt: DateTime.now())
        : next;

    final prefs = await ref.read(sharedPrefsProvider.future);
    await prefs.setString(
      _kRegistrationEnrollmentKey,
      jsonEncode(completed.toJson()),
    );
    state = completed;
  }
}
