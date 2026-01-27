import 'package:flutter/material.dart';

import 'brand_palette.dart';

class BrandBackdrop extends StatelessWidget {
  const BrandBackdrop({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gradient = isDark
        ? BrandPalette.darkHeroGradient
        : BrandPalette.heroGradient;

    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(gradient: gradient),
          ),
        ),
        Positioned(
          top: -80,
          right: -40,
          child: _Orb(
            size: 180,
            color: Colors.white.withAlpha(isDark ? 30 : 80),
          ),
        ),
        Positioned(
          bottom: -90,
          left: -20,
          child: _Orb(
            size: 200,
            color: Colors.black.withAlpha(isDark ? 50 : 20),
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface.withAlpha(
                    isDark ? 210 : 235,
                  ),
            ),
          ),
        ),
        child,
      ],
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
