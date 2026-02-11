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

    // 1) Try MRZ first (best signal if present on document)
    final mrz = _tryParseMrz(lines);
    if (mrz != null) return mrz.copyWith(rawText: raw);

    // 2) Generic label-based parsing (IDs, other docs)
    final combinedName = _valueAfterAnyLabel(lines, [
      RegExp(r'^(NOMS?|SURNAME|NAME)\b', caseSensitive: false),
      RegExp(r'^(NOM)\b', caseSensitive: false),
      RegExp(r'^(PRENOMS?|GIVEN\s+NAMES?)\b', caseSensitive: false),
      RegExp(r'^(NOMS?\s+ET\s+PRENOMS?)\b', caseSensitive: false),
      RegExp(r'^(NOM\s+ET\s+PRENOM)\b', caseSensitive: false),
      RegExp(r'^(NOM\s+DE\s+FAMILLE)\b', caseSensitive: false),
      RegExp(r'^(FULL\s+NAME)\b', caseSensitive: false),
      RegExp(r'^(NOMS?\s*\/\s*PRENOMS?)\b', caseSensitive: false),
      RegExp(r'^(NOM\s*\/\s*PRENOM)\b', caseSensitive: false),
    ]);
    final surname = _valueAfterAnyLabel(lines, [
      RegExp(r'^(NOM|NOMS|SURNAME|LAST\s+NAME)\b', caseSensitive: false),
      RegExp(r'^(NOM\s+DE\s+FAMILLE)\b', caseSensitive: false),
    ]);
    final givenNames = _valueAfterAnyLabel(lines, [
      RegExp(
        r'^(PRENOMS?|GIVEN\s+NAMES?|FIRST\s+NAMES?)\b',
        caseSensitive: false,
      ),
    ]);

    final dobLabelValue = _valueAfterAnyLabel(lines, [
      RegExp(r'^(DATE\s+DE\s+NAISSANCE)\b', caseSensitive: false),
      RegExp(r'^(DATE\s+NAISSANCE)\b', caseSensitive: false),
      RegExp(r'^(DATE\s+OF\s+BIRTH)\b', caseSensitive: false),
      RegExp(r'^(NE\s+LE|N[EÉ]\s+LE)\b', caseSensitive: false),
      RegExp(r'^(DOB)\b', caseSensitive: false),
    ]);

    final nationality = _valueAfterAnyLabel(lines, [
      RegExp(r'^(NATIONALIT(E|Y))\b', caseSensitive: false),
      RegExp(r'^(CITIZENSHIP)\b', caseSensitive: false),
      RegExp(r'^(PAYS)\b', caseSensitive: false),
    ]);

    final pob = _valueAfterAnyLabel(lines, [
      RegExp(r'^(LIEU\s+DE\s+NAISSANCE)\b', caseSensitive: false),
      RegExp(r'^(LIEU\s+DE\s+NAISS)\b', caseSensitive: false),
      RegExp(r'^(LIEU\s+DE\s+N)\b', caseSensitive: false),
      RegExp(r'^(LIEU\s+NAISSANCE)\b', caseSensitive: false),
      RegExp(r'^(PLACE\s+OF\s+BIRTH)\b', caseSensitive: false),
      RegExp(r'^(BIRTH\s+PLACE)\b', caseSensitive: false),
      RegExp(r'^(BORN\s+AT)\b', caseSensitive: false),
      RegExp(r'^(BORN\s+IN)\b', caseSensitive: false),
      RegExp(r'^(NE\s+A|N[EÉ]\s+A)\b', caseSensitive: false),
    ]);

    final dob = _parseDateFromText(dobLabelValue) ?? _findFirstDate(lines);
    final isPassport = docType == OfficialDocumentType.passport;
    final resolvedName =
        _mergeNameParts(surname, givenNames) ??
        combinedName ??
        _guessName(
          isPassport ? lines.where((l) => !l.contains('<')).toList() : lines,
        );

    return OcrExtractedIdentity(
      rawText: raw,
      fullName: _cleanValue(resolvedName),
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
    required OfficialDocumentType docType,
    required OcrExtractedIdentity extracted,
  }) {
    // More tolerant for real-world documents: accept partial matches.
    final nameOk = expectedFullName.trim().isEmpty
        ? true
        : _fuzzyNameMatch(expectedFullName, extracted.fullName);
    final dobOk = _dobMatch(expectedDob, extracted.dateOfBirth);
    final hasPob = expectedPlaceOfBirth.trim().isNotEmpty;
    final extractedPob = (extracted.placeOfBirth ?? '').trim().isNotEmpty;
    final pobOk = !hasPob || !extractedPob
        ? true
        : _tokenOverlapMatch(
            expectedPlaceOfBirth,
            extracted.placeOfBirth,
            minScore: 0.3,
          );
    final hasNat = expectedNationality.trim().isNotEmpty;
    final natOk = !hasNat
        ? true
        : _tokenOverlapMatch(
            expectedNationality,
            extracted.nationality,
            minScore: 0.3,
          );

    final cameroonFlag = _cameroonDocFlag(
      extracted.nationality,
      extracted.rawText,
    );
    final foreignDetected = cameroonFlag == false;

    final checks = <bool>[nameOk, dobOk];
    if (hasPob && extractedPob) checks.add(pobOk);
    if (hasNat) checks.add(natOk);
    final matches = checks.where((v) => v).length;
    final requiresCore = nameOk || dobOk;

    final minMatches = switch (docType) {
      OfficialDocumentType.passport => 1,
      OfficialDocumentType.nationalId => 1,
      OfficialDocumentType.other => 1,
    };

    final cappedMin = minMatches.clamp(1, checks.length);
    final ok = requiresCore && matches >= cappedMin && !foreignDetected;

    final issues = <String>[];
    if (!nameOk) issues.add('Name mismatch');
    if (!dobOk) issues.add('Date of birth mismatch');
    if (hasPob && extractedPob && !pobOk) {
      issues.add('Place of birth mismatch');
    }
    if (hasNat && !natOk) issues.add('Nationality mismatch');
    if (foreignDetected) issues.add('Foreign document detected');

    final pendingNote = cameroonFlag == null
        ? 'Nationality pending admin review'
        : null;
    final summary = ok
        ? (pendingNote == null ? 'Verified' : 'Verified • $pendingNote')
        : [
            if (issues.isNotEmpty) issues.join(' • '),
            if (pendingNote != null) pendingNote,
          ].where((s) => s.isNotEmpty).join(' • ');

    return OcrValidationResult(
      ok: ok,
      summary: summary,
      nameOk: nameOk,
      dobOk: dobOk,
      pobOk: pobOk,
      nationalityOk: !foreignDetected,
    );
  }

  // ------------------------ helpers ------------------------

  static DateTime? _findFirstDate(List<String> lines) {
    // Supports: dd/mm/yyyy, dd-mm-yyyy, dd.mm.yyyy, dd mm yyyy, yyyy-mm-dd
    final patterns = <RegExp>[
      RegExp(r'\b(\d{2})[\/\.\-](\d{2})[\/\.\-](\d{4})\b'),
      RegExp(r'\b(\d{2})[\/\.\-](\d{2})[\/\.\-](\d{2})\b'),
      RegExp(r'\b(\d{2})\s+(\d{2})\s+(\d{4})\b'),
      RegExp(r'\b(\d{4})\s+(\d{2})\s+(\d{2})\b'),
      RegExp(r'\b(\d{4})[\/\.\-](\d{2})[\/\.\-](\d{2})\b'),
    ];
    for (final line in lines) {
      for (final p in patterns) {
        final m = p.firstMatch(line);
        if (m == null) continue;

        try {
          if (m.groupCount == 3) {
            final a = int.parse(m.group(1)!);
            final b = int.parse(m.group(2)!);
            final cRaw = int.parse(m.group(3)!);
            final c = cRaw < 100
                ? (cRaw >= 50 ? 1900 + cRaw : 2000 + cRaw)
                : cRaw;
            if (c > 1900 && a <= 31) {
              // dd/mm/yyyy
              return DateTime(c, b, a);
            }
            if (a > 1900) {
              // yyyy/mm/dd
              return DateTime(a, b, c);
            }
          }
        } catch (_) {}
      }
    }
    return null;
  }

  static DateTime? _parseDateFromText(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final cleaned = raw.replaceAll(RegExp(r'[^\w\/\.\-\s]'), ' ');
    return _findFirstDate([cleaned]) ?? _findMonthNameDate(cleaned);
  }

  static DateTime? _findMonthNameDate(String raw) {
    final normalized = _normalize(raw);
    if (normalized.isEmpty) return null;

    final monthMap = <String, int>{
      'JAN': 1,
      'JANVIER': 1,
      'JANV': 1,
      'FEB': 2,
      'FEV': 2,
      'FEVR': 2,
      'FEVRIER': 2,
      'FÉV': 2,
      'FEBRUARY': 2,
      'MAR': 3,
      'MARS': 3,
      'APR': 4,
      'AVR': 4,
      'AVRIL': 4,
      'APRIL': 4,
      'MAY': 5,
      'MAI': 5,
      'JUN': 6,
      'JUIN': 6,
      'JUNE': 6,
      'JUL': 7,
      'JUIL': 7,
      'JUILLET': 7,
      'JULY': 7,
      'AUG': 8,
      'AOUT': 8,
      'AOÛT': 8,
      'AUGUST': 8,
      'SEP': 9,
      'SEPT': 9,
      'SEPTEMBRE': 9,
      'SEPTEMBER': 9,
      'OCT': 10,
      'OCTOBRE': 10,
      'OCTOBER': 10,
      'NOV': 11,
      'NOVEMBRE': 11,
      'NOVEMBER': 11,
      'DEC': 12,
      'DECEMBRE': 12,
      'DECEMBER': 12,
    };

    final tokens = normalized.split(' ');
    for (var i = 0; i + 2 < tokens.length; i++) {
      final day = int.tryParse(tokens[i]);
      final monthToken = tokens[i + 1];
      final year = int.tryParse(tokens[i + 2]);
      if (day == null || year == null) continue;
      final month =
          monthMap[monthToken] ??
          monthMap[monthToken.substring(0, min(3, monthToken.length))];
      if (month == null) continue;
      if (year < 100) {
        final resolved = year >= 50 ? 1900 + year : 2000 + year;
        return DateTime(resolved, month, day);
      }
      return DateTime(year, month, day);
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
          // Try same-line after label without colon
          final cleaned = line
              .replaceFirst(label, '')
              .replaceFirst(RegExp(r'^[:\-\s]+'), '')
              .trim();
          if (cleaned.isNotEmpty) return cleaned;
          // Otherwise next non-empty line
          for (var j = i + 1; j < lines.length; j++) {
            final candidate = lines[j].trim();
            if (candidate.isNotEmpty) return candidate;
          }
        }
      }
    }
    return null;
  }

  static String? _guessName(List<String> lines) {
    final candidates = <String>[];
    for (final line in lines) {
      final normalized = _normalize(line);
      if (normalized.isEmpty) continue;
      if (RegExp(r'\d').hasMatch(normalized)) continue;
      if (_isDocumentHeader(normalized)) continue;
      final tokens = normalized.split(' ').where((t) => t.length >= 2).toList();
      if (tokens.length < 2) continue;
      candidates.add(line.trim());
    }
    if (candidates.isEmpty) return null;
    candidates.sort(
      (a, b) => _normalize(b).length.compareTo(_normalize(a).length),
    );
    return candidates.first;
  }

  static bool _isDocumentHeader(String normalized) {
    const headerTokens = [
      'REPUBLIQUE',
      'REPUBLIC',
      'CAMEROUN',
      'CAMEROON',
      'CARTE',
      'IDENTITE',
      'NATIONALE',
      'PASSPORT',
      'PASSEPORT',
      'ELECTORAL',
      'ELECTEUR',
      'CNI',
    ];
    return headerTokens.any(normalized.contains);
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
    if (expected.year != got.year) return false;
    if (expected.month == got.month && expected.day == got.day) return true;
    if (expected.month == got.day && expected.day == got.month) return true;
    if (expected.month == got.month && (expected.day - got.day).abs() <= 1) {
      return true;
    }
    return false;
  }

  static bool _tokenOverlapMatch(
    String expected,
    String? got, {
    double minScore = 0.7,
  }) {
    if (got == null) return false;
    final a = _normalize(
      expected,
    ).split(' ').where((e) => e.length >= 2).toSet();
    final b = _normalize(got).split(' ').where((e) => e.length >= 2).toSet();
    if (a.isEmpty || b.isEmpty) return false;
    final inter = a.intersection(b).length;
    final score = inter / max(1, min(a.length, b.length));
    return score >= minScore;
  }

  static bool _fuzzyNameMatch(String expected, String? got) {
    if (got == null) return false;
    // Tolerant match: accept 35% token overlap for noisy OCR.
    return _tokenOverlapMatch(expected, got, minScore: 0.35);
  }

  static bool? _cameroonDocFlag(String? nationality, String rawText) {
    final nat = nationality?.trim() ?? '';
    if (nat.isNotEmpty) {
      return _isCameroonNationality(nat);
    }
    if (_containsCameroonMarkers(rawText)) {
      return true;
    }
    return null;
  }

  static bool _isCameroonNationality(String value) {
    final v = _normalizeLoose(value).replaceAll(' ', '');
    const tokens = {
      'CMR',
      'CM',
      'CAMEROUN',
      'CAMEROON',
      'CAMEROUNAIS',
      'CAMEROUNAISE',
      'CAMEROONIAN',
      'REPUBLIQUEDUCAMEROUN',
      'REPUBLICOFCAMEROON',
    };
    return tokens.any(v.contains);
  }

  static bool _containsCameroonMarkers(String raw) {
    final v = _normalizeLoose(raw);
    final markers = [
      'REPUBLIQUE DU CAMEROUN',
      'REPUBLIC OF CAMEROON',
      'CAMEROUN',
      'CAMEROON',
      'CARTE NATIONALE',
      'CARTE NATIONALE D IDENTITE',
      'CARTE NATIONALE DIDENTITE',
      'CARTE D IDENTITE',
      'CARTE IDENTITE',
      'CNI',
      'CARTE D ELECTEUR',
      'CARTE ELECTORALE',
      'ELECTEUR',
      'ELECTORAL CARD',
      'CMR',
    ];
    return markers.any(v.contains);
  }

  static String? _mergeNameParts(String? surname, String? given) {
    final s = _cleanValue(surname);
    final g = _cleanValue(given);
    if (s == null && g == null) return null;
    if (s != null && g != null) return '$s $g'.trim();
    return s ?? g;
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

  static String _normalizeLoose(String input) {
    final normalized = _normalize(input);
    const digitMap = {
      '0': 'O',
      '1': 'I',
      '2': 'Z',
      '4': 'A',
      '5': 'S',
      '6': 'G',
      '8': 'B',
      '9': 'G',
    };
    final b = StringBuffer();
    for (final ch in normalized.split('')) {
      b.write(digitMap[ch] ?? ch);
    }
    return b.toString();
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
