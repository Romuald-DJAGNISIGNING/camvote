import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:camvote/gen/l10n/app_localizations.dart';

import '../../../core/branding/brand_logo.dart';
import '../../../core/branding/brand_palette.dart';
import '../../../core/config/app_settings_controller.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/routing/route_paths.dart';
import '../../notifications/widgets/notification_app_bar.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _controller = PageController();
  int _index = 0;
  bool _isFinishing = false;

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
      appBar: NotificationAppBar(
        showBack: false,
        showBell: false,
        title: CamVoteLogo(showText: true, size: 30),
      ),
      body: SafeArea(
        child: ResponsiveContent(
          padding: EdgeInsets.zero,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxHeight < 640;
              final isTight = constraints.maxHeight < 600;
              final horizontalPad = constraints.maxWidth < 360 ? 12.0 : 16.0;
              final verticalPad = isTight ? 6.0 : (isCompact ? 10.0 : 16.0);

              return Padding(
                padding: EdgeInsets.fromLTRB(
                  horizontalPad,
                  verticalPad,
                  horizontalPad,
                  isCompact ? 16 : 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _finish,
                        child: Text(t.onboardingSkip),
                      ),
                    ),
                    SizedBox(height: isTight ? 2 : (isCompact ? 4 : 8)),
                    Text(
                      t.slogan,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style:
                          (isCompact
                                  ? Theme.of(context).textTheme.titleSmall
                                  : Theme.of(context).textTheme.titleMedium)
                              ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    SizedBox(height: isTight ? 4 : (isCompact ? 6 : 12)),
                    Expanded(
                      child: PageView.builder(
                        controller: _controller,
                        allowImplicitScrolling: true,
                        physics: kIsWeb
                            ? const ClampingScrollPhysics()
                            : const PageScrollPhysics(),
                        itemCount: slides.length,
                        onPageChanged: (i) {
                          if (i == _index) return;
                          setState(() => _index = i);
                        },
                        itemBuilder: (context, i) {
                          return _SlideCard(
                            slide: slides[i],
                            isActive: i == _index,
                          );
                        },
                      ),
                    ),
                    SizedBox(height: isTight ? 4 : (isCompact ? 6 : 10)),
                    _PageIndicator(count: slides.length, index: _index),
                    SizedBox(height: isTight ? 4 : (isCompact ? 6 : 12)),
                    LayoutBuilder(
                      builder: (context, btnConstraints) {
                        final stack = btnConstraints.maxWidth < 360;
                        if (stack) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (_index > 0)
                                OutlinedButton(
                                  onPressed: _back,
                                  child: Text(t.onboardingBack),
                                ),
                              if (_index > 0) const SizedBox(height: 10),
                              FilledButton.icon(
                                onPressed: () => _next(slides.length),
                                icon: Icon(
                                  isLastSlide
                                      ? Icons.rocket_launch
                                      : Icons.arrow_forward,
                                ),
                                label: Text(
                                  isLastSlide
                                      ? t.onboardingEnter
                                      : t.onboardingNext,
                                ),
                              ),
                            ],
                          );
                        }
                        return Row(
                          children: [
                            if (_index > 0)
                              OutlinedButton(
                                onPressed: _back,
                                child: Text(t.onboardingBack),
                              ),
                            const Spacer(),
                            FilledButton.icon(
                              onPressed: () => _next(slides.length),
                              icon: Icon(
                                isLastSlide
                                    ? Icons.rocket_launch
                                    : Icons.arrow_forward,
                              ),
                              label: Text(
                                isLastSlide
                                    ? t.onboardingEnter
                                    : t.onboardingNext,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _back() {
    if (_index == 0) return;
    _controller.previousPage(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }

  void _next(int slideCount) {
    if (_index >= slideCount - 1) {
      _finish();
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }

  void _finish() {
    if (_isFinishing) return;
    _isFinishing = true;
    ref.read(onboardingSessionBypassProvider.notifier).enable();

    final target = _resolveExitTarget();
    try {
      if (!mounted) return;
      context.go(target);
    } catch (_) {
      _isFinishing = false;
      return;
    }

    // Persist asynchronously after navigation; never block onboarding exit.
    unawaited(
      ref.read(appSettingsProvider.notifier).setOnboardingSeen(true).catchError(
        (error, stackTrace) {
          // Ignore storage failures; session bypass already avoids loops.
        },
      ),
    );

    // Safety reset so user is never locked out if router stalls.
    unawaited(
      Future<void>.delayed(const Duration(milliseconds: 900), () {
        if (!mounted) return;
        final current = _matchedLocation();
        if (current == RoutePaths.onboarding) {
          _isFinishing = false;
        }
      }),
    );
  }

  String _matchedLocation() {
    try {
      return GoRouterState.of(context).matchedLocation;
    } catch (_) {
      return RoutePaths.onboarding;
    }
  }

  String _resolveExitTarget() {
    if (!kIsWeb) return RoutePaths.gateway;

    String? from;
    try {
      from = GoRouterState.of(context).uri.queryParameters['from'];
    } catch (_) {
      from = null;
    }
    from ??= _queryFromFragment('from');
    final sanitizedFrom = _sanitizeFromTarget(from);
    if (sanitizedFrom != null) return sanitizedFrom;

    final entry = _resolvePortalEntry();
    return entry == 'admin' ? RoutePaths.adminPortal : RoutePaths.webPortal;
  }

  String? _sanitizeFromTarget(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final trimmed = raw.trim();
    final parsed = Uri.tryParse(trimmed);
    if (parsed == null) return null;
    if (!trimmed.startsWith('/')) return null;
    if (parsed.path == RoutePaths.onboarding) return null;
    return parsed.toString();
  }

  String? _queryFromFragment(String key) {
    final fragment = Uri.base.fragment;
    if (fragment.isEmpty) return null;
    final normalized = fragment.startsWith('/') ? fragment : '/$fragment';
    final parsed = Uri.tryParse(normalized);
    return parsed?.queryParameters[key];
  }

  String? _resolvePortalEntry() {
    if (!kIsWeb) return null;

    String? queryEntry;
    try {
      queryEntry = GoRouterState.of(context).uri.queryParameters['entry'];
    } catch (_) {
      queryEntry = null;
    }
    queryEntry ??= Uri.base.queryParameters['entry'];
    if (queryEntry == 'admin' || queryEntry == 'general') {
      return queryEntry;
    }

    final fragment = Uri.base.fragment;
    if (fragment.isNotEmpty) {
      final normalized = fragment.startsWith('/') ? fragment : '/$fragment';
      final parsed = Uri.tryParse(normalized);
      final fragmentEntry = parsed?.queryParameters['entry'];
      if (fragmentEntry == 'admin' || fragmentEntry == 'general') {
        return fragmentEntry;
      }
      final fragmentPath = parsed?.path.toLowerCase() ?? '';
      if (fragmentPath.contains('/backoffice')) return 'admin';
      if (fragmentPath.contains('/portal')) return 'general';
    }

    final basePath = Uri.base.path.toLowerCase();
    if (basePath.contains('/backoffice')) return 'admin';
    if (basePath.contains('/portal')) return 'general';

    return 'general';
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
  final bool isActive;

  const _SlideCard({required this.slide, required this.isActive});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final cs = theme.colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxHeight = constraints.maxHeight;
        final isCompact = maxHeight < 520;
        final heroHeight = math.max(
          120.0,
          math.min(
            isCompact ? 170.0 : 230.0,
            maxHeight * (isCompact ? 0.38 : 0.48),
          ),
        );

        final content = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HeroPanel(slide: slide, height: heroHeight, isActive: isActive),
            SizedBox(height: isCompact ? 12 : 18),
            Text(
              slide.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(height: isCompact ? 6 : 8),
            Text(
              slide.subtitle,
              maxLines: isCompact ? 3 : 4,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withAlpha(180),
              ),
            ),
            SizedBox(height: isCompact ? 12 : 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: slide.highlights.map((text) {
                return Chip(
                  label: Text(text),
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest
                      .withAlpha(190),
                );
              }).toList(),
            ),
          ],
        );

        final framedContent = AnimatedScale(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          scale: isActive ? 1 : 0.984,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            opacity: isActive ? 1 : 0.92,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeOutCubic,
              padding: EdgeInsets.all(isCompact ? 12 : 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    cs.surface.withAlpha(236),
                    cs.surfaceContainerHighest.withAlpha(isActive ? 165 : 126),
                  ],
                ),
                border: Border.all(
                  color: isActive
                      ? cs.primary.withAlpha(94)
                      : cs.outlineVariant.withAlpha(120),
                ),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: cs.primary.withAlpha(36),
                          blurRadius: 20,
                          offset: const Offset(0, 12),
                        ),
                      ]
                    : BrandPalette.softShadow,
              ),
              child: content,
            ),
          ),
        );

        if (!isCompact) {
          return RepaintBoundary(child: framedContent);
        }

        return RepaintBoundary(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: framedContent,
            ),
          ),
        );
      },
    );
  }
}

class _HeroPanel extends StatelessWidget {
  final _OnboardingSlide slide;
  final double height;
  final bool isActive;

  const _HeroPanel({
    required this.slide,
    required this.height,
    required this.isActive,
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
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
              child: AnimatedScale(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutCubic,
                scale: isActive ? 1 : 0.92,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeOutCubic,
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withAlpha(isActive ? 238 : 220),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(isActive ? 28 : 12),
                        blurRadius: isActive ? 22 : 10,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(slide.icon, size: 62, color: BrandPalette.ink),
                ),
              ),
            ),
          ],
        ),
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
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
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
