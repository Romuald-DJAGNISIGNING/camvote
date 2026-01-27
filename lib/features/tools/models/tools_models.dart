class FraudInsight {
  final double riskScore;
  final int totalSignals;
  final int devicesFlagged;
  final int accountsAtRisk;
  final List<FraudSignal> signals;
  final DateTime? lastUpdated;

  const FraudInsight({
    required this.riskScore,
    required this.totalSignals,
    required this.devicesFlagged,
    required this.accountsAtRisk,
    required this.signals,
    required this.lastUpdated,
  });
}

class FraudSignal {
  final String id;
  final String title;
  final String detail;
  final int count;
  final String severity;

  const FraudSignal({
    required this.id,
    required this.title,
    required this.detail,
    required this.count,
    required this.severity,
  });
}

class DeviceRisk {
  final String deviceId;
  final String label;
  final String reason;
  final String status;
  final int strikes;
  final DateTime? lastSeen;

  const DeviceRisk({
    required this.deviceId,
    required this.label,
    required this.reason,
    required this.status,
    required this.strikes,
    required this.lastSeen,
  });
}

class IncidentOverview {
  final String id;
  final String title;
  final String status;
  final String severity;
  final String location;
  final DateTime reportedAt;
  final String reporterRole;
  final List<String> attachments;

  const IncidentOverview({
    required this.id,
    required this.title,
    required this.status,
    required this.severity,
    required this.location,
    required this.reportedAt,
    required this.reporterRole,
    required this.attachments,
  });
}

class ResultsPublishStatus {
  final String electionId;
  final String electionTitle;
  final bool readyToPublish;
  final int totalVotes;
  final int precinctsReporting;
  final DateTime? lastPublishedAt;

  const ResultsPublishStatus({
    required this.electionId,
    required this.electionTitle,
    required this.readyToPublish,
    required this.totalVotes,
    required this.precinctsReporting,
    required this.lastPublishedAt,
  });
}

class TransparencyUpdate {
  final String id;
  final String title;
  final String summary;
  final DateTime publishedAt;
  final String source;

  const TransparencyUpdate({
    required this.id,
    required this.title,
    required this.summary,
    required this.publishedAt,
    required this.source,
  });
}

class ObservationChecklistItem {
  final String id;
  final String title;
  final String description;
  final bool required;
  final bool completed;

  const ObservationChecklistItem({
    required this.id,
    required this.title,
    required this.description,
    required this.required,
    required this.completed,
  });
}

class CivicLesson {
  final String id;
  final String title;
  final String summary;
  final String category;
  final String sourceUrl;

  const CivicLesson({
    required this.id,
    required this.title,
    required this.summary,
    required this.category,
    required this.sourceUrl,
  });
}

class ElectionCalendarEntry {
  final String id;
  final String title;
  final String scope;
  final String location;
  final String status;
  final DateTime startAt;
  final DateTime endAt;

  const ElectionCalendarEntry({
    required this.id,
    required this.title,
    required this.scope,
    required this.location,
    required this.status,
    required this.startAt,
    required this.endAt,
  });
}
