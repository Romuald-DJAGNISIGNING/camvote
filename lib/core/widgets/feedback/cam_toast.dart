import 'dart:math';

import 'package:flutter/material.dart';
import 'package:camvote/gen/l10n/app_localizations.dart';

import '../../motion/cam_motion.dart';

enum CamToastType { info, success, warning, error }

class CamToast {
  const CamToast._();

  static Color _bgFor(BuildContext context, CamToastType type) {
    final cs = Theme.of(context).colorScheme;
    return switch (type) {
      CamToastType.info => cs.primaryContainer,
      CamToastType.success => cs.tertiaryContainer,
      CamToastType.warning => cs.secondaryContainer,
      CamToastType.error => cs.errorContainer,
    };
  }

  static Color _fgFor(BuildContext context, CamToastType type) {
    final cs = Theme.of(context).colorScheme;
    return switch (type) {
      CamToastType.info => cs.onPrimaryContainer,
      CamToastType.success => cs.onTertiaryContainer,
      CamToastType.warning => cs.onSecondaryContainer,
      CamToastType.error => cs.onErrorContainer,
    };
  }

  static IconData _iconFor(CamToastType type) {
    return switch (type) {
      CamToastType.info => Icons.info_rounded,
      CamToastType.success => Icons.check_circle_rounded,
      CamToastType.warning => Icons.warning_rounded,
      CamToastType.error => Icons.error_rounded,
    };
  }

  /// Premium “toast” using SnackBar (floating + smooth).
  static void show(
    BuildContext context, {
    required String message,
    CamToastType type = CamToastType.info,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 3),
  }) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;

    messenger.clearSnackBars();

    final bg = _bgFor(context, type);
    final fg = _fgFor(context, type);

    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: duration,
        margin: const EdgeInsets.all(12),
        backgroundColor: bg,
        elevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Row(
          children: [
            Icon(_iconFor(type), color: fg),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: fg),
              ),
            ),
          ],
        ),
        action: (actionLabel != null && onAction != null)
            ? SnackBarAction(
                label: actionLabel,
                textColor: fg,
                onPressed: onAction,
              )
            : null,
      ),
    );
  }

  /// Small celebration popup (for: “Pre-Eligible → Eligible”, registration verified, etc).
  /// No external assets required (keeps it working everywhere).
  static Future<void> celebrate(
    BuildContext context, {
    required String title,
    required String message,
  }) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return _CamCelebrationDialog(title: title, message: message);
      },
    );
  }
}

class _CamCelebrationDialog extends StatefulWidget {
  const _CamCelebrationDialog({required this.title, required this.message});

  final String title;
  final String message;

  @override
  State<_CamCelebrationDialog> createState() => _CamCelebrationDialogState();
}

class _CamCelebrationDialogState extends State<_CamCelebrationDialog> {
  bool _on = false;

  @override
  void initState() {
    super.initState();
    // Trigger the animation after first frame for smoother entrance
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _on = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            const Positioned.fill(
              child: IgnorePointer(
                child: _CamConfettiBurst(particleCount: 24),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedScale(
                    scale: _on ? 1.0 : 0.85,
                    duration: CamMotion.medium,
                    curve: CamMotion.emphasized,
                    child: AnimatedRotation(
                      turns: _on ? 0.02 : 0.0,
                      duration: CamMotion.medium,
                      curve: CamMotion.emphasized,
                      child: Container(
                        height: 64,
                        width: 64,
                        decoration: BoxDecoration(
                          color: cs.primaryContainer,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Icon(
                          Icons.celebration_rounded,
                          color: cs.onPrimaryContainer,
                          size: 34,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(widget.title, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(
                    widget.message,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(AppLocalizations.of(context).ok),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CamConfettiBurst extends StatefulWidget {
  const _CamConfettiBurst({this.particleCount = 24});

  final int particleCount;

  @override
  State<_CamConfettiBurst> createState() => _CamConfettiBurstState();
}

class _CamConfettiBurstState extends State<_CamConfettiBurst>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_ConfettiParticle> _particles;
  final _rng = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..forward();

    _particles = List.generate(widget.particleCount, (index) {
      final startX = _rng.nextDouble();
      final startY = _rng.nextDouble() * 0.15;
      final driftX = (_rng.nextDouble() - 0.5) * 0.65;
      final fall = 0.65 + _rng.nextDouble() * 0.55;
      final size = 4.0 + _rng.nextDouble() * 6.0;
      final spin = (_rng.nextDouble() - 0.5) * 1.6;
      final shape = _rng.nextBool() ? _ConfettiShape.circle : _ConfettiShape.rect;
      return _ConfettiParticle(
        start: Offset(startX, startY),
        driftX: driftX,
        fall: fall,
        size: size,
        spin: spin,
        shape: shape,
        colorIndex: index % 5,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final palette = [
      cs.primary,
      cs.secondary,
      cs.tertiary,
      cs.primaryContainer,
      cs.tertiaryContainer,
    ];

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return CustomPaint(
          painter: _ConfettiPainter(
            progress: Curves.easeOut.transform(_controller.value),
            particles: _particles,
            colors: palette,
          ),
        );
      },
    );
  }
}

enum _ConfettiShape { circle, rect }

class _ConfettiParticle {
  final Offset start;
  final double driftX;
  final double fall;
  final double size;
  final double spin;
  final _ConfettiShape shape;
  final int colorIndex;

  const _ConfettiParticle({
    required this.start,
    required this.driftX,
    required this.fall,
    required this.size,
    required this.spin,
    required this.shape,
    required this.colorIndex,
  });
}

class _ConfettiPainter extends CustomPainter {
  final double progress;
  final List<_ConfettiParticle> particles;
  final List<Color> colors;

  _ConfettiPainter({
    required this.progress,
    required this.particles,
    required this.colors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final x = particle.start.dx * size.width + (particle.driftX * progress * size.width);
      final y = particle.start.dy * size.height + (particle.fall * progress * size.height);
      final alpha = (1.0 - progress).clamp(0.0, 1.0);
      final paint = Paint()
        ..color =
            colors[particle.colorIndex % colors.length].withValues(alpha: alpha);
      final center = Offset(x, y);
      final half = particle.size / 2;

      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(particle.spin * progress);
      if (particle.shape == _ConfettiShape.circle) {
        canvas.drawCircle(Offset.zero, half, paint);
      } else {
        canvas.drawRect(
          Rect.fromCenter(center: Offset.zero, width: particle.size, height: particle.size * 0.65),
          paint,
        );
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.particles != particles ||
        oldDelegate.colors != colors;
  }
}
