import 'dart:io';

import 'package:student_gradecalc_dart/core/models/grade_config.dart';
import 'package:student_gradecalc_dart/core/models/processing_report.dart';
import 'package:student_gradecalc_dart/core/services/file_import_service.dart';
import 'package:student_gradecalc_dart/core/services/grading_engine.dart';
import 'package:student_gradecalc_dart/core/services/workbook_export_service.dart';

Future<void> main(List<String> args) async {
  final options = _CliOptions.parse(args);
  if (options.showHelp ||
      options.inputPath == null ||
      options.outputPath == null) {
    _printUsage();
    exit(options.showHelp ? 0 : 1);
  }

  final importService = const FileImportService();
  final gradingEngine = const GradingEngine();
  final exporter = const WorkbookExportService();

  try {
    final rows = await importService.parseFile(options.inputPath!);
    final report = gradingEngine.batchGrade(rows);
    final result = await exporter.export(report, options.outputPath!);
    _printSummary(report, result.sizeBytes);
  } on UnsupportedError catch (error) {
    stderr.writeln('Input error: ${error.message}');
    exit(2);
  } on FileSystemException catch (error) {
    stderr.writeln('File error: ${error.message}');
    exit(2);
  } catch (error) {
    stderr.writeln('Unexpected error: $error');
    exit(3);
  }
}

void _printSummary(ProcessingReport report, int sizeBytes) {
  final summary = report.summary;
  final distribution = summary.gradeCounts.entries
      .where((entry) => entry.value > 0)
      .map((entry) => '${entry.key.label}:${entry.value}')
      .join(', ');

  stdout.writeln('Processed ${summary.totalRows} rows.');
  stdout.writeln(
    'Graded: ${summary.gradedRows} | Unknown: ${summary.unknownRows}',
  );
  stdout.writeln(
    'Average: ${summary.average.toStringAsFixed(2)} | Median: ${summary.median.toStringAsFixed(2)} | Pass Rate: ${summary.passRate.toStringAsFixed(2)}%',
  );
  stdout.writeln('Issues: ${report.issues.length}');
  stdout.writeln('Grade distribution: $distribution');
  stdout.writeln(
    'Workbook generated (${(sizeBytes / 1024).toStringAsFixed(1)} KB).',
  );
}

void _printUsage() {
  stdout.writeln('Student Grade Calculator CLI (Dart)');
  stdout.writeln('Usage:');
  stdout.writeln(
    '  dart run bin/gradecalc_cli.dart --input <file.csv|file.xlsx> --output <result.xlsx>',
  );
  stdout.writeln('Options:');
  stdout.writeln('  --input, -i   Source dataset path');
  stdout.writeln('  --output, -o  Destination xlsx path');
  stdout.writeln('  --help, -h    Show this help');
}

class _CliOptions {
  const _CliOptions({
    required this.inputPath,
    required this.outputPath,
    required this.showHelp,
  });

  final String? inputPath;
  final String? outputPath;
  final bool showHelp;

  static _CliOptions parse(List<String> args) {
    String? input;
    String? output;
    var showHelp = false;

    for (var i = 0; i < args.length; i++) {
      final arg = args[i];
      if (arg == '--help' || arg == '-h') {
        showHelp = true;
      } else if (arg == '--input' || arg == '-i') {
        if (i + 1 < args.length) {
          input = args[++i];
        }
      } else if ((arg == '--output' || arg == '-o') && i + 1 < args.length) {
        output = args[++i];
      }
    }

    return _CliOptions(
      inputPath: input,
      outputPath: output,
      showHelp: showHelp,
    );
  }
}
