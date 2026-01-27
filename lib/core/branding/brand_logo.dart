import 'package:flutter/material.dart';
import 'package:camvote/gen/l10n/app_localizations.dart';

import 'brand_palette.dart';

class CamVoteLogo extends StatelessWidget {
  const CamVoteLogo({
    super.key,
    this.size = 72,
    this.showText = false,
  });

  final double size;
  final bool showText;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w900,
        );

    return LayoutBuilder(
      builder: (context, constraints) {
        final isTight = constraints.maxWidth > 0 &&
            constraints.maxWidth < (size * (showText ? 2.6 : 1.2));
        final logo = CustomPaint(
          size: Size.square(size),
          painter: _CamVoteLogoPainter(),
        );
        if (!showText) {
          return logo;
        }
        if (isTight) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              logo,
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context).appName,
                style: textStyle,
                textAlign: TextAlign.center,
              ),
            ],
          );
        }
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            logo,
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                AppLocalizations.of(context).appName,
                style: textStyle,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CamVoteLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width / 2;
    final center = size.center(Offset.zero);

    final base = Paint()
      ..shader = BrandPalette.heroGradient.createShader(
        Rect.fromCircle(center: center, radius: r),
      );

    canvas.drawCircle(center, r, base);

    final inner = Paint()..color = Colors.white.withAlpha(210);
    canvas.drawCircle(center, r * 0.72, inner);

    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.12
      ..color = Colors.white.withAlpha(140);
    canvas.drawCircle(center, r * 0.56, ring);

    _drawShield(canvas, center, r * 0.46);
    _drawCheck(canvas, center, r * 0.22);
  }

  void _drawShield(Canvas canvas, Offset center, double size) {
    final path = Path()
      ..moveTo(center.dx, center.dy - size)
      ..lineTo(center.dx + size, center.dy - size * 0.35)
      ..lineTo(center.dx + size * 0.76, center.dy + size * 0.9)
      ..lineTo(center.dx, center.dy + size * 1.2)
      ..lineTo(center.dx - size * 0.76, center.dy + size * 0.9)
      ..lineTo(center.dx - size, center.dy - size * 0.35)
      ..close();

    final paint = Paint()..color = BrandPalette.inkSoft.withAlpha(220);
    canvas.drawPath(path, paint);
  }

  void _drawCheck(Canvas canvas, Offset center, double size) {
    final check = Path()
      ..moveTo(center.dx - size * 0.9, center.dy + size * 0.1)
      ..lineTo(center.dx - size * 0.2, center.dy + size * 0.75)
      ..lineTo(center.dx + size * 1.1, center.dy - size * 0.55);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size * 0.35
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = Colors.white;

    canvas.drawPath(check, paint);
  }

  @override
  bool shouldRepaint(covariant _CamVoteLogoPainter oldDelegate) => false;
}
