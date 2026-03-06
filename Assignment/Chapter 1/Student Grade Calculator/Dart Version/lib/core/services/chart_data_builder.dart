import '../models/chart_dataset.dart';
import '../models/grade_config.dart';
import '../models/processing_report.dart';

class ChartDataBuilder {
  const ChartDataBuilder();

  ChartDataset buildGradeDistribution(ProcessingReport report) {
    // The chart builder only transforms graded data, so the UI never has to know the raw map structure.
    final points = report.summary.gradeCounts.entries
        .where((entry) => entry.value > 0)
        .map((entry) => ChartPoint(label: entry.key.label, count: entry.value))
        .toList();

    return ChartDataset(points: points);
  }
}

