import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/models/chart_dataset.dart';
import '../../../core/models/grade_config.dart';
import '../../../core/models/grade_result.dart';
import '../../../core/models/validation_issue.dart';
import '../../../core/providers/grade_calculator_controller.dart';

class ResultsDashboard extends ConsumerWidget {
  const ResultsDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gradeCalculatorProvider);
    final controller = ref.read(gradeCalculatorProvider.notifier);
    final report = state.report;

    if (report == null) {
      return const SizedBox.shrink();
    }

    final chart = controller.buildChartDataset();
    final summary = report.summary;
    final formatter = NumberFormat('0.00');

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 450),
      child: Column(
        key: ValueKey(summary.totalRows),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _metricCard('Rows', summary.totalRows.toString(), const Color(0xFF0E5A8A)),
              _metricCard('Average', formatter.format(summary.average), const Color(0xFF2C8E5A)),
              _metricCard('Median', formatter.format(summary.median), const Color(0xFF7A5C00)),
              _metricCard('Pass Rate', '${formatter.format(summary.passRate)}%', const Color(0xFF7B2CBF)),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 6,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                height: 260,
                child: Row(
                  children: [
                    Expanded(child: _buildPieChart(chart)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildLegend(chart)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 6,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _buildTopTable(report.results),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 6,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _buildIssues(report.issues),
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricCard(String label, String value, Color accent) {
    return Container(
      width: 190,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [accent.withValues(alpha: 0.92), accent.withValues(alpha: 0.75)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 22,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart(ChartDataset chart) {
    if (chart.points.isEmpty) {
      return const Center(child: Text('No chart data yet'));
    }

    final colors = <Color>[
      const Color(0xFF2C8E5A),
      const Color(0xFF1A73E8),
      const Color(0xFF7B2CBF),
      const Color(0xFFD97706),
      const Color(0xFF6B7280),
      const Color(0xFFB91C1C),
      const Color(0xFF8B5CF6),
      const Color(0xFF047857),
      const Color(0xFF111827),
    ];

    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 42,
        sections: chart.points.asMap().entries.map((entry) {
          final index = entry.key;
          final point = entry.value;
          return PieChartSectionData(
            title: point.label,
            value: point.count.toDouble(),
            radius: 80,
            color: colors[index % colors.length],
            titleStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        }).toList(growable: false),
      ),
    );
  }

  Widget _buildLegend(ChartDataset chart) {
    if (chart.points.isEmpty) {
      return const SizedBox.shrink();
    }

    final total = chart.points.fold<int>(0, (sum, point) => sum + point.count);

    return ListView.builder(
      itemCount: chart.points.length,
      itemBuilder: (context, index) {
        final point = chart.points[index];
        final ratio = total == 0 ? 0 : (point.count / total) * 100;
        return ListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          title: Text('Grade ${point.label}'),
          trailing: Text('${point.count} (${ratio.toStringAsFixed(1)}%)'),
        );
      },
    );
  }

  Widget _buildTopTable(List<GradeResult> results) {
    final preview = results.take(12).toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Top Preview Rows',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Row')),
              DataColumn(label: Text('Name')),
              DataColumn(label: Text('Matricule')),
              DataColumn(label: Text('Score')),
              DataColumn(label: Text('Letter')),
              DataColumn(label: Text('Pass')),
              DataColumn(label: Text('Source')),
            ],
            rows: preview
                .map(
                  (result) => DataRow(cells: [
                    DataCell(Text(result.rowIndex.toString())),
                    DataCell(Text(result.name ?? '-')),
                    DataCell(Text(result.matricule ?? '-')),
                    DataCell(Text(result.finalScore?.toStringAsFixed(2) ?? '-')),
                    DataCell(Text(result.letter.label)),
                    DataCell(Text(result.pass ? 'Yes' : 'No')),
                    DataCell(Text(result.source)),
                  ]),
                )
                .toList(growable: false),
          ),
        ),
      ],
    );
  }

  Widget _buildIssues(List<ValidationIssue> issues) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Validation & Processing Issues',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        if (issues.isEmpty)
          const Text('No issues detected.')
        else
          SizedBox(
            height: 200,
            child: ListView.separated(
              itemCount: issues.length,
              separatorBuilder: (context, index) => const Divider(height: 8),
              itemBuilder: (context, index) {
                final issue = issues[index];
                final accent = switch (issue.severity) {
                  IssueSeverity.error => const Color(0xFFB71C1C),
                  IssueSeverity.warning => const Color(0xFFB26A00),
                  IssueSeverity.info => const Color(0xFF0E5A8A),
                };
                return Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.report_gmailerrorred_rounded, color: accent),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '[Row ${issue.rowIndex}] ${issue.code}: ${issue.message}',
                          style: TextStyle(color: accent, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}



