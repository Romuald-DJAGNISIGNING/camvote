import 'grade_result.dart';
import 'processing_summary.dart';
import 'validation_issue.dart';

class ProcessingReport {
  const ProcessingReport({
    required this.results,
    required this.issues,
    required this.summary,
  });

  final List<GradeResult> results;
  final List<ValidationIssue> issues;
  final ProcessingSummary summary;
}
