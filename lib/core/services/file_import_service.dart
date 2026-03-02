import 'dart:io';

import 'package:csv/csv.dart';
import 'package:excel/excel.dart';

import '../models/student_input_row.dart';
import 'column_mapping_config.dart';

class FileImportService {
  const FileImportService({this.mapping = ColumnMappingConfig.defaults});

  final ColumnMappingConfig mapping;

  Future<List<StudentInputRow>> parseFile(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.csv')) {
      return parseCsv(path);
    }
    if (lower.endsWith('.xlsx')) {
      return parseXlsx(path);
    }
    throw UnsupportedError('Only .csv and .xlsx are supported.');
  }

  Future<List<StudentInputRow>> parseCsv(String path) async {
    final content = await File(path).readAsString();
    final rows = csv.decode(content);

    if (rows.isEmpty) {
      return const [];
    }

    final headers = rows.first.map((value) => value.toString()).toList();
    final output = <StudentInputRow>[];

    for (var i = 1; i < rows.length; i++) {
      output.add(_rowFromCells(i + 1, headers, rows[i]));
    }

    return output;
  }

  Future<List<StudentInputRow>> parseXlsx(String path) async {
    final bytes = await File(path).readAsBytes();
    final workbook = Excel.decodeBytes(bytes);
    if (workbook.tables.isEmpty) {
      return const [];
    }

    final sheet = workbook.tables.values.first;
    final rows = sheet.rows;
    if (rows.isEmpty) {
      return const [];
    }

    final headers = rows.first
        .map((cell) => cell?.value?.toString() ?? '')
        .toList(growable: false);

    final output = <StudentInputRow>[];
    for (var i = 1; i < rows.length; i++) {
      final rowCells = rows[i]
          .map((cell) => cell?.value?.toString() ?? '')
          .toList(growable: false);
      output.add(_rowFromCells(i + 1, headers, rowCells));
    }

    return output;
  }

  StudentInputRow _rowFromCells(int rowIndex, List<String> headers, List<dynamic> row) {
    final raw = <String, String?>{};
    for (var i = 0; i < headers.length; i++) {
      final value = i < row.length ? row[i]?.toString() : null;
      raw[headers[i]] = value?.trim().isEmpty == true ? null : value?.trim();
    }

    String? findByCanonical(String key) {
      for (final entry in raw.entries) {
        final canonical = mapping.resolveCanonical(entry.key);
        if (canonical == key) {
          return entry.value;
        }
      }
      return null;
    }

    return StudentInputRow(
      rowIndex: rowIndex,
      name: findByCanonical('name'),
      matricule: findByCanonical('matricule'),
      ca: findByCanonical('ca'),
      exam: findByCanonical('exam'),
      total: findByCanonical('total'),
      rawValues: raw,
    );
  }
}

