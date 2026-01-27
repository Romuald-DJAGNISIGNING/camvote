import 'package:camvote/gen/l10n/app_localizations.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

enum IncidentCategory {
  fraud,
  intimidation,
  violence,
  logistics,
  technical,
  accessibility,
  other,
}

extension IncidentCategoryX on IncidentCategory {
  String label(AppLocalizations t) => switch (this) {
        IncidentCategory.fraud => t.incidentCategoryFraud,
        IncidentCategory.intimidation => t.incidentCategoryIntimidation,
        IncidentCategory.violence => t.incidentCategoryViolence,
        IncidentCategory.logistics => t.incidentCategoryLogistics,
        IncidentCategory.technical => t.incidentCategoryTechnical,
        IncidentCategory.accessibility => t.incidentCategoryAccessibility,
        IncidentCategory.other => t.incidentCategoryOther,
      };

  String get apiValue => switch (this) {
        IncidentCategory.fraud => 'fraud',
        IncidentCategory.intimidation => 'intimidation',
        IncidentCategory.violence => 'violence',
        IncidentCategory.logistics => 'logistics',
        IncidentCategory.technical => 'technical',
        IncidentCategory.accessibility => 'accessibility',
        IncidentCategory.other => 'other',
      };
}

enum IncidentSeverity { low, medium, high, critical }

extension IncidentSeverityX on IncidentSeverity {
  String label(AppLocalizations t) => switch (this) {
        IncidentSeverity.low => t.incidentSeverityLow,
        IncidentSeverity.medium => t.incidentSeverityMedium,
        IncidentSeverity.high => t.incidentSeverityHigh,
        IncidentSeverity.critical => t.incidentSeverityCritical,
      };

  String get apiValue => switch (this) {
        IncidentSeverity.low => 'low',
        IncidentSeverity.medium => 'medium',
        IncidentSeverity.high => 'high',
        IncidentSeverity.critical => 'critical',
      };
}

@immutable
class IncidentReport {
  final String title;
  final String description;
  final String location;
  final DateTime occurredAt;
  final IncidentCategory category;
  final IncidentSeverity severity;
  final String electionId;
  final List<XFile> attachments;

  const IncidentReport({
    required this.title,
    required this.description,
    required this.location,
    required this.occurredAt,
    required this.category,
    required this.severity,
    required this.electionId,
    required this.attachments,
  });
}

@immutable
class IncidentReportResult {
  final String reportId;
  final String status;
  final String message;

  const IncidentReportResult({
    required this.reportId,
    required this.status,
    required this.message,
  });

  factory IncidentReportResult.fromJson(Map<String, dynamic> json) {
    return IncidentReportResult(
      reportId: (json['report_id'] as String?) ?? '',
      status: (json['status'] as String?) ?? '',
      message: (json['message'] as String?) ?? '',
    );
  }
}
