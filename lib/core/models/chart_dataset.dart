class ChartPoint {
  const ChartPoint({required this.label, required this.count});

  final String label;
  final int count;
}

class ChartDataset {
  const ChartDataset({required this.points});

  final List<ChartPoint> points;
}
