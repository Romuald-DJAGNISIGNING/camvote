import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:camvote/gen/l10n/app_localizations.dart';

import '../utils/candidate_metric.dart';

enum _ChartKind { bar, pie, line }

/// Drop-in widget for Public Results:
/// - Bar chart (votes per candidate)
/// - Pie chart (vote share)
/// - Line chart (turnout trend / stats trend)
///
/// Pure Flutter (CustomPainter) => no fl_chart params, no deprecations.
class ResultsCharts extends StatefulWidget {
  const ResultsCharts({
    super.key,
    required this.candidates,
    this.turnoutTrend, // 0..100 values or null (line chart hidden if null/short)
    this.watermarkTitle,
    this.watermarkSubtitle,
  });

  final List<CandidateMetric> candidates;

  /// Optional turnout trend in percent (e.g. [2.0, 8.4, 12.1, ...]).
  /// If null or < 2 points, the line chart shows an empty state.
  final List<double>? turnoutTrend;

  /// Subtle watermark overlay (e.g. "CamVote")
  final String? watermarkTitle;

  /// Subtle watermark subtitle (e.g. slogan)
  final String? watermarkSubtitle;

  @override
  State<ResultsCharts> createState() => _ResultsChartsState();
}

class _ResultsChartsState extends State<ResultsCharts> {
  _ChartKind _kind = _ChartKind.bar;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = AppLocalizations.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header + segmented control
            Row(
              children: [
                Expanded(
                  child: Text(
                    t.chartsTab,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                SegmentedButton<_ChartKind>(
                  segments: [
                    ButtonSegment(
                      value: _ChartKind.bar,
                      label: Text(t.chartBarLabel),
                      icon: const Icon(Icons.bar_chart_rounded),
                    ),
                    ButtonSegment(
                      value: _ChartKind.pie,
                      label: Text(t.chartPieLabel),
                      icon: const Icon(Icons.pie_chart_rounded),
                    ),
                    ButtonSegment(
                      value: _ChartKind.line,
                      label: Text(t.chartLineLabel),
                      icon: const Icon(Icons.show_chart_rounded),
                    ),
                  ],
                  selected: {_kind},
                  showSelectedIcon: false,
                  onSelectionChanged: (s) {
                    setState(() => _kind = s.first);
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Animated chart switch
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 420),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, anim) {
                final fade = FadeTransition(opacity: anim, child: child);
                final scale = ScaleTransition(
                  scale: Tween<double>(begin: 0.98, end: 1).animate(anim),
                  child: fade,
                );
                return scale;
              },
              child: _buildChart(context, key: ValueKey(_kind)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart(BuildContext context, {required Key key}) {
    final candidates = widget.candidates;
    final t = AppLocalizations.of(context);
    final hasCandidates = candidates.isNotEmpty;

    final trend =
        (widget.turnoutTrend != null && widget.turnoutTrend!.length >= 2)
        ? widget.turnoutTrend!
        : const <double>[];

    switch (_kind) {
      case _ChartKind.bar:
        if (!hasCandidates) {
          return _EmptyChart(key: key, height: 260, message: t.noData);
        }
        return _ChartFrame(
          key: key,
          height: 260,
          child: _AnimatedChart(
            child: CamBarChart(
              candidates: candidates,
              watermarkTitle: widget.watermarkTitle,
              watermarkSubtitle: widget.watermarkSubtitle,
            ),
          ),
        );

      case _ChartKind.pie:
        if (!hasCandidates) {
          return _EmptyChart(key: key, height: 260, message: t.noData);
        }
        return _ChartFrame(
          key: key,
          height: 260,
          child: _AnimatedChart(
            child: CamPieChart(
              candidates: candidates,
              watermarkTitle: widget.watermarkTitle,
              watermarkSubtitle: widget.watermarkSubtitle,
            ),
          ),
        );

      case _ChartKind.line:
        if (trend.length < 2) {
          return _EmptyChart(key: key, height: 260, message: t.noData);
        }
        return _ChartFrame(
          key: key,
          height: 260,
          child: _AnimatedChart(
            child: CamLineChart(
              series: trend,
              watermarkTitle: widget.watermarkTitle,
              watermarkSubtitle: widget.watermarkSubtitle,
            ),
          ),
        );
    }
  }
}

class _EmptyChart extends StatelessWidget {
  const _EmptyChart({super.key, required this.height, required this.message});

  final double height;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _ChartFrame(
      height: height,
      child: Center(
        child: Text(
          message,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface.withAlpha(160),
          ),
        ),
      ),
    );
  }
}

class _ChartFrame extends StatelessWidget {
  const _ChartFrame({super.key, required this.child, required this.height});

  final Widget child;
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final border = theme.colorScheme.outlineVariant.withAlpha(90);

    return Container(
      height: height,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
      ),
      child: child,
    );
  }
}

class _AnimatedChart extends StatelessWidget {
  const _AnimatedChart({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeOutCubic,
      child: child,
      builder: (context, value, child) {
        final content = child ?? const SizedBox.shrink();
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 10),
            child: Transform.scale(
              scale: 0.985 + (value * 0.015),
              child: _ChartProgressScope(progress: value, child: content),
            ),
          ),
        );
      },
    );
  }
}

class _ChartProgressScope extends InheritedWidget {
  const _ChartProgressScope({required this.progress, required super.child});

  final double progress;

  static double of(BuildContext context) {
    final w = context.dependOnInheritedWidgetOfExactType<_ChartProgressScope>();
    return w?.progress ?? 1;
  }

  @override
  bool updateShouldNotify(covariant _ChartProgressScope oldWidget) =>
      oldWidget.progress != progress;
}

// ----------------------- BAR CHART -----------------------

class CamBarChart extends StatelessWidget {
  const CamBarChart({
    super.key,
    required this.candidates,
    this.watermarkTitle,
    this.watermarkSubtitle,
  });

  final List<CandidateMetric> candidates;
  final String? watermarkTitle;
  final String? watermarkSubtitle;

  @override
  Widget build(BuildContext context) {
    final p = _ChartProgressScope.of(context);
    return CustomPaint(
      painter: _BarChartPainter(
        candidates: candidates,
        progress: p,
        theme: Theme.of(context),
        watermarkTitle: watermarkTitle,
        watermarkSubtitle: watermarkSubtitle,
      ),
      child: const SizedBox.expand(),
    );
  }
}

class _BarChartPainter extends CustomPainter {
  _BarChartPainter({
    required this.candidates,
    required this.progress,
    required this.theme,
    required this.watermarkTitle,
    required this.watermarkSubtitle,
  });

  final List<CandidateMetric> candidates;
  final double progress;
  final ThemeData theme;
  final String? watermarkTitle;
  final String? watermarkSubtitle;

  @override
  void paint(Canvas canvas, Size size) {
    final pad = 8.0;
    final chart = Rect.fromLTWH(
      pad,
      pad,
      size.width - pad * 2,
      size.height - pad * 2,
    );

    // grid
    _drawGrid(canvas, chart);

    if (candidates.isEmpty) return;

    final maxVotes = candidates.map((e) => e.votes).reduce(math.max).toDouble();
    final safeMax = maxVotes <= 0 ? 1 : maxVotes;

    final barCount = candidates.length;
    final gap = 10.0;
    final barW = (chart.width - gap * (barCount - 1)) / barCount;

    final labelStyle = theme.textTheme.labelSmall?.copyWith(
      color: theme.colorScheme.onSurface.withAlpha(170),
      fontWeight: FontWeight.w800,
    );

    for (int i = 0; i < barCount; i++) {
      final c = candidates[i];
      final x = chart.left + i * (barW + gap);
      final h = (c.votes / safeMax) * chart.height * progress;

      final barRect = Rect.fromLTWH(x, chart.bottom - h, barW, h);
      final rrect = RRect.fromRectAndRadius(barRect, const Radius.circular(12));

      final fill = Paint()..color = c.color.withAlpha(220);
      canvas.drawRRect(rrect, fill);

      // subtle shine
      final shine = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white.withAlpha(80), Colors.white.withAlpha(0)],
          stops: const [0, 1],
        ).createShader(barRect);
      canvas.drawRRect(rrect, shine);

      // label (short name)
      final name = c.name.length > 10 ? '${c.name.substring(0, 10)}…' : c.name;
      _drawText(
        canvas,
        Offset(x + barW / 2, chart.bottom + 6),
        name,
        labelStyle,
        alignCenter: true,
      );
    }

    _drawWatermark(canvas, chart);
  }

  void _drawGrid(Canvas canvas, Rect r) {
    final gridPaint = Paint()
      ..color = theme.colorScheme.onSurface.withAlpha(12)
      ..strokeWidth = 1;

    const lines = 4;
    for (int i = 1; i <= lines; i++) {
      final y = r.top + (r.height * i / (lines + 1));
      canvas.drawLine(Offset(r.left, y), Offset(r.right, y), gridPaint);
    }
  }

  void _drawWatermark(Canvas canvas, Rect r) {
    final title = watermarkTitle;
    if (title == null || title.trim().isEmpty) return;

    final style = theme.textTheme.headlineSmall?.copyWith(
      fontWeight: FontWeight.w900,
      color: theme.colorScheme.onSurface.withAlpha(18),
    );

    _drawText(
      canvas,
      Offset(r.right - 6, r.top + 8),
      title,
      style,
      alignRight: true,
    );

    final sub = watermarkSubtitle;
    if (sub != null && sub.trim().isNotEmpty) {
      final s2 = theme.textTheme.labelMedium?.copyWith(
        fontWeight: FontWeight.w800,
        color: theme.colorScheme.onSurface.withAlpha(14),
      );
      _drawText(
        canvas,
        Offset(r.right - 6, r.top + 38),
        sub,
        s2,
        alignRight: true,
      );
    }
  }

  void _drawText(
    Canvas canvas,
    Offset anchor,
    String text,
    TextStyle? style, {
    bool alignCenter = false,
    bool alignRight = false,
  }) {
    if (style == null) return;
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      maxLines: 1,
      ellipsis: '…',
    )..layout(maxWidth: 160);

    var dx = anchor.dx;
    if (alignCenter) dx -= tp.width / 2;
    if (alignRight) dx -= tp.width;

    tp.paint(canvas, Offset(dx, anchor.dy));
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.candidates != candidates ||
      oldDelegate.theme != theme ||
      oldDelegate.watermarkTitle != watermarkTitle ||
      oldDelegate.watermarkSubtitle != watermarkSubtitle;
}

// ----------------------- PIE CHART -----------------------

class CamPieChart extends StatelessWidget {
  const CamPieChart({
    super.key,
    required this.candidates,
    this.watermarkTitle,
    this.watermarkSubtitle,
  });

  final List<CandidateMetric> candidates;
  final String? watermarkTitle;
  final String? watermarkSubtitle;

  @override
  Widget build(BuildContext context) {
    final p = _ChartProgressScope.of(context);
    return CustomPaint(
      painter: _PieChartPainter(
        candidates: candidates,
        progress: p,
        theme: Theme.of(context),
        watermarkTitle: watermarkTitle,
        watermarkSubtitle: watermarkSubtitle,
      ),
      child: const SizedBox.expand(),
    );
  }
}

class _PieChartPainter extends CustomPainter {
  _PieChartPainter({
    required this.candidates,
    required this.progress,
    required this.theme,
    required this.watermarkTitle,
    required this.watermarkSubtitle,
  });

  final List<CandidateMetric> candidates;
  final double progress;
  final ThemeData theme;
  final String? watermarkTitle;
  final String? watermarkSubtitle;

  @override
  void paint(Canvas canvas, Size size) {
    final r = math.min(size.width, size.height) / 2;
    final center = size.center(Offset.zero);

    // Leave space for watermark text at top-left area
    final pieR = r - 8;

    final total = candidates.fold<int>(0, (a, b) => a + b.votes);
    final safeTotal = total <= 0 ? 1 : total;

    final rect = Rect.fromCircle(center: center, radius: pieR);

    var start = -math.pi / 2;
    for (final c in candidates) {
      final frac = (c.votes / safeTotal);
      final sweep = (math.pi * 2) * frac * progress;

      final paint = Paint()
        ..style = PaintingStyle.fill
        ..color = c.color.withAlpha(235);

      canvas.drawArc(rect, start, sweep, true, paint);

      // subtle slice border
      final border = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = theme.colorScheme.surface.withAlpha(140);
      canvas.drawArc(rect, start, sweep, true, border);

      start += (math.pi * 2) * frac;
    }

    // donut hole (premium)
    final hole = Paint()..color = theme.colorScheme.surface;
    canvas.drawCircle(center, pieR * 0.52, hole);

    // soft inner ring
    final innerRing = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = theme.colorScheme.onSurface.withAlpha(18);
    canvas.drawCircle(center, pieR * 0.52, innerRing);

    _drawWatermark(canvas, size);
  }

  void _drawWatermark(Canvas canvas, Size size) {
    final title = watermarkTitle;
    if (title == null || title.trim().isEmpty) return;

    final style = theme.textTheme.titleLarge?.copyWith(
      fontWeight: FontWeight.w900,
      color: theme.colorScheme.onSurface.withAlpha(18),
    );

    final tp = TextPainter(
      text: TextSpan(text: title, style: style),
      textDirection: TextDirection.ltr,
      maxLines: 1,
      ellipsis: '…',
    )..layout(maxWidth: size.width);

    tp.paint(canvas, Offset(4, 4));

    final sub = watermarkSubtitle;
    if (sub != null && sub.trim().isNotEmpty) {
      final s2 = theme.textTheme.labelMedium?.copyWith(
        fontWeight: FontWeight.w800,
        color: theme.colorScheme.onSurface.withAlpha(14),
      );

      final tp2 = TextPainter(
        text: TextSpan(text: sub, style: s2),
        textDirection: TextDirection.ltr,
        maxLines: 2,
        ellipsis: '…',
      )..layout(maxWidth: size.width - 8);

      tp2.paint(canvas, Offset(4, 34));
    }
  }

  @override
  bool shouldRepaint(covariant _PieChartPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.candidates != candidates ||
      oldDelegate.theme != theme ||
      oldDelegate.watermarkTitle != watermarkTitle ||
      oldDelegate.watermarkSubtitle != watermarkSubtitle;
}

// ----------------------- LINE CHART -----------------------

class CamLineChart extends StatelessWidget {
  const CamLineChart({
    super.key,
    required this.series,
    this.watermarkTitle,
    this.watermarkSubtitle,
  });

  /// Values in percent (0..100)
  final List<double> series;
  final String? watermarkTitle;
  final String? watermarkSubtitle;

  @override
  Widget build(BuildContext context) {
    final p = _ChartProgressScope.of(context);
    return CustomPaint(
      painter: _LineChartPainter(
        series: series,
        progress: p,
        theme: Theme.of(context),
        watermarkTitle: watermarkTitle,
        watermarkSubtitle: watermarkSubtitle,
      ),
      child: const SizedBox.expand(),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  _LineChartPainter({
    required this.series,
    required this.progress,
    required this.theme,
    required this.watermarkTitle,
    required this.watermarkSubtitle,
  });

  final List<double> series;
  final double progress;
  final ThemeData theme;
  final String? watermarkTitle;
  final String? watermarkSubtitle;

  @override
  void paint(Canvas canvas, Size size) {
    final pad = 10.0;
    final chart = Rect.fromLTWH(
      pad,
      pad,
      size.width - pad * 2,
      size.height - pad * 2,
    );

    _drawGrid(canvas, chart);

    if (series.length < 2) return;

    final minV = 0.0;
    final maxV = 100.0;

    final pts = <Offset>[];
    for (int i = 0; i < series.length; i++) {
      final x = chart.left + (chart.width * (i / (series.length - 1)));
      final v = series[i].clamp(minV, maxV);
      final y = chart.bottom - (chart.height * ((v - minV) / (maxV - minV)));
      pts.add(Offset(x, y));
    }

    // animate by trimming path length
    final shown = math.max(2, (pts.length * progress).floor());
    final visiblePts = pts.take(shown).toList();

    // path
    final path = Path()..moveTo(visiblePts.first.dx, visiblePts.first.dy);
    for (int i = 1; i < visiblePts.length; i++) {
      final p0 = visiblePts[i - 1];
      final p1 = visiblePts[i];
      final mid = Offset((p0.dx + p1.dx) / 2, (p0.dy + p1.dy) / 2);
      path.quadraticBezierTo(p0.dx, p0.dy, mid.dx, mid.dy);
    }
    path.lineTo(visiblePts.last.dx, visiblePts.last.dy);

    // stroke
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          const Color(0xFF1B8E3E).withAlpha(220),
          const Color(0xFFD81F26).withAlpha(220),
          const Color(0xFFF5C400).withAlpha(220),
        ],
      ).createShader(chart);

    canvas.drawPath(path, stroke);

    // fill under curve (subtle)
    final fillPath = Path.from(path)
      ..lineTo(visiblePts.last.dx, chart.bottom)
      ..lineTo(visiblePts.first.dx, chart.bottom)
      ..close();

    final fill = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFFD81F26).withAlpha(45),
          const Color(0xFFD81F26).withAlpha(0),
        ],
      ).createShader(chart);

    canvas.drawPath(fillPath, fill);

    // dots
    final dotPaint = Paint()..color = theme.colorScheme.surface;
    final dotBorder = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = theme.colorScheme.onSurface.withAlpha(40);

    for (final p in visiblePts) {
      canvas.drawCircle(p, 4.5, dotPaint);
      canvas.drawCircle(p, 4.5, dotBorder);
    }

    _drawWatermark(canvas, chart);
  }

  void _drawGrid(Canvas canvas, Rect r) {
    final gridPaint = Paint()
      ..color = theme.colorScheme.onSurface.withAlpha(12)
      ..strokeWidth = 1;

    const lines = 4;
    for (int i = 1; i <= lines; i++) {
      final y = r.top + (r.height * i / (lines + 1));
      canvas.drawLine(Offset(r.left, y), Offset(r.right, y), gridPaint);
    }
  }

  void _drawWatermark(Canvas canvas, Rect r) {
    final title = watermarkTitle;
    if (title == null || title.trim().isEmpty) return;

    final style = theme.textTheme.headlineSmall?.copyWith(
      fontWeight: FontWeight.w900,
      color: theme.colorScheme.onSurface.withAlpha(18),
    );

    final tp = TextPainter(
      text: TextSpan(text: title, style: style),
      textDirection: TextDirection.ltr,
      maxLines: 1,
      ellipsis: '…',
    )..layout(maxWidth: 200);

    tp.paint(canvas, Offset(r.right - tp.width - 6, r.top + 8));

    final sub = watermarkSubtitle;
    if (sub != null && sub.trim().isNotEmpty) {
      final s2 = theme.textTheme.labelMedium?.copyWith(
        fontWeight: FontWeight.w800,
        color: theme.colorScheme.onSurface.withAlpha(14),
      );

      final tp2 = TextPainter(
        text: TextSpan(text: sub, style: s2),
        textDirection: TextDirection.ltr,
        maxLines: 2,
        ellipsis: '…',
      )..layout(maxWidth: 260);

      tp2.paint(canvas, Offset(r.right - tp2.width - 6, r.top + 40));
    }
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.series != series ||
      oldDelegate.theme != theme ||
      oldDelegate.watermarkTitle != watermarkTitle ||
      oldDelegate.watermarkSubtitle != watermarkSubtitle;
}
