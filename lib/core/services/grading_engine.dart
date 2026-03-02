import 'dart:math';

import 'package:collection/collection.dart';

import '../models/grade_config.dart';
import '../models/grade_result.dart';
import '../models/normalized_student.dart';
import '../models/processing_report.dart';
import '../models/processing_summary.dart';
import '../models/student_input_row.dart';
import '../models/validation_issue.dart';
import 'numeric_parser.dart';

class GradingEngine {
  const GradingEngine({this.config = GradingConfig.strictDefault});

  final GradingConfig config;

  ProcessingReport batchGrade(List<StudentInputRow> inputRows) {
    final issues = <ValidationIssue>[];
    final dedupedRows = _dedupeRows(inputRows, issues);

    final graded = dedupedRows.map((row) {
      final evaluation = _evaluate(row);
      issues.addAll(evaluation.issues);
      return evaluation.result;
    }).toList()
      ..sort((a, b) => a.rowIndex.compareTo(b.rowIndex));

    final summary = _buildSummary(graded);

    return ProcessingReport(
      results: graded,
      issues: issues..sort((a, b) => a.rowIndex.compareTo(b.rowIndex)),
      summary: summary,
    );
  }

  List<StudentInputRow> _dedupeRows(
    List<StudentInputRow> rows,
    List<ValidationIssue> issues,
  ) {
    final byKey = <String, StudentInputRow>{};

    for (final row in rows) {
      final key = _dedupeKey(row);
      if (key == null) {
        byKey['row-${row.rowIndex}'] = row;
        continue;
      }

      final existing = byKey[key];
      if (existing != null) {
        issues.add(
          ValidationIssue(
            rowIndex: row.rowIndex,
            severity: IssueSeverity.warning,
            code: 'DUPLICATE',
            message:
                'Duplicate identifier detected. Keeping latest row ${row.rowIndex}, replacing row ${existing.rowIndex}.',
          ),
        );
      }
      byKey[key] = row;
    }

    return byKey.values.toList();
  }

  String? _dedupeKey(StudentInputRow row) {
    final matricule = row.matricule?.trim();
    if (matricule != null && matricule.isNotEmpty) {
      return 'm:${matricule.toLowerCase()}';
    }
    final name = row.name?.trim();
    if (name != null && name.isNotEmpty) {
      return 'n:${name.toLowerCase()}';
    }
    return null;
  }

  _Evaluation _evaluate(StudentInputRow row) {
    final issues = <ValidationIssue>[];
    final reasons = <String>[];

    final name = row.name?.trim();
    final matricule = row.matricule?.trim();
    final hasIdentity = (name?.isNotEmpty == true) || (matricule?.isNotEmpty == true);

    final caPresent = row.ca?.trim().isNotEmpty == true;
    final examPresent = row.exam?.trim().isNotEmpty == true;
    final totalPresent = row.total?.trim().isNotEmpty == true;

    final ca = NumericParser.parseFlexible(row.ca);
    final exam = NumericParser.parseFlexible(row.exam);
    final total = NumericParser.parseFlexible(row.total);

    final normalized = NormalizedStudent(
      rowIndex: row.rowIndex,
      name: name,
      matricule: matricule,
      ca: ca,
      exam: exam,
      total: total,
      caPresent: caPresent,
      examPresent: examPresent,
      totalPresent: totalPresent,
    );

    if (!hasIdentity) {
      issues.add(
        ValidationIssue(
          rowIndex: row.rowIndex,
          severity: IssueSeverity.error,
          code: 'MISSING_ID',
          message: 'Both name and matricule are missing.',
        ),
      );
      reasons.add('Missing identifier');
    }

    if (caPresent && ca == null) {
      reasons.add('CA mark is not numeric');
    }
    if (examPresent && exam == null) {
      reasons.add('Exam mark is not numeric');
    }
    if (totalPresent && total == null) {
      reasons.add('Total mark is not numeric');
    }

    final scoreDecision = _resolveFinalScore(normalized, reasons);
    final finalScore = scoreDecision.score;
    final unknown = !hasIdentity || finalScore == null;

    if (unknown) {
      issues.add(
        ValidationIssue(
          rowIndex: row.rowIndex,
          severity: IssueSeverity.error,
          code: 'UNKNOWN_GRADE',
          message: reasons.isEmpty
              ? 'Unable to compute final score from provided marks.'
              : reasons.join('; '),
        ),
      );
    } else if (scoreDecision.usedFallback) {
      issues.add(
        ValidationIssue(
          rowIndex: row.rowIndex,
          severity: IssueSeverity.warning,
          code: 'FALLBACK_TOTAL',
          message: 'CA/Exam could not be used. Total score fallback applied.',
        ),
      );
    }

    final roundedScore = finalScore == null
        ? null
        : double.parse(finalScore.toStringAsFixed(2));
    final letter = config.letterForScore(roundedScore, unknown: unknown);
    final pass = roundedScore != null && roundedScore >= config.passCutoff;

    final result = GradeResult(
      rowIndex: row.rowIndex,
      name: name,
      matricule: matricule,
      finalScore: roundedScore,
      letter: letter,
      pass: pass,
      status: unknown ? GradeStatus.unknown : GradeStatus.graded,
      reasons: List.unmodifiable(reasons),
      source: scoreDecision.source,
    );

    return _Evaluation(result: result, issues: issues);
  }

  _ScoreDecision _resolveFinalScore(NormalizedStudent row, List<String> reasons) {
    if (row.caPresent && row.examPresent && row.ca != null && row.exam != null) {
      final ca = row.ca!;
      final exam = row.exam!;

      if (NumericParser.inRange(ca, 0, config.caMaxRaw) &&
          NumericParser.inRange(exam, 0, config.examMaxRaw)) {
        return _ScoreDecision(score: ca + exam, source: 'CA+Exam (raw)', usedFallback: false);
      }

      if (NumericParser.inRange(ca, 0, config.maxPercent) &&
          NumericParser.inRange(exam, 0, config.maxPercent)) {
        final weighted = (ca * config.caWeight) + (exam * config.examWeight);
        return _ScoreDecision(score: weighted, source: 'CA+Exam (weighted)', usedFallback: false);
      }

      reasons.add('CA/Exam values are out of accepted ranges');
    } else if (row.caPresent || row.examPresent) {
      reasons.add('CA/Exam pair is incomplete');
    }

    if (row.totalPresent && row.total != null) {
      final total = row.total!;
      if (NumericParser.inRange(total, 0, config.maxPercent)) {
        return _ScoreDecision(score: total, source: 'Total (fallback)', usedFallback: true);
      }
      reasons.add('Total is out of 0..100 range');
    }

    if (row.totalPresent && row.total == null) {
      reasons.add('Total is present but invalid');
    }

    return const _ScoreDecision(score: null, source: 'Unavailable', usedFallback: false);
  }

  ProcessingSummary _buildSummary(List<GradeResult> results) {
    final gradeCounts = <LetterGrade, int>{
      for (final letter in LetterGrade.values) letter: 0,
    };

    for (final result in results) {
      gradeCounts[result.letter] = (gradeCounts[result.letter] ?? 0) + 1;
    }

    final gradedScores = results
        .where((result) => result.status == GradeStatus.graded)
        .map((result) => result.finalScore!)
        .toList()
      ..sort();

    final gradedRows = gradedScores.length;
    final unknownRows = results.length - gradedRows;
    final average = gradedRows == 0
        ? 0.0
        : gradedScores.sum / max(gradedRows, 1);

    final median = _median(gradedScores);
    final passCount = results
        .where((result) => result.status == GradeStatus.graded && result.pass)
        .length;
    final passRate = gradedRows == 0 ? 0.0 : (passCount / gradedRows) * 100;

    return ProcessingSummary(
      totalRows: results.length,
      gradedRows: gradedRows,
      unknownRows: unknownRows,
      average: double.parse(average.toStringAsFixed(2)),
      median: double.parse(median.toStringAsFixed(2)),
      passRate: double.parse(passRate.toStringAsFixed(2)),
      gradeCounts: gradeCounts,
    );
  }

  double _median(List<double> sorted) {
    if (sorted.isEmpty) {
      return 0;
    }
    final mid = sorted.length ~/ 2;
    if (sorted.length.isOdd) {
      return sorted[mid];
    }
    return (sorted[mid - 1] + sorted[mid]) / 2;
  }
}

class _Evaluation {
  const _Evaluation({required this.result, required this.issues});

  final GradeResult result;
  final List<ValidationIssue> issues;
}

class _ScoreDecision {
  const _ScoreDecision({
    required this.score,
    required this.source,
    required this.usedFallback,
  });

  final double? score;
  final String source;
  final bool usedFallback;
}
