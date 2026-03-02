enum IssueSeverity { info, warning, error }

class ValidationIssue {
  const ValidationIssue({
    required this.rowIndex,
    required this.severity,
    required this.code,
    required this.message,
  });

  final int rowIndex;
  final IssueSeverity severity;
  final String code;
  final String message;
}
