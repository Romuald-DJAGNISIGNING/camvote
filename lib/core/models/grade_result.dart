import 'grade_config.dart';

enum GradeStatus { graded, unknown }

class GradeResult {
  const GradeResult({
    required this.rowIndex,
    required this.name,
    required this.matricule,
    required this.finalScore,
    required this.letter,
    required this.pass,
    required this.status,
    required this.reasons,
    required this.source,
  });

  final int rowIndex;
  final String? name;
  final String? matricule;
  final double? finalScore;
  final LetterGrade letter;
  final bool pass;
  final GradeStatus status;
  final List<String> reasons;
  final String source;

  String get printableName {
    final trimmedName = name?.trim();
    if (trimmedName != null && trimmedName.isNotEmpty) {
      return trimmedName;
    }
    final trimmedMatricule = matricule?.trim();
    if (trimmedMatricule != null && trimmedMatricule.isNotEmpty) {
      return trimmedMatricule;
    }
    return 'Unknown Student';
  }
}
