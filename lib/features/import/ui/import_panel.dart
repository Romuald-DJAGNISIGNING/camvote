import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/grade_calculator_controller.dart';

class ImportPanel extends ConsumerWidget {
  const ImportPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gradeCalculatorProvider);
    final controller = ref.read(gradeCalculatorProvider.notifier);

    return Card(
      color: Colors.white.withValues(alpha: 0.92),
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Import Student Marks',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            const Text(
              'Supported formats: CSV and XLSX. Duplicates are auto-handled and logged.',
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                FilledButton.icon(
                  onPressed: state.loading ? null : controller.importAndProcess,
                  icon: const Icon(Icons.upload_file_rounded),
                  label: const Text('Choose File & Process'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    controller.sourceFileName,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            if (state.error != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  state.error!,
                  style: const TextStyle(color: Color(0xFFB71C1C)),
                ),
              ),
            ],
            if (state.lastExportPath != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Exported workbook: ${state.lastExportPath}',
                  style: const TextStyle(color: Color(0xFF1B5E20)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

