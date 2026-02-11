import 'package:flutter/material.dart';

import 'brand_logo.dart';

class BrandHeader extends StatelessWidget {
  const BrandHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.eyebrow,
    this.trailing,
    this.showLogo = true,
  });

  final String title;
  final String subtitle;
  final String? eyebrow;
  final Widget? trailing;
  final bool showLogo;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      builder: (context, t, child) {
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, (1 - t) * 10),
            child: child,
          ),
        );
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 360;
          final logoSize = isCompact ? 40.0 : 48.0;
          final accentWidth = isCompact ? 42.0 : 64.0;
          final titleStyle =
              (isCompact
                      ? theme.textTheme.titleLarge
                      : theme.textTheme.headlineMedium)
                  ?.copyWith(fontWeight: FontWeight.w900);
          final subtitleStyle =
              (isCompact
                      ? theme.textTheme.bodyMedium
                      : theme.textTheme.bodyLarge)
                  ?.copyWith(
                    color: theme.colorScheme.onSurface.withAlpha(180),
                    fontWeight: FontWeight.w600,
                  );
          final eyebrowStyle = theme.textTheme.labelLarge?.copyWith(
            color: cs.primary,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.1,
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (showLogo) CamVoteLogo(showText: true, size: logoSize),
                  if (trailing != null) ...[const Spacer(), trailing!],
                ],
              ),
              SizedBox(height: isCompact ? 10 : 16),
              if (eyebrow != null && eyebrow!.trim().isNotEmpty) ...[
                Text(eyebrow!.toUpperCase(), style: eyebrowStyle),
                const SizedBox(height: 6),
              ],
              Text(title, style: titleStyle),
              SizedBox(height: isCompact ? 8 : 10),
              Container(
                width: accentWidth,
                height: 4,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  gradient: LinearGradient(
                    colors: [
                      cs.primary.withAlpha(220),
                      cs.tertiary.withAlpha(210),
                    ],
                  ),
                ),
              ),
              SizedBox(height: isCompact ? 6 : 8),
              Text(subtitle, style: subtitleStyle),
            ],
          );
        },
      ),
    );
  }
}
