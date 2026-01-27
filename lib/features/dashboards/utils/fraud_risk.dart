import 'package:flutter/material.dart';

import '../models/admin_models.dart';

enum FraudRiskLevel { low, medium, high, critical }

class FraudRisk {
  final FraudRiskLevel level;
  final int score;
  final List<String> signals;

  const FraudRisk({
    required this.level,
    required this.score,
    required this.signals,
  });

  String get label => switch (level) {
        FraudRiskLevel.low => 'Low',
        FraudRiskLevel.medium => 'Medium',
        FraudRiskLevel.high => 'High',
        FraudRiskLevel.critical => 'Critical',
      };

  Color color(ColorScheme cs) => switch (level) {
        FraudRiskLevel.low => cs.primary,
        FraudRiskLevel.medium => Colors.orange,
        FraudRiskLevel.high => Colors.deepOrange,
        FraudRiskLevel.critical => cs.error,
      };
}

class FraudRiskEngine {
  static FraudRisk evaluate(VoterAdminRecord voter) {
    var score = 0;
    final signals = <String>[];

    if (voter.deviceFlagged) {
      score += 35;
      signals.add('Device anomaly');
    }
    if (voter.biometricDuplicateFlag) {
      score += 45;
      signals.add('Biometric duplicate');
    }
    if (!voter.verified) {
      score += 10;
      signals.add('Unverified');
    }
    if (voter.age < 18 || voter.age > 110) {
      score += 20;
      signals.add('Age anomaly');
    }
    if (voter.status == VoterStatus.suspended ||
        voter.status == VoterStatus.deceased) {
      score += 25;
      signals.add('Status risk');
    }
    if (voter.hasVoted && voter.status != VoterStatus.voted) {
      score += 20;
      signals.add('Vote state mismatch');
    }

    final level = switch (score) {
      >= 80 => FraudRiskLevel.critical,
      >= 55 => FraudRiskLevel.high,
      >= 25 => FraudRiskLevel.medium,
      _ => FraudRiskLevel.low,
    };

    return FraudRisk(level: level, score: score, signals: signals);
  }
}
