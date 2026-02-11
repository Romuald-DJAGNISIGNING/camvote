import 'dart:math' as math;
import 'dart:ui' show lerpDouble;
import 'package:flutter/material.dart';

/// CamVote signature loader:
/// - Thin arc ("tire") in Cameroon flag colors: Green → Red → Yellow
/// - Start cap is a sharp green triangle
/// - End cap is a yellow rectangular cap
/// - Stars appear progressively from start to end (Cameroon vibe)
///
/// No deprecated APIs used (no withOpacity()).
class CamElectionLoader extends StatefulWidget {
  final double size;
  final double strokeWidth;
  final String? label;

  const CamElectionLoader({
    super.key,
    this.size = 84,
    this.strokeWidth = 7,
    this.label,
  });

  @override
  State<CamElectionLoader> createState() => _CamElectionLoaderState();
}

class _CamElectionLoaderState extends State<CamElectionLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1550),
    )..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final label = widget.label;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _c,
          builder: (context, _) {
            return SizedBox(
              width: widget.size,
              height: widget.size,
              child: CustomPaint(
                painter: _CamVoteFlagLoaderPainter(
                  t: _c.value,
                  strokeWidth: widget.strokeWidth,
                  // Cameroon flag colors
                  green: const Color.fromARGB(255, 0, 135, 62),
                  red: const Color.fromARGB(255, 206, 17, 38),
                  yellow: const Color.fromARGB(255, 252, 209, 22),
                ),
              ),
            );
          },
        ),
        if (label != null) ...[
          const SizedBox(height: 10),
          Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ],
    );
  }
}

class _CamVoteFlagLoaderPainter extends CustomPainter {
  final double t; // 0..1 loop
  final double strokeWidth;

  final Color green;
  final Color red;
  final Color yellow;

  _CamVoteFlagLoaderPainter({
    required this.t,
    required this.strokeWidth,
    required this.green,
    required this.red,
    required this.yellow,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (math.min(size.width, size.height) / 2) - strokeWidth;

    // Arc growth: from small sweep to large sweep, then resets smoothly
    final grow = _easeInOutCubic(_pingPong(t));
    final sweep = lerpDouble(math.pi * 0.45, math.pi * 1.75, grow)!;

    // Rotation so it feels alive + elegant
    final startAngle = (-math.pi / 2) + (math.pi * 2 * t * 0.85);

    // Shadow (subtle)
    final shadowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt
      ..color = Colors.black.withAlpha(24);

    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(
      rect.shift(const Offset(0, 1.6)),
      startAngle,
      sweep,
      false,
      shadowPaint,
    );

    // Draw 3 colored segments along the sweep: green → red → yellow
    _drawFlagArc(canvas, rect, startAngle, sweep);

    // Start cap triangle (sharp green)
    _drawStartTriangleCap(canvas, center, radius, startAngle);

    // End cap rectangle (yellow)
    _drawEndRectCap(canvas, center, radius, startAngle + sweep);

    // Stars progressing along the arc
    _drawProgressStars(canvas, center, radius, startAngle, sweep);
  }

  void _drawFlagArc(Canvas canvas, Rect rect, double startAngle, double sweep) {
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    // Segment weights (Cameroon: green, red, yellow)
    final gW = 0.33;
    final rW = 0.34;
    final yW = 0.33;

    final gSweep = sweep * gW;
    final rSweep = sweep * rW;
    final ySweep = sweep * yW;

    // Green
    p.color = green.withAlpha(235);
    canvas.drawArc(rect, startAngle, gSweep, false, p);

    // Red
    p.color = red.withAlpha(235);
    canvas.drawArc(rect, startAngle + gSweep, rSweep, false, p);

    // Yellow
    p.color = yellow.withAlpha(235);
    canvas.drawArc(rect, startAngle + gSweep + rSweep, ySweep, false, p);
  }

  void _drawStartTriangleCap(
    Canvas canvas,
    Offset center,
    double radius,
    double angle,
  ) {
    final tip = _pointOnCircle(center, radius, angle);
    final tangent = _tangentUnit(angle);

    final outward = _radialUnit(angle);
    final capLen = strokeWidth * 1.25;
    final capHalf = strokeWidth * 0.72;

    // Triangle points: tip at arc start, base behind it.
    final baseCenter = tip - tangent * capLen;
    final p1 = baseCenter + outward * capHalf;
    final p2 = baseCenter - outward * capHalf;

    final path = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(p1.dx, p1.dy)
      ..lineTo(p2.dx, p2.dy)
      ..close();

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = green.withAlpha(255);

    // tiny shadow
    final shadow = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.black.withAlpha(20);

    canvas.drawPath(path.shift(const Offset(0, 1)), shadow);
    canvas.drawPath(path, paint);
  }

  void _drawEndRectCap(
    Canvas canvas,
    Offset center,
    double radius,
    double angle,
  ) {
    final end = _pointOnCircle(center, radius, angle);
    final tangent = _tangentUnit(angle);
    final outward = _radialUnit(angle);

    final capLen = strokeWidth * 1.35;
    final capHalf = strokeWidth * 0.62;

    // Rectangle oriented with tangent: centered at end point.
    final a = end - tangent * (capLen * 0.5) + outward * capHalf;
    final b = end + tangent * (capLen * 0.5) + outward * capHalf;
    final c = end + tangent * (capLen * 0.5) - outward * capHalf;
    final d = end - tangent * (capLen * 0.5) - outward * capHalf;

    final path = Path()
      ..moveTo(a.dx, a.dy)
      ..lineTo(b.dx, b.dy)
      ..lineTo(c.dx, c.dy)
      ..lineTo(d.dx, d.dy)
      ..close();

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = yellow.withAlpha(255);

    final shadow = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.black.withAlpha(18);

    canvas.drawPath(path.shift(const Offset(0, 1)), shadow);
    canvas.drawPath(path, paint);
  }

  void _drawProgressStars(
    Canvas canvas,
    Offset center,
    double radius,
    double startAngle,
    double sweep,
  ) {
    // We’ll place stars along the sweep.
    // They appear progressively from start → end.
    const starCount = 8;

    // Progress for star reveal follows arc growth.
    final reveal = _easeInOutCubic(_pingPong(t));

    // Stars draw on a slightly inner ring (more elegant)
    final starRadius = radius - strokeWidth * 1.25;

    for (int i = 0; i < starCount; i++) {
      final frac = (i + 1) / (starCount + 1);
      if (frac > reveal) continue; // appear progressively

      final angle = startAngle + sweep * frac;
      final pos = _pointOnCircle(center, starRadius, angle);

      // Twinkle (subtle)
      final tw = (math.sin((t * math.pi * 2) + i) * 0.5 + 0.5);
      final alpha = lerpDouble(130, 230, tw)!;

      // Star size: small + elegant
      final s = lerpDouble(strokeWidth * 0.55, strokeWidth * 0.8, tw)!;

      final paint = Paint()
        ..style = PaintingStyle.fill
        ..color = yellow.withAlpha(alpha.round());

      final shadow = Paint()
        ..style = PaintingStyle.fill
        ..color = Colors.black.withAlpha((alpha * 0.12).round());

      final star = _starPath(pos, s, points: 5);

      canvas.drawPath(star.shift(const Offset(0, 1)), shadow);
      canvas.drawPath(star, paint);
    }
  }

  // ===== helpers =====

  double _pingPong(double x) {
    // 0..1..0..1 (triangle wave)
    final v = x * 2;
    return v <= 1 ? v : 2 - v;
  }

  double _easeInOutCubic(double x) {
    return x < 0.5 ? 4 * x * x * x : 1 - math.pow(-2 * x + 2, 3).toDouble() / 2;
  }

  Offset _pointOnCircle(Offset c, double r, double a) =>
      Offset(c.dx + math.cos(a) * r, c.dy + math.sin(a) * r);

  Offset _tangentUnit(double a) {
    // tangent direction (perpendicular to radial)
    final dx = -math.sin(a);
    final dy = math.cos(a);
    return Offset(dx, dy);
  }

  Offset _radialUnit(double a) => Offset(math.cos(a), math.sin(a));

  Path _starPath(Offset center, double size, {int points = 5}) {
    final outer = size;
    final inner = size * 0.45;
    final step = math.pi / points;

    final path = Path();
    for (int i = 0; i < points * 2; i++) {
      final r = (i.isEven) ? outer : inner;
      final ang = -math.pi / 2 + step * i;
      final p = Offset(
        center.dx + math.cos(ang) * r,
        center.dy + math.sin(ang) * r,
      );
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant _CamVoteFlagLoaderPainter oldDelegate) {
    return oldDelegate.t != t ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.green != green ||
        oldDelegate.red != red ||
        oldDelegate.yellow != yellow;
  }
}
