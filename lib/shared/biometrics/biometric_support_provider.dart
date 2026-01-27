import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'biometric_gate.dart';

final biometricSupportProvider = FutureProvider<bool>((ref) async {
  final gate = BiometricGate();
  return gate.isSupported();
});
