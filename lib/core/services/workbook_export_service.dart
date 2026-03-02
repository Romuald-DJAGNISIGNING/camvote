import 'dart:io';

import 'package:excel/excel.dart';

import '../models/grade_config.dart';
import '../models/processing_report.dart';
import '../models/validation_issue.dart';

class ExportResult {
  const ExportResult({required this.path, required this.sizeBytes});

  final String path;
  final int sizeBytes;
}

class WorkbookExportService {
  const WorkbookExportService();

  Future<ExportResult> export(ProcessingReport report, String destinationPath) async {
    final excel = Excel.createExcel();
    excel.delete('Sheet1');

    final gradesSheet = excel['Grades'];
    final summarySheet = excel['Summary'];
    final issuesSheet = excel['Issues'];
    final chartSheet = excel['ChartData'];

    _fillGrades(gradesSheet, report);
    _fillSummary(summarySheet, report);
    _fillIssues(issuesSheet, report);
    _fillChartData(chartSheet, report);

    final bytes = excel.save();
    if (bytes == null) {
      throw StateError('Could not generate workbook bytes.');
    }

    final file = File(destinationPath);
    await file.parent.create(recursive: true);
    await file.writeAsBytes(bytes, flush: true);

    return ExportResult(path: destinationPath, sizeBytes: bytes.length);
  }

  void _fillGrades(Sheet sheet, ProcessingReport report) {
    final headers = [
      'Row',
      'Name',
      'Matricule',
      'Final Score',
      'Letter',
      'Pass',
      'Status',
      'Source',
      'Reasons',
    ];

    _appendHeader(sheet, headers);

    for (final result in report.results) {
      sheet.appendRow([
        IntCellValue(result.rowIndex),
        TextCellValue(result.name ?? ''),
        TextCellValue(result.matricule ?? ''),
        result.finalScore == null
            ? TextCellValue('')
            : DoubleCellValue(result.finalScore!),
        TextCellValue(result.letter.label),
        TextCellValue(result.pass ? 'YES' : 'NO'),
        TextCellValue(result.status.name.toUpperCase()),
        TextCellValue(result.source),
        TextCellValue(result.reasons.join(' | ')),
      ]);
    }

    for (var row = 1; row < sheet.maxRows; row++) {
      final gradeCell = sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: row));
      final grade = gradeCell.value?.toString() ?? '';
      final rowStyle = _styleForGrade(grade);
      for (var col = 0; col < headers.length; col++) {
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row))
            .cellStyle = rowStyle;
      }
    }
  }

  void _fillSummary(Sheet sheet, ProcessingReport report) {
    _appendHeader(sheet, ['Metric', 'Value']);
    final summary = report.summary;

    sheet.appendRow([
      TextCellValue('Total Rows'),
      IntCellValue(summary.totalRows),
    ]);
    sheet.appendRow([
      TextCellValue('Graded Rows'),
      IntCellValue(summary.gradedRows),
    ]);
    sheet.appendRow([
      TextCellValue('Unknown Rows'),
      IntCellValue(summary.unknownRows),
    ]);
    sheet.appendRow([
      TextCellValue('Average Score'),
      DoubleCellValue(summary.average),
    ]);
    sheet.appendRow([
      TextCellValue('Median Score'),
      DoubleCellValue(summary.median),
    ]);
    sheet.appendRow([
      TextCellValue('Pass Rate %'),
      DoubleCellValue(summary.passRate),
    ]);

    sheet.appendRow([TextCellValue(''), TextCellValue('')]);
    _appendHeader(sheet, ['Grade', 'Count']);
    for (final entry in summary.gradeCounts.entries) {
      sheet.appendRow([
        TextCellValue(entry.key.label),
        IntCellValue(entry.value),
      ]);
    }
  }

  void _fillIssues(Sheet sheet, ProcessingReport report) {
    _appendHeader(sheet, ['Row', 'Severity', 'Code', 'Message']);
    for (final issue in report.issues) {
      sheet.appendRow([
        IntCellValue(issue.rowIndex),
        TextCellValue(issue.severity.name.toUpperCase()),
        TextCellValue(issue.code),
        TextCellValue(issue.message),
      ]);

      final targetRow = sheet.maxRows - 1;
      final style = _styleForSeverity(issue.severity);
      for (var col = 0; col < 4; col++) {
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: targetRow))
            .cellStyle = style;
      }
    }
  }

  void _fillChartData(Sheet sheet, ProcessingReport report) {
    _appendHeader(sheet, ['Grade', 'Count']);
    for (final entry in report.summary.gradeCounts.entries) {
      sheet.appendRow([
        TextCellValue(entry.key.label),
        IntCellValue(entry.value),
      ]);
    }
  }

  void _appendHeader(Sheet sheet, List<String> titles) {
    sheet.appendRow(titles.map(TextCellValue.new).toList(growable: false));
    final headerRow = sheet.maxRows - 1;
    final style = CellStyle(
      bold: true,
      fontColorHex: ExcelColor.white,
      backgroundColorHex: '#103B67'.excelColor,
      horizontalAlign: HorizontalAlign.Center,
    );

    for (var col = 0; col < titles.length; col++) {
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: headerRow))
          .cellStyle = style;
    }
  }

  CellStyle _styleForGrade(String grade) {
    final fill = switch (grade) {
      'A' || 'B+' || 'B' => '#D7FBE8'.excelColor,
      'C+' || 'C' => '#FFF4CC'.excelColor,
      'D+' || 'D' => '#FFE2B5'.excelColor,
      'F' || 'X' => '#FFD6D6'.excelColor,
      _ => ExcelColor.none,
    };

    return CellStyle(backgroundColorHex: fill);
  }

  CellStyle _styleForSeverity(IssueSeverity severity) {
    final fill = switch (severity) {
      IssueSeverity.error => '#FFD6D6'.excelColor,
      IssueSeverity.warning => '#FFF4CC'.excelColor,
      IssueSeverity.info => '#DCEBFF'.excelColor,
    };

    return CellStyle(backgroundColorHex: fill);
  }
}



