import 'grade_config.dart';

class ProcessingSummary {
  const ProcessingSummary({
    required this.totalRows,
    required this.gradedRows,
    required this.unknownRows,
    required this.average,
    required this.median,
    required this.passRate,
    required this.gradeCounts,
  });

  final int totalRows;
  final int gradedRows;
  final int unknownRows;
  final double average;
  final double median;
  final double passRate;
  final Map<LetterGrade, int> gradeCounts;
}
