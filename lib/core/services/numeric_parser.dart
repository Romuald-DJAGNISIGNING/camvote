class NumericParser {
  static double? parseFlexible(String? value) {
    if (value == null) {
      return null;
    }
    final compact = value.trim();
    if (compact.isEmpty) {
      return null;
    }

    final normalized = compact
        .replaceAll(RegExp(r'\s+'), '')
        .replaceAll(',', '.')
        .replaceAll(RegExp(r'[^0-9.\-]'), '');

    if (normalized.isEmpty || normalized == '-' || normalized == '.') {
      return null;
    }

    final dotCount = '.'.allMatches(normalized).length;
    if (dotCount > 1) {
      return null;
    }

    return double.tryParse(normalized);
  }

  static bool inRange(double value, double min, double max) {
    return value >= min && value <= max;
  }
}
