class StudentInputRow {
  const StudentInputRow({
    required this.rowIndex,
    required this.name,
    required this.matricule,
    required this.ca,
    required this.exam,
    required this.total,
    required this.rawValues,
  });

  final int rowIndex;
  final String? name;
  final String? matricule;
  final String? ca;
  final String? exam;
  final String? total;
  final Map<String, String?> rawValues;

  StudentInputRow copyWith({
    String? name,
    String? matricule,
    String? ca,
    String? exam,
    String? total,
    Map<String, String?>? rawValues,
  }) {
    return StudentInputRow(
      rowIndex: rowIndex,
      name: name ?? this.name,
      matricule: matricule ?? this.matricule,
      ca: ca ?? this.ca,
      exam: exam ?? this.exam,
      total: total ?? this.total,
      rawValues: rawValues ?? this.rawValues,
    );
  }
}
