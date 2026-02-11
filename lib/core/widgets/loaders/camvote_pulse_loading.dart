import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../branding/brand_backdrop.dart';
import '../../branding/brand_logo.dart';
import '../../branding/brand_palette.dart';
import 'cameroon_election_loader.dart';

class CamVoteLoadingScreen extends StatelessWidget {
  const CamVoteLoadingScreen({super.key, required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BrandBackdrop(
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: CamVotePulseLoading(title: title, subtitle: subtitle),
            ),
          ),
        ),
      ),
    );
  }
}

class CamVoteLoadingOverlay extends StatelessWidget {
  const CamVoteLoadingOverlay({super.key, required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      child: Container(
        color: Colors.black.withAlpha(150),
        alignment: Alignment.center,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 26),
          child: CamVotePulseLoading(
            title: title,
            subtitle: subtitle,
            compact: true,
            panelColor: Theme.of(context).colorScheme.surface.withAlpha(232),
          ),
        ),
      ),
    );
  }
}

class CamVotePulseLoading extends StatefulWidget {
  const CamVotePulseLoading({
    super.key,
    required this.title,
    this.subtitle,
    this.compact = false,
    this.panelColor,
  });

  final String title;
  final String? subtitle;
  final bool compact;
  final Color? panelColor;

  @override
  State<CamVotePulseLoading> createState() => _CamVotePulseLoadingState();
}

class _CamVotePulseLoadingState extends State<CamVotePulseLoading>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2300),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final compact = widget.compact;
    final panelColor =
        widget.panelColor ??
        Theme.of(context).colorScheme.surface.withAlpha(222);
    final titleStyle = Theme.of(
      context,
    ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900);
    final subtitleStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );

    final orbSize = compact ? 148.0 : 188.0;
    final logoSize = compact ? 54.0 : 68.0;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final angle = _controller.value * 2 * math.pi;
        final pulse = 1 + (math.sin(angle) * 0.055);

        return Transform.scale(
          scale: pulse,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(compact ? 24 : 28),
              color: panelColor,
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withAlpha(55),
              ),
              boxShadow: BrandPalette.softShadow,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: compact ? 18 : 24,
                vertical: compact ? 18 : 22,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: orbSize,
                    height: orbSize,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: orbSize * 0.98,
                          height: orbSize * 0.98,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                BrandPalette.sunrise.withAlpha(46),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                        Transform.rotate(
                          angle: angle,
                          child: _ring(
                            size: orbSize,
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withAlpha(155),
                            stroke: compact ? 2.4 : 2.8,
                          ),
                        ),
                        Transform.rotate(
                          angle: -angle * 1.35,
                          child: _ring(
                            size: orbSize * 0.8,
                            color: Theme.of(
                              context,
                            ).colorScheme.secondary.withAlpha(150),
                            stroke: compact ? 2 : 2.3,
                          ),
                        ),
                        Transform.rotate(
                          angle: angle * 0.72,
                          child: _ring(
                            size: orbSize * 0.62,
                            color: Theme.of(
                              context,
                            ).colorScheme.tertiary.withAlpha(145),
                            stroke: compact ? 1.8 : 2.1,
                          ),
                        ),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: BrandPalette.heroGradient,
                            boxShadow: [
                              BoxShadow(
                                color: BrandPalette.ember.withAlpha(70),
                                blurRadius: 28,
                                spreadRadius: 1.5,
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(compact ? 9 : 11),
                            child: DecoratedBox(
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(compact ? 8 : 10),
                                child: CamVoteLogo(size: logoSize),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: compact ? 10 : 14),
                  CamElectionLoader(
                    size: compact ? 34 : 40,
                    strokeWidth: compact ? 2.8 : 3.1,
                  ),
                  SizedBox(height: compact ? 10 : 12),
                  Text(
                    widget.title,
                    textAlign: TextAlign.center,
                    style: titleStyle,
                  ),
                  if (widget.subtitle != null &&
                      widget.subtitle!.trim().isNotEmpty) ...[
                    const SizedBox(height: 6),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: compact ? 280 : 360,
                      ),
                      child: Text(
                        widget.subtitle!,
                        textAlign: TextAlign.center,
                        style: subtitleStyle,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _ring({
    required double size,
    required Color color,
    double stroke = 2.4,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color, width: stroke),
      ),
    );
  }
}
