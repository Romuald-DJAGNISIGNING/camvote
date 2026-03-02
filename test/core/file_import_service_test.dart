import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:student_gradecalc_dart/core/services/file_import_service.dart';

void main() {
  group('FileImportService CSV parser', () {
    test('maps aliases and parses comma decimals as strings', () async {
      final tempDir = await Directory.systemTemp.createTemp('gradecalc_csv_test');
      final file = File('${tempDir.path}/input.csv');

      await file.writeAsString('Name,Matricule,CA,Exam,Total\nAlice,MAT001,20,45,\nBob,MAT002,,,"72,5"\n');

      final service = FileImportService();
      final rows = await service.parseCsv(file.path);

      expect(rows.length, 2);
      expect(rows.first.name, 'Alice');
      expect(rows.first.matricule, 'MAT001');
      expect(rows.first.ca, '20');
      expect(rows[1].total, '72,5');
    });
  });
}
