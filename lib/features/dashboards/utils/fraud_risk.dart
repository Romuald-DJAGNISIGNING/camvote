import 'package:flutter/material.dart';

import 'package:camvote/gen/l10n/app_localizations.dart';

import '../models/admin_models.dart';

enum FraudRiskLevel { low, medium, high, critical }

enum FraudSignalType {
  deviceAnomaly,
  biometricDuplicate,
  unverified,
  ageAnomaly,
  statusRisk,
  voteStateMismatch;

  String label(AppLocalizations t) => switch (this) {
    FraudSignalType.deviceAnomaly => t.fraudSignalDeviceAnomaly,
    FraudSignalType.biometricDuplicate => t.fraudSignalBiometricDuplicate,
    FraudSignalType.unverified => t.fraudSignalUnverified,
    FraudSignalType.ageAnomaly => t.fraudSignalAgeAnomaly,
    FraudSignalType.statusRisk => t.fraudSignalStatusRisk,
    FraudSignalType.voteStateMismatch => t.fraudSignalVoteStateMismatch,
  };
}

class FraudRisk {
  final FraudRiskLevel level;
  final int score;
  final List<FraudSignalType> signals;

  const FraudRisk({
    required this.level,
    required this.score,
    required this.signals,
  });

  String label(AppLocalizations t) => switch (level) {
    FraudRiskLevel.low => t.riskLow,
    FraudRiskLevel.medium => t.riskMedium,
    FraudRiskLevel.high => t.riskHigh,
    FraudRiskLevel.critical => t.riskCritical,
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
    final signals = <FraudSignalType>[];

    if (voter.deviceFlagged) {
      score += 35;
      signals.add(FraudSignalType.deviceAnomaly);
    }
    if (voter.biometricDuplicateFlag) {
      score += 45;
      signals.add(FraudSignalType.biometricDuplicate);
    }
    if (!voter.verified) {
      score += 10;
      signals.add(FraudSignalType.unverified);
    }
    if (voter.age < 18 || voter.age > 110) {
      score += 20;
      signals.add(FraudSignalType.ageAnomaly);
    }
    if (voter.status == VoterStatus.suspended ||
        voter.status == VoterStatus.deceased) {
      score += 25;
      signals.add(FraudSignalType.statusRisk);
    }
    if (voter.hasVoted && voter.status != VoterStatus.voted) {
      score += 20;
      signals.add(FraudSignalType.voteStateMismatch);
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
