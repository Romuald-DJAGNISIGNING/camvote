class NormalizedStudent {
  const NormalizedStudent({
    required this.rowIndex,
    required this.name,
    required this.matricule,
    required this.ca,
    required this.exam,
    required this.total,
    required this.caPresent,
    required this.examPresent,
    required this.totalPresent,
  });

  final int rowIndex;
  final String? name;
  final String? matricule;
  final double? ca;
  final double? exam;
  final double? total;
  final bool caPresent;
  final bool examPresent;
  final bool totalPresent;
}
