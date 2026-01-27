import 'package:flutter/material.dart';

/// Metadata for a Cameroon region (10 regions).
class CameroonRegionMeta {
  const CameroonRegionMeta({
    required this.code,
    required this.defaultName,
    required this.polygon, // normalized points 0..1
  });

  final String code;
  final String defaultName;

  /// Polygon points in normalized (0..1) coordinates (x,y).
  final List<Offset> polygon;
}

/// A stylized Cameroon map split into 10 regions.
/// It is "vector-like" and works on Android/iOS/Web.
///
/// - Each region is colored via [fillByCode]
/// - Optional [winnerTagByCode] draws small winner label inside each region
/// - Optional [highlightedCode] draws a glowing outline on a region
/// - Taps are detected and sent via [onRegionTap]
class CameroonRegionsMap extends StatefulWidget {
  const CameroonRegionsMap({
    super.key,
    required this.fillByCode,
    required this.labelsByCode,
    this.winnerTagByCode = const {},
    this.highlightedCode,
    this.onRegionTap,
    this.showLabels = true,
    this.showWinnerTags = true,
  });

  /// Region list is exposed for screens/legends.
  static const List<CameroonRegionMeta> regions = _regions;

  /// Instance getter too (in case some old code used map.regions).
  List<CameroonRegionMeta> get regionsInstance => regions;

  final Map<String, Color> fillByCode;
  final Map<String, String> labelsByCode;
  final Map<String, String> winnerTagByCode;

  final String? highlightedCode;
  final ValueChanged<String>? onRegionTap;

  final bool showLabels;
  final bool showWinnerTags;

  @override
  State<CameroonRegionsMap> createState() => _CameroonRegionsMapState();
}

class _CameroonRegionsMapState extends State<CameroonRegionsMap> {
  // We keep computed paths for hit-testing.
  late Map<String, Path> _paths;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _paths = {};
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (d) {
            if (widget.onRegionTap == null) return;
            final local = d.localPosition;

            for (final entry in _paths.entries) {
              if (entry.value.contains(local)) {
                widget.onRegionTap?.call(entry.key);
                return;
              }
            }
          },
          child: CustomPaint(
            painter: _CameroonRegionsPainter(
              fillByCode: widget.fillByCode,
              labelsByCode: widget.labelsByCode,
              winnerTagByCode: widget.winnerTagByCode,
              highlightedCode: widget.highlightedCode,
              showLabels: widget.showLabels,
              showWinnerTags: widget.showWinnerTags,
              theme: Theme.of(context),
              onPathsBuilt: (paths) => _paths = paths,
            ),
            child: const SizedBox.expand(),
          ),
        );
      },
    );
  }
}

class _CameroonRegionsPainter extends CustomPainter {
  _CameroonRegionsPainter({
    required this.fillByCode,
    required this.labelsByCode,
    required this.winnerTagByCode,
    required this.highlightedCode,
    required this.showLabels,
    required this.showWinnerTags,
    required this.theme,
    required this.onPathsBuilt,
  });

  final Map<String, Color> fillByCode;
  final Map<String, String> labelsByCode;
  final Map<String, String> winnerTagByCode;
  final String? highlightedCode;
  final bool showLabels;
  final bool showWinnerTags;
  final ThemeData theme;
  final ValueChanged<Map<String, Path>> onPathsBuilt;

  @override
  void paint(Canvas canvas, Size size) {
    final pad = 8.0;
    final rect = Rect.fromLTWH(pad, pad, size.width - pad * 2, size.height - pad * 2);

    // Build region paths in screen coordinates.
    final paths = <String, Path>{};

    for (final region in CameroonRegionsMap.regions) {
      final path = _buildPath(region.polygon, rect);
      paths[region.code] = path;
    }

    onPathsBuilt(paths);

    // Draw shadow for depth
    final shadowPaint = Paint()
      ..color = Colors.black.withAlpha(22)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    for (final p in paths.values) {
      canvas.drawPath(p.shift(const Offset(0, 2)), shadowPaint);
    }

    // Draw regions
    for (final region in CameroonRegionsMap.regions) {
      final path = paths[region.code]!;
      final fill = (fillByCode[region.code] ?? theme.colorScheme.surfaceContainerHighest)
          .withAlpha(215);

      final fillPaint = Paint()..color = fill;
      canvas.drawPath(path, fillPaint);

      // Border between regions (subtle)
      final border = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = theme.colorScheme.surface.withAlpha(170);
      canvas.drawPath(path, border);

      // Label + winner tag
      final label = labelsByCode[region.code] ?? region.defaultName;
      final tag = winnerTagByCode[region.code] ?? '';

      final centroid = _centroid(region.polygon);
      final labelPos = Offset(
        rect.left + centroid.dx * rect.width,
        rect.top + centroid.dy * rect.height,
      );

      if (showLabels) {
        _drawText(
          canvas,
          labelPos.translate(0, 6),
          label,
          theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w900,
            color: theme.colorScheme.onSurface.withAlpha(230),
          ),
          maxWidth: 92,
          alignCenter: true,
        );
      }

      if (showWinnerTags && tag.trim().isNotEmpty) {
        _drawBadge(canvas, labelPos.translate(0, -12), tag);
      }
    }

    // Highlight spotlight
    final h = highlightedCode;
    if (h != null && paths.containsKey(h)) {
      final glow = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..color = theme.colorScheme.onSurface.withAlpha(28)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

      final outline = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.6
        ..color = theme.colorScheme.onSurface.withAlpha(120);

      canvas.drawPath(paths[h]!, glow);
      canvas.drawPath(paths[h]!, outline);
    }

    // Outer country border (premium)
    final union = Path();
    for (final p in paths.values) {
      union.addPath(p, Offset.zero);
    }

    final outer = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = theme.colorScheme.onSurface.withAlpha(30);

    canvas.drawPath(union, outer);
  }

  Path _buildPath(List<Offset> normalized, Rect rect) {
    final path = Path();
    for (int i = 0; i < normalized.length; i++) {
      final p = Offset(
        rect.left + normalized[i].dx * rect.width,
        rect.top + normalized[i].dy * rect.height,
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

  Offset _centroid(List<Offset> poly) {
    double x = 0, y = 0;
    for (final p in poly) {
      x += p.dx;
      y += p.dy;
    }
    return Offset(x / poly.length, y / poly.length);
  }

  void _drawBadge(Canvas canvas, Offset center, String tag) {
    final bg = Paint()
      ..color = theme.colorScheme.surface.withAlpha(235);

    final border = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = theme.colorScheme.onSurface.withAlpha(40);

    final tp = TextPainter(
      text: TextSpan(
        text: tag,
        style: theme.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w900,
          color: theme.colorScheme.onSurface.withAlpha(220),
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
      ellipsis: '…',
    )..layout(maxWidth: 56);

    final w = tp.width + 16;
    final h = tp.height + 10;

    final r = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: w, height: h),
      const Radius.circular(999),
    );

    canvas.drawRRect(r, bg);
    canvas.drawRRect(r, border);

    tp.paint(canvas, Offset(center.dx - tp.width / 2, center.dy - tp.height / 2));
  }

  void _drawText(
    Canvas canvas,
    Offset center,
    String text,
    TextStyle? style, {
    bool alignCenter = false,
    bool alignRight = false,
    double maxWidth = 120,
  }) {
    if (style == null) return;
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      maxLines: 2,
      ellipsis: '…',
      textAlign: TextAlign.center,
    )..layout(maxWidth: maxWidth);

    double dx = center.dx;
    if (alignCenter) dx -= tp.width / 2;
    if (alignRight) dx -= tp.width;

    tp.paint(canvas, Offset(dx, center.dy));
  }

  @override
  bool shouldRepaint(covariant _CameroonRegionsPainter oldDelegate) {
    return oldDelegate.fillByCode != fillByCode ||
        oldDelegate.labelsByCode != labelsByCode ||
        oldDelegate.winnerTagByCode != winnerTagByCode ||
        oldDelegate.highlightedCode != highlightedCode ||
        oldDelegate.showLabels != showLabels ||
        oldDelegate.showWinnerTags != showWinnerTags ||
        oldDelegate.theme != theme;
  }
}

// ------------------ 10 REGION SHAPES (stylized) ------------------

const List<CameroonRegionMeta> _regions = [
  CameroonRegionMeta(
    code: 'far_north',
    defaultName: 'Far North',
    polygon: [
      Offset(0.45, 0.02),
      Offset(0.65, 0.02),
      Offset(0.72, 0.10),
      Offset(0.62, 0.16),
      Offset(0.46, 0.14),
      Offset(0.40, 0.08),
    ],
  ),
  CameroonRegionMeta(
    code: 'north',
    defaultName: 'North',
    polygon: [
      Offset(0.38, 0.14),
      Offset(0.62, 0.16),
      Offset(0.70, 0.24),
      Offset(0.60, 0.32),
      Offset(0.40, 0.30),
      Offset(0.32, 0.22),
    ],
  ),
  CameroonRegionMeta(
    code: 'adamawa',
    defaultName: 'Adamawa',
    polygon: [
      Offset(0.30, 0.30),
      Offset(0.60, 0.32),
      Offset(0.68, 0.44),
      Offset(0.56, 0.52),
      Offset(0.34, 0.50),
      Offset(0.24, 0.40),
    ],
  ),
  CameroonRegionMeta(
    code: 'north_west',
    defaultName: 'North West',
    polygon: [
      Offset(0.12, 0.34),
      Offset(0.26, 0.32),
      Offset(0.30, 0.42),
      Offset(0.26, 0.54),
      Offset(0.16, 0.56),
      Offset(0.08, 0.46),
    ],
  ),
  CameroonRegionMeta(
    code: 'west',
    defaultName: 'West',
    polygon: [
      Offset(0.20, 0.52),
      Offset(0.34, 0.50),
      Offset(0.36, 0.62),
      Offset(0.28, 0.70),
      Offset(0.16, 0.66),
      Offset(0.14, 0.58),
    ],
  ),
  CameroonRegionMeta(
    code: 'centre',
    defaultName: 'Centre',
    polygon: [
      Offset(0.34, 0.50),
      Offset(0.56, 0.52),
      Offset(0.58, 0.66),
      Offset(0.46, 0.74),
      Offset(0.30, 0.70),
      Offset(0.28, 0.62),
    ],
  ),
  CameroonRegionMeta(
    code: 'littoral',
    defaultName: 'Littoral',
    polygon: [
      Offset(0.12, 0.70),
      Offset(0.28, 0.70),
      Offset(0.30, 0.80),
      Offset(0.22, 0.88),
      Offset(0.10, 0.84),
      Offset(0.08, 0.76),
    ],
  ),
  CameroonRegionMeta(
    code: 'south_west',
    defaultName: 'South West',
    polygon: [
      Offset(0.06, 0.86),
      Offset(0.22, 0.88),
      Offset(0.22, 0.98),
      Offset(0.06, 0.98),
      Offset(0.02, 0.92),
    ],
  ),
  CameroonRegionMeta(
    code: 'east',
    defaultName: 'East',
    polygon: [
      Offset(0.56, 0.52),
      Offset(0.80, 0.46),
      Offset(0.94, 0.60),
      Offset(0.92, 0.84),
      Offset(0.70, 0.94),
      Offset(0.58, 0.80),
    ],
  ),
  CameroonRegionMeta(
    code: 'south',
    defaultName: 'South',
    polygon: [
      Offset(0.22, 0.88),
      Offset(0.46, 0.74),
      Offset(0.58, 0.80),
      Offset(0.70, 0.94),
      Offset(0.44, 0.98),
      Offset(0.22, 0.98),
    ],
  ),
];
