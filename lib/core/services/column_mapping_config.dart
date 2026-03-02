class ColumnMappingConfig {
  const ColumnMappingConfig({
    required this.nameAliases,
    required this.matriculeAliases,
    required this.caAliases,
    required this.examAliases,
    required this.totalAliases,
  });

  final Set<String> nameAliases;
  final Set<String> matriculeAliases;
  final Set<String> caAliases;
  final Set<String> examAliases;
  final Set<String> totalAliases;

  static const defaults = ColumnMappingConfig(
    nameAliases: {
      'name',
      'studentname',
      'student_name',
      'fullname',
      'full_name',
      'nom',
    },
    matriculeAliases: {
      'matricule',
      'matriculation',
      'matriculeid',
      'registration',
      'studentid',
      'id',
    },
    caAliases: {
      'ca',
      'continuousassessment',
      'coursework',
      'assignment',
      'test',
    },
    examAliases: {
      'exam',
      'exammark',
      'examscore',
      'finalexam',
      'final_exam',
    },
    totalAliases: {
      'total',
      'totalmark',
      'totalscore',
      'score',
      'mark',
      'gradepoint',
    },
  );

  static String normalizeHeader(String input) {
    return input.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
  }

  String? resolveCanonical(String rawHeader) {
    final normalized = normalizeHeader(rawHeader);
    if (nameAliases.contains(normalized)) {
      return 'name';
    }
    if (matriculeAliases.contains(normalized)) {
      return 'matricule';
    }
    if (caAliases.contains(normalized)) {
      return 'ca';
    }
    if (examAliases.contains(normalized)) {
      return 'exam';
    }
    if (totalAliases.contains(normalized)) {
      return 'total';
    }
    return null;
  }
}
