import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'brand_palette.dart';
import '../theme/cam_subtheme.dart';

class BrandBackdrop extends StatelessWidget {
  const BrandBackdrop({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.maybeOf(context);
    final profile = _BackdropVisualProfile.resolve(media);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    final subtheme = CamSubtheme.of(context);
    final surfaceWashAlpha = kIsWeb ? 0 : (isDark ? 70 : 36);
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isDark
          ? [
              Color.alphaBlend(cs.primary.withAlpha(34), cs.surface),
              Color.alphaBlend(cs.secondary.withAlpha(42), cs.surface),
              Color.alphaBlend(cs.tertiary.withAlpha(48), cs.surface),
            ]
          : [
              Color.alphaBlend(
                cs.tertiary.withAlpha(78),
                cs.surface.withAlpha(252),
              ),
              Color.alphaBlend(
                cs.secondary.withAlpha(76),
                cs.surface.withAlpha(252),
              ),
              Color.alphaBlend(cs.primary.withAlpha(80), cs.surface),
            ],
    );

    return Stack(
      children: [
        RepaintBoundary(
          child: Stack(
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(gradient: gradient),
                ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.topLeft,
                      radius: profile.primaryHighlightRadius,
                      colors: [
                        subtheme.roleAccent.withAlpha(isDark ? 38 : 58),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              if (profile.showSecondaryGlow)
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.bottomRight,
                        radius: 1.05,
                        colors: [
                          subtheme.info.withAlpha(isDark ? 30 : 52),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              Positioned(
                top: -80,
                right: -40,
                child: _Orb(
                  size: 180 * profile.orbScale,
                  color: subtheme.roleAccentSoft.withAlpha(isDark ? 56 : 105),
                ),
              ),
              Positioned(
                bottom: -90,
                left: -20,
                child: _Orb(
                  size: 200 * profile.orbScale,
                  color: subtheme.surfaceElevated.withAlpha(isDark ? 120 : 70),
                ),
              ),
              if (surfaceWashAlpha > 0)
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      // Keep readability on mobile/desktop apps while avoiding
                      // the web "gray mask" effect.
                      color: cs.surface.withAlpha(surfaceWashAlpha),
                    ),
                  ),
                ),
              if (profile.showPatternTexture)
                Positioned.fill(
                  child: IgnorePointer(
                    child: Opacity(
                      opacity: profile.textureOpacity * (isDark ? 0.78 : 1),
                      child: Image.asset(
                        'assets/illustrations/cam_pattern.png',
                        repeat: ImageRepeat.repeat,
                        fit: BoxFit.none,
                        filterQuality: FilterQuality.low,
                        color: cs.onSurface.withAlpha(isDark ? 26 : 18),
                        colorBlendMode: BlendMode.srcATop,
                      ),
                    ),
                  ),
                ),
              if (kIsWeb && profile.showPulseRim)
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: cs.primary.withAlpha(isDark ? 26 : 34),
                          width: 1.1,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        child,
      ],
    );
  }
}

class _BackdropVisualProfile {
  final bool showPatternTexture;
  final bool showSecondaryGlow;
  final bool showPulseRim;
  final double textureOpacity;
  final double orbScale;
  final double primaryHighlightRadius;

  const _BackdropVisualProfile({
    required this.showPatternTexture,
    required this.showSecondaryGlow,
    required this.showPulseRim,
    required this.textureOpacity,
    required this.orbScale,
    required this.primaryHighlightRadius,
  });

  factory _BackdropVisualProfile.resolve(MediaQueryData? media) {
    final size = media?.size ?? const Size(1200, 800);
    final shortest = size.shortestSide;
    final area = size.width * size.height;
    final reduceMotion = media?.disableAnimations ?? false;

    final ultraCompact = shortest < 360 || area < 150000;
    final compact = shortest < 460 || area < 260000;

    return _BackdropVisualProfile(
      // On web this subtle texture can read as a gray filter on some GPUs.
      showPatternTexture: !kIsWeb && !ultraCompact,
      showSecondaryGlow: !compact,
      showPulseRim: !compact && !reduceMotion,
      textureOpacity: ultraCompact ? 0.08 : (compact ? 0.12 : 0.18),
      orbScale: compact ? 0.78 : 1,
      primaryHighlightRadius: compact ? 0.95 : 1.2,
    );
  }
}

class _Orb extends StatelessWidget {
  const _Orb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: BrandPalette.softShadow,
      ),
    );
  }
}
