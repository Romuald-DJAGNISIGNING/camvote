import 'dart:math';

import 'ocr_models.dart';

class OcrParser {
  static OcrExtractedIdentity parse({
    required String raw,
    required OfficialDocumentType docType,
  }) {
    final text = raw.replaceAll('\r', '\n');
    final lines = text
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    // 1) Try MRZ first for passports (best signal)
    if (docType == OfficialDocumentType.passport) {
      final mrz = _tryParseMrz(lines);
      if (mrz != null) return mrz.copyWith(rawText: raw);
    }

    // 2) Generic label-based parsing (IDs, other docs)
    final fullName = _valueAfterAnyLabel(lines, [
      RegExp(r'^(NOMS?|SURNAME|NAME)\b', caseSensitive: false),
      RegExp(r'^(NOM)\b', caseSensitive: false),
      RegExp(r'^(PRENOMS?|GIVEN\s+NAMES?)\b', caseSensitive: false),
    ]);

    final nationality = _valueAfterAnyLabel(lines, [
      RegExp(r'^(NATIONALIT(E|Y))\b', caseSensitive: false),
      RegExp(r'^(CITIZENSHIP)\b', caseSensitive: false),
    ]);

    final pob = _valueAfterAnyLabel(lines, [
      RegExp(r'^(LIEU\s+DE\s+NAISSANCE)\b', caseSensitive: false),
      RegExp(r'^(PLACE\s+OF\s+BIRTH)\b', caseSensitive: false),
      RegExp(r'^(BORN\s+AT)\b', caseSensitive: false),
    ]);

    final dob = _findFirstDate(lines);

    return OcrExtractedIdentity(
      rawText: raw,
      fullName: _cleanValue(fullName),
      dateOfBirth: dob,
      placeOfBirth: _cleanValue(pob),
      nationality: _cleanValue(nationality),
    );
  }

  static OcrValidationResult validate({
    required String expectedFullName,
    required DateTime expectedDob,
    required String expectedPlaceOfBirth,
    required String expectedNationality,
    required OcrExtractedIdentity extracted,
  }) {
    // Strict rule: ALL FOUR must match to pass.
    final nameOk = _fuzzyNameMatch(expectedFullName, extracted.fullName);
    final dobOk = _dobMatch(expectedDob, extracted.dateOfBirth);
    final pobOk = _tokenOverlapMatch(
      expectedPlaceOfBirth,
      extracted.placeOfBirth,
    );
    final natOk = _tokenOverlapMatch(
      expectedNationality,
      extracted.nationality,
    );

    final ok = nameOk && dobOk && pobOk && natOk;

    final issues = <String>[];
    if (!nameOk) issues.add('Name mismatch');
    if (!dobOk) issues.add('Date of birth mismatch');
    if (!pobOk) issues.add('Place of birth mismatch');
    if (!natOk) issues.add('Nationality mismatch');

    return OcrValidationResult(
      ok: ok,
      summary: ok ? 'Verified' : issues.join(' • '),
      nameOk: nameOk,
      dobOk: dobOk,
      pobOk: pobOk,
      nationalityOk: natOk,
    );
  }

  // ------------------------ helpers ------------------------

  static DateTime? _findFirstDate(List<String> lines) {
    // Supports: dd/mm/yyyy, dd-mm-yyyy, yyyy-mm-dd
    final patterns = <RegExp>[
      RegExp(r'\b(\d{2})[\/\-](\d{2})[\/\-](\d{4})\b'),
      RegExp(r'\b(\d{4})[\/\-](\d{2})[\/\-](\d{2})\b'),
    ];
    for (final line in lines) {
      for (final p in patterns) {
        final m = p.firstMatch(line);
        if (m == null) continue;

        try {
          if (m.groupCount == 3) {
            final a = int.parse(m.group(1)!);
            final b = int.parse(m.group(2)!);
            final c = int.parse(m.group(3)!);
            if (c > 1900) {
              // dd/mm/yyyy
              return DateTime(c, b, a);
            } else {
              // yyyy/mm/dd
              return DateTime(a, b, c);
            }
          }
        } catch (_) {}
      }
    }
    return null;
  }

  static String? _valueAfterAnyLabel(List<String> lines, List<RegExp> labels) {
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      for (final label in labels) {
        if (label.hasMatch(line)) {
          // Try same-line after ":" first
          final idx = line.indexOf(':');
          if (idx != -1 && idx < line.length - 1) {
            final v = line.substring(idx + 1).trim();
            if (v.isNotEmpty) return v;
          }
          // Otherwise next line
          if (i + 1 < lines.length) return lines[i + 1].trim();
        }
      }
    }
    return null;
  }

  static String? _cleanValue(String? s) {
    if (s == null) return null;
    final v = s
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r'^[\-\:]+'), '')
        .trim();
    return v.isEmpty ? null : v;
  }

  static bool _dobMatch(DateTime expected, DateTime? got) {
    if (got == null) return false;
    return expected.year == got.year &&
        expected.month == got.month &&
        expected.day == got.day;
  }

  static bool _tokenOverlapMatch(String expected, String? got) {
    if (got == null) return false;
    final a = _normalize(
      expected,
    ).split(' ').where((e) => e.length >= 2).toSet();
    final b = _normalize(got).split(' ').where((e) => e.length >= 2).toSet();
    if (a.isEmpty || b.isEmpty) return false;
    final inter = a.intersection(b).length;
    final score = inter / max(1, min(a.length, b.length));
    return score >= 0.70; // fairly strict
  }

  static bool _fuzzyNameMatch(String expected, String? got) {
    if (got == null) return false;
    // stronger: require at least 2 tokens overlap and >= 0.7 overlap score
    final ok = _tokenOverlapMatch(expected, got);
    if (!ok) return false;

    // Extra strict: last-name token must match (common on official docs)
    final eTokens = _normalize(
      expected,
    ).split(' ').where((e) => e.isNotEmpty).toList();
    final gTokens = _normalize(
      got,
    ).split(' ').where((e) => e.isNotEmpty).toList();
    if (eTokens.isEmpty || gTokens.isEmpty) return false;
    return gTokens.contains(eTokens.first) || gTokens.contains(eTokens.last);
  }

  static String _normalize(String input) {
    final s = input.toUpperCase();
    // basic diacritic stripping (enough for FR names)
    const map = {
      'À': 'A',
      'Â': 'A',
      'Ä': 'A',
      'Á': 'A',
      'Ã': 'A',
      'Ç': 'C',
      'È': 'E',
      'É': 'E',
      'Ê': 'E',
      'Ë': 'E',
      'Ì': 'I',
      'Í': 'I',
      'Î': 'I',
      'Ï': 'I',
      'Ò': 'O',
      'Ó': 'O',
      'Ô': 'O',
      'Ö': 'O',
      'Õ': 'O',
      'Ù': 'U',
      'Ú': 'U',
      'Û': 'U',
      'Ü': 'U',
      'Ÿ': 'Y',
      '’': '',
      '\'': '',
      '-': ' ',
    };
    final b = StringBuffer();
    for (final ch in s.split('')) {
      b.write(map[ch] ?? ch);
    }
    return b
        .toString()
        .replaceAll(RegExp(r'[^A-Z0-9 ]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  // -------- MRZ (passport) --------
  static _MrzParsed? _tryParseMrz(List<String> lines) {
    final mrzLines = lines
        .where((l) => l.contains('<') && l.length >= 30)
        .toList();
    if (mrzLines.length < 2) return null;

    // Best guess: last two MRZ-like lines
    final l1 = mrzLines[mrzLines.length - 2];
    final l2 = mrzLines[mrzLines.length - 1];

    if (!l1.startsWith('P<') && !l1.startsWith('I<')) return null;

    String? name;
    DateTime? dob;
    String? nat;

    // Line1: names
    final namePart = l1.length > 5 ? l1.substring(2) : l1;
    final split = namePart.split('<<');
    if (split.isNotEmpty) {
      final surname = split[0].replaceAll('<', ' ').trim();
      final given = split.length > 1
          ? split[1].replaceAll('<', ' ').trim()
          : '';
      final combined = ('$surname $given')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();
      if (combined.isNotEmpty) name = combined;
    }

    // Line2: nationality + birthdate YYMMDD (positions vary by doc type; use common passport layout)
    if (l2.length >= 20) {
      nat = l2.substring(10, 13).replaceAll('<', '').trim();
      final yy = int.tryParse(l2.substring(13, 15));
      final mm = int.tryParse(l2.substring(15, 17));
      final dd = int.tryParse(l2.substring(17, 19));
      if (yy != null && mm != null && dd != null) {
        // naive century guess: 00-29 => 2000+, else 1900+
        final year = (yy <= 29) ? 2000 + yy : 1900 + yy;
        dob = DateTime(year, mm, dd);
      }
    }

    return _MrzParsed(fullName: name, dateOfBirth: dob, nationality: nat);
  }
}

class _MrzParsed {
  final String? fullName;
  final DateTime? dateOfBirth;
  final String? nationality;

  _MrzParsed({this.fullName, this.dateOfBirth, this.nationality});

  OcrExtractedIdentity copyWith({required String rawText}) =>
      OcrExtractedIdentity(
        rawText: rawText,
        fullName: fullName,
        dateOfBirth: dateOfBirth,
        placeOfBirth: null, // MRZ doesn't contain POB reliably
        nationality: nationality,
      );
}
