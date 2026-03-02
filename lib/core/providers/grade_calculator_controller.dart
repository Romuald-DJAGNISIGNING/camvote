import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/chart_dataset.dart';
import '../models/processing_report.dart';
import '../services/chart_data_builder.dart';
import '../services/file_import_service.dart';
import '../services/grading_engine.dart';
import '../services/workbook_export_service.dart';

class GradeCalculatorState {
  const GradeCalculatorState({
    this.loading = false,
    this.sourcePath,
    this.report,
    this.error,
    this.lastExportPath,
  });

  final bool loading;
  final String? sourcePath;
  final ProcessingReport? report;
  final String? error;
  final String? lastExportPath;

  GradeCalculatorState copyWith({
    bool? loading,
    String? sourcePath,
    ProcessingReport? report,
    String? error,
    String? lastExportPath,
  }) {
    return GradeCalculatorState(
      loading: loading ?? this.loading,
      sourcePath: sourcePath ?? this.sourcePath,
      report: report ?? this.report,
      error: error,
      lastExportPath: lastExportPath ?? this.lastExportPath,
    );
  }
}

class GradeCalculatorController extends Notifier<GradeCalculatorState> {
  final FileImportService _fileImportService = const FileImportService();
  final GradingEngine _gradingEngine = const GradingEngine();
  final WorkbookExportService _exportService = const WorkbookExportService();
  final ChartDataBuilder _chartBuilder = const ChartDataBuilder();

  @override
  GradeCalculatorState build() => const GradeCalculatorState();

  Future<void> importAndProcess() async {
    state = state.copyWith(loading: true, error: null, lastExportPath: null);

    try {
      final picked = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['csv', 'xlsx'],
        lockParentWindow: true,
      );

      final path = picked?.files.single.path;
      if (path == null) {
        state = state.copyWith(loading: false);
        return;
      }

      final rows = await _fileImportService.parseFile(path);
      final report = _gradingEngine.batchGrade(rows);

      state = state.copyWith(
        loading: false,
        sourcePath: path,
        report: report,
        error: null,
      );
    } catch (error) {
      state = state.copyWith(
        loading: false,
        error: error.toString(),
      );
    }
  }

  Future<void> exportWorkbook() async {
    final report = state.report;
    if (report == null) {
      return;
    }

    state = state.copyWith(loading: true, error: null);

    try {
      final selectedPath = await FilePicker.platform.saveFile(
        dialogTitle: 'Save designed grade workbook',
        fileName: 'student_grade_report.xlsx',
        type: FileType.custom,
        allowedExtensions: const ['xlsx'],
        lockParentWindow: true,
      );

      if (selectedPath == null) {
        state = state.copyWith(loading: false);
        return;
      }

      final finalPath = selectedPath.toLowerCase().endsWith('.xlsx')
          ? selectedPath
          : '$selectedPath.xlsx';

      final exportResult = await _exportService.export(report, finalPath);

      state = state.copyWith(
        loading: false,
        lastExportPath: exportResult.path,
      );
    } catch (error) {
      state = state.copyWith(
        loading: false,
        error: error.toString(),
      );
    }
  }

  ChartDataset buildChartDataset() {
    final report = state.report;
    if (report == null) {
      return const ChartDataset(points: []);
    }
    return _chartBuilder.buildGradeDistribution(report);
  }

  String get sourceFileName {
    final sourcePath = state.sourcePath;
    if (sourcePath == null || sourcePath.isEmpty) {
      return 'No file imported';
    }
    return File(sourcePath).uri.pathSegments.last;
  }
}

final gradeCalculatorProvider =
    NotifierProvider<GradeCalculatorController, GradeCalculatorState>(
  GradeCalculatorController.new,
);
