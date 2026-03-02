import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/grade_calculator_controller.dart';

class ExportActions extends ConsumerWidget {
  const ExportActions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gradeCalculatorProvider);
    final controller = ref.read(gradeCalculatorProvider.notifier);

    final canExport = state.report != null && !state.loading;

    return Align(
      alignment: Alignment.centerRight,
      child: FilledButton.icon(
        onPressed: canExport ? controller.exportWorkbook : null,
        icon: const Icon(Icons.file_download_done_rounded),
        label: const Text('Export Styled Workbook'),
      ),
    );
  }
}
