import 'package:flutter_test/flutter_test.dart';

import 'package:student_gradecalc_dart/core/models/grade_config.dart';
import 'package:student_gradecalc_dart/core/models/student_input_row.dart';
import 'package:student_gradecalc_dart/core/services/grading_engine.dart';

void main() {
  group('GradingEngine', () {
    final engine = GradingEngine(config: GradingConfig.strictDefault);

    test('applies weighted fallback when CA/Exam are 0..100 values', () {
      final report = engine.batchGrade([
        const StudentInputRow(
          rowIndex: 2,
          name: 'Alice',
          matricule: 'MAT001',
          ca: '80',
          exam: '90',
          total: null,
          rawValues: {},
        ),
      ]);

      expect(report.results.single.finalScore, closeTo(87, 0.01));
      expect(report.results.single.letter, LetterGrade.a);
      expect(report.results.single.pass, isTrue);
    });

    test('uses raw CA+Exam when ranges are 0..30 and 0..70', () {
      final report = engine.batchGrade([
        const StudentInputRow(
          rowIndex: 3,
          name: 'Bob',
          matricule: 'MAT002',
          ca: '28',
          exam: '61',
          total: null,
          rawValues: {},
        ),
      ]);

      expect(report.results.single.finalScore, 89);
      expect(report.results.single.letter, LetterGrade.a);
    });

    test('uses total fallback when CA/Exam incomplete', () {
      final report = engine.batchGrade([
        const StudentInputRow(
          rowIndex: 4,
          name: 'Chris',
          matricule: 'MAT003',
          ca: '20',
          exam: null,
          total: '66',
          rawValues: {},
        ),
      ]);

      final result = report.results.single;
      expect(result.finalScore, 66);
      expect(result.letter, LetterGrade.c);
      expect(report.issues.any((i) => i.code == 'FALLBACK_TOTAL'), isTrue);
    });

    test('marks row as X when score source is invalid', () {
      final report = engine.batchGrade([
        const StudentInputRow(
          rowIndex: 5,
          name: 'Dina',
          matricule: 'MAT004',
          ca: 'abc',
          exam: 'def',
          total: null,
          rawValues: {},
        ),
      ]);

      final result = report.results.single;
      expect(result.letter, LetterGrade.x);
      expect(result.finalScore, isNull);
      expect(result.status.name, 'unknown');
    });

    test('keeps latest duplicate and logs warning', () {
      final report = engine.batchGrade([
        const StudentInputRow(
          rowIndex: 6,
          name: 'Eva',
          matricule: 'MAT005',
          ca: '20',
          exam: '30',
          total: null,
          rawValues: {},
        ),
        const StudentInputRow(
          rowIndex: 7,
          name: 'Eva New',
          matricule: 'MAT005',
          ca: '25',
          exam: '35',
          total: null,
          rawValues: {},
        ),
      ]);

      expect(report.results.length, 1);
      expect(report.results.single.rowIndex, 7);
      expect(report.issues.any((i) => i.code == 'DUPLICATE'), isTrue);
    });
  });
}
