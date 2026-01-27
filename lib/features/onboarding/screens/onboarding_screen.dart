import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:camvote/gen/l10n/app_localizations.dart';

import '../../../core/branding/brand_backdrop.dart';
import '../../../core/branding/brand_logo.dart';
import '../../../core/branding/brand_palette.dart';
import '../../../core/config/app_settings_controller.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/motion/cam_reveal.dart';
import '../../../core/routing/route_paths.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final slides = _buildSlides(t);
    final isLastSlide = _index == slides.length - 1;

    return Scaffold(
      body: BrandBackdrop(
        child: SafeArea(
          child: ResponsiveContent(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxHeight < 640;
                final heroHeight = isCompact ? 200.0 : 240.0;
                final pageHeight =
                    math.max(280.0, constraints.maxHeight * (isCompact ? 0.48 : 0.55));

                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const CamVoteLogo(showText: true, size: 40),
                            TextButton(
                              onPressed: _finish,
                              child: Text(t.onboardingSkip),
                            ),
                          ],
                        ),
                        SizedBox(height: isCompact ? 10 : 16),
                        Text(
                          t.slogan,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        SizedBox(height: isCompact ? 10 : 16),
                        SizedBox(
                          height: pageHeight,
                          child: PageView.builder(
                            controller: _controller,
                            itemCount: slides.length,
                            onPageChanged: (i) => setState(() => _index = i),
                            itemBuilder: (context, i) {
                              return _SlideCard(
                                slide: slides[i],
                                heroHeight: heroHeight,
                              );
                            },
                          ),
                        ),
                        SizedBox(height: isCompact ? 10 : 16),
                        _PageIndicator(count: slides.length, index: _index),
                        SizedBox(height: isCompact ? 10 : 16),
                        Row(
                          children: [
                            if (_index > 0)
                              OutlinedButton(
                                onPressed: _back,
                                child: Text(t.onboardingBack),
                              ),
                            const Spacer(),
                            FilledButton.icon(
                              onPressed: _next,
                              icon: Icon(
                                isLastSlide
                                    ? Icons.rocket_launch
                                    : Icons.arrow_forward,
                              ),
                              label: Text(
                                isLastSlide ? t.onboardingEnter : t.onboardingNext,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _back() {
    if (_index == 0) return;
    _controller.previousPage(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  void _next() {
    if (_index >= _buildSlides(AppLocalizations.of(context)).length - 1) {
      _finish();
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _finish() async {
    await ref.read(appSettingsProvider.notifier).setOnboardingSeen(true);
    if (!mounted) return;
    context.go(RoutePaths.gateway);
  }

  List<_OnboardingSlide> _buildSlides(AppLocalizations t) {
    return [
      _OnboardingSlide(
        icon: Icons.verified_user_outlined,
        title: t.onboardingSlide1Title,
        subtitle: t.onboardingSlide1Subtitle,
        highlights: [
          t.onboardingSlide1Highlight1,
          t.onboardingSlide1Highlight2,
          t.onboardingSlide1Highlight3,
        ],
        colors: const [
          BrandPalette.sunrise,
          BrandPalette.ember,
          BrandPalette.forest,
        ],
      ),
      _OnboardingSlide(
        icon: Icons.public,
        title: t.onboardingSlide2Title,
        subtitle: t.onboardingSlide2Subtitle,
        highlights: [
          t.onboardingSlide2Highlight1,
          t.onboardingSlide2Highlight2,
          t.onboardingSlide2Highlight3,
        ],
        colors: const [
          BrandPalette.ocean,
          BrandPalette.forest,
          BrandPalette.sunrise,
        ],
      ),
      _OnboardingSlide(
        icon: Icons.shield_outlined,
        title: t.onboardingSlide3Title,
        subtitle: t.onboardingSlide3Subtitle,
        highlights: [
          t.onboardingSlide3Highlight1,
          t.onboardingSlide3Highlight2,
          t.onboardingSlide3Highlight3,
        ],
        colors: const [
          BrandPalette.ember,
          BrandPalette.ocean,
          BrandPalette.inkSoft,
        ],
      ),
    ];
  }
}

class _SlideCard extends StatelessWidget {
  final _OnboardingSlide slide;
  final double heroHeight;

  const _SlideCard({
    required this.slide,
    required this.heroHeight,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return CamReveal(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HeroPanel(slide: slide, height: heroHeight),
          const SizedBox(height: 18),
          Text(
            slide.title,
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            slide.subtitle,
            style: textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withAlpha(180),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: slide.highlights.map((text) {
              return Chip(
                label: Text(text),
                backgroundColor:
                    theme.colorScheme.surfaceContainerHighest.withAlpha(190),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _HeroPanel extends StatelessWidget {
  final _OnboardingSlide slide;
  final double height;

  const _HeroPanel({
    required this.slide,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: LinearGradient(
          colors: slide.colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: BrandPalette.softShadow,
      ),
      child: Stack(
        children: [
          Positioned(
            right: -40,
            top: -20,
            child: _GlowOrb(color: Colors.white.withAlpha(50), size: 140),
          ),
          Positioned(
            left: -30,
            bottom: -40,
            child: _GlowOrb(color: Colors.black.withAlpha(40), size: 160),
          ),
          Center(
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withAlpha(235),
              ),
              child: Icon(slide.icon, size: 62, color: BrandPalette.ink),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  final Color color;
  final double size;

  const _GlowOrb({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}

class _PageIndicator extends StatelessWidget {
  final int count;
  final int index;

  const _PageIndicator({required this.count, required this.index});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 8,
          width: active ? 26 : 10,
          decoration: BoxDecoration(
            color: active ? cs.primary : cs.outline.withAlpha(120),
            borderRadius: BorderRadius.circular(12),
          ),
        );
      }),
    );
  }
}

class _OnboardingSlide {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<String> highlights;
  final List<Color> colors;

  const _OnboardingSlide({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.highlights,
    required this.colors,
  });
}
