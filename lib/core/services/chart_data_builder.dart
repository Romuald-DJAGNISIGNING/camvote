import '../models/chart_dataset.dart';
import '../models/grade_config.dart';
import '../models/processing_report.dart';

class ChartDataBuilder {
  const ChartDataBuilder();

  ChartDataset buildGradeDistribution(ProcessingReport report) {
    final points = report.summary.gradeCounts.entries
        .where((entry) => entry.value > 0)
        .map((entry) => ChartPoint(label: entry.key.label, count: entry.value))
        .toList();

    return ChartDataset(points: points);
  }
}

