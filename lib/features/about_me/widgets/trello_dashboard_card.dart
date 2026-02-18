import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:camvote/core/branding/brand_palette.dart';
import 'package:camvote/core/motion/cam_motion.dart';
import 'package:camvote/core/utils/external_links.dart';
import 'package:camvote/gen/l10n/app_localizations.dart';

import '../models/trello_stats.dart';

class TrelloDashboardCard extends StatefulWidget {
  const TrelloDashboardCard({
    super.key,
    required this.stats,
    this.isRefreshing = false,
  });

  final TrelloStats stats;
  final bool isRefreshing;

  @override
  State<TrelloDashboardCard> createState() => _TrelloDashboardCardState();
}

class _TrelloDashboardCardState extends State<TrelloDashboardCard> {
  bool _showAllLists = false;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final borderGradient = isDark
        ? BrandPalette.darkHeroGradient
        : BrandPalette.heroGradient;

    final listsSorted = [...widget.stats.lists]
      ..sort((a, b) {
        final byOpen = b.openCards.compareTo(a.openCards);
        if (byOpen != 0) return byOpen;
        return b.totalCards.compareTo(a.totalCards);
      });

    final listsShown = _showAllLists
        ? listsSorted
        : listsSorted.take(5).toList(growable: false);

    final total = math.max(0, widget.stats.totalCards);
    final done = math.max(0, widget.stats.doneCards);
    final open = math.max(0, widget.stats.openCards);
    final doneFrac = _safeFrac(done, total);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: DecoratedBox(
        decoration: BoxDecoration(gradient: borderGradient),
        child: Padding(
          padding: const EdgeInsets.all(1.3),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(18.7),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: IgnorePointer(
                    child: Opacity(
                      opacity: isDark ? 0.35 : 0.24,
                      child: _TrelloCardBackdrop(gradient: borderGradient),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _TrelloHeader(
                        boardName: widget.stats.boardName,
                        boardUrl: widget.stats.boardUrl,
                        isRefreshing: widget.isRefreshing,
                      ),
                      const SizedBox(height: 10),
                      _TrelloMetaRow(
                        lastActivityAt: widget.stats.lastActivityAt,
                        listsCount: widget.stats.lists.length,
                      ),
                      const SizedBox(height: 12),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final wide = constraints.maxWidth >= 520;

                          final kpis = _TrelloKpis(
                            total: total,
                            open: open,
                            done: done,
                          );

                          final progress = _TrelloProgressPanel(
                            doneFraction: doneFrac,
                            done: done,
                            total: total,
                          );

                          if (!wide) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                kpis,
                                const SizedBox(height: 12),
                                progress,
                              ],
                            );
                          }

                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: kpis),
                              const SizedBox(width: 12),
                              SizedBox(width: 180, child: progress),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              t.aboutTopListsLabel,
                              style: theme.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: widget.stats.lists.length <= 5
                                ? null
                                : () {
                                    setState(
                                      () => _showAllLists = !_showAllLists,
                                    );
                                  },
                            child: Text(
                              _showAllLists
                                  ? t.aboutTrelloShowTopLists
                                  : t.aboutTrelloShowAllLists,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      AnimatedSize(
                        duration: CamMotion.medium,
                        curve: CamMotion.emphasized,
                        alignment: Alignment.topCenter,
                        child: Column(
                          children: [
                            for (final l in listsShown) ...[
                              _TrelloListRow(stat: l),
                              const SizedBox(height: 8),
                            ],
                            if (!_showAllLists &&
                                widget.stats.lists.length > listsShown.length)
                              _MoreListsHint(
                                remaining:
                                    widget.stats.lists.length -
                                    listsShown.length,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

double _safeFrac(int numerator, int denominator) {
  if (denominator <= 0) return 0;
  final f = numerator / denominator;
  if (f.isNaN || !f.isFinite) return 0;
  return f.clamp(0, 1);
}

class _TrelloHeader extends StatelessWidget {
  const _TrelloHeader({
    required this.boardName,
    required this.boardUrl,
    required this.isRefreshing,
  });

  final String boardName;
  final String boardUrl;
  final bool isRefreshing;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final name = boardName.trim().isEmpty
        ? t.aboutTrelloTitle
        : boardName.trim();
    final url = boardUrl.trim();

    return Row(
      children: [
        const _TrelloIconBadge(),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        if (isRefreshing)
          Tooltip(
            message: t.refresh,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: cs.primary.withAlpha(14),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: cs.primary.withAlpha(60)),
              ),
              child: SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: cs.primary,
                ),
              ),
            ),
          ),
        const SizedBox(width: 8),
        Tooltip(
          message: t.aboutTrelloOpenBoard,
          child: IconButton.filledTonal(
            onPressed: url.isEmpty
                ? null
                : () => openExternalLink(context, url),
            icon: const Icon(Icons.open_in_new_rounded),
          ),
        ),
        const SizedBox(width: 6),
        Tooltip(
          message: t.aboutCopyBoardUrl,
          child: IconButton.filledTonal(
            onPressed: url.isEmpty
                ? null
                : () => _copyToClipboard(context, t.aboutBoardUrlLabel, url),
            icon: const Icon(Icons.link_rounded),
          ),
        ),
      ],
    );
  }
}

class _TrelloIconBadge extends StatelessWidget {
  const _TrelloIconBadge();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final grad = isDark
        ? BrandPalette.darkHeroGradient
        : BrandPalette.heroGradient;

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        gradient: grad,
        borderRadius: BorderRadius.circular(14),
        boxShadow: BrandPalette.softShadow,
      ),
      child: const Icon(Icons.view_kanban_rounded, color: Colors.white),
    );
  }
}

class _TrelloMetaRow extends StatelessWidget {
  const _TrelloMetaRow({
    required this.lastActivityAt,
    required this.listsCount,
  });

  final DateTime? lastActivityAt;
  final int listsCount;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    final last = lastActivityAt;
    final lastText = last == null ? null : _formatDate(last);

    return Wrap(
      spacing: 10,
      runSpacing: 8,
      children: [
        _MetaChip(
          icon: Icons.layers_outlined,
          label: t.aboutTrelloListsLabel,
          value: '$listsCount',
        ),
        if (lastText != null)
          _MetaChip(
            icon: Icons.schedule_rounded,
            label: t.aboutLastActivityLabel,
            value: lastText,
          ),
      ],
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final border = cs.outlineVariant.withAlpha(120);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withAlpha(80),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: cs.onSurface.withAlpha(170)),
          const SizedBox(width: 8),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: cs.onSurface.withAlpha(160),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            value,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _TrelloKpis extends StatelessWidget {
  const _TrelloKpis({
    required this.total,
    required this.open,
    required this.done,
  });

  final int total;
  final int open;
  final int done;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 420;
        if (isNarrow) {
          return Column(
            children: [
              _KpiPill(
                label: t.aboutStatTotal,
                value: total,
                color: BrandPalette.ocean,
                icon: Icons.inventory_2_outlined,
              ),
              const SizedBox(height: 10),
              _KpiPill(
                label: t.aboutStatOpen,
                value: open,
                color: BrandPalette.sunrise,
                icon: Icons.pending_actions_rounded,
              ),
              const SizedBox(height: 10),
              _KpiPill(
                label: t.aboutStatDone,
                value: done,
                color: BrandPalette.forest,
                icon: Icons.task_alt_rounded,
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(
              child: _KpiPill(
                label: t.aboutStatTotal,
                value: total,
                color: BrandPalette.ocean,
                icon: Icons.inventory_2_outlined,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _KpiPill(
                label: t.aboutStatOpen,
                value: open,
                color: BrandPalette.sunrise,
                icon: Icons.pending_actions_rounded,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _KpiPill(
                label: t.aboutStatDone,
                value: done,
                color: BrandPalette.forest,
                icon: Icons.task_alt_rounded,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _KpiPill extends StatelessWidget {
  const _KpiPill({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String label;
  final int value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final bg = color.withAlpha(isDark ? 20 : 18);
    final border = color.withAlpha(isDark ? 90 : 70);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: cs.surface.withAlpha(200),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: border.withAlpha(120)),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DefaultTextStyle(
                  style:
                      theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: cs.onSurface,
                      ) ??
                      const TextStyle(),
                  child: _AnimatedIntText(value: value),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: cs.onSurface.withAlpha(170),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TrelloProgressPanel extends StatelessWidget {
  const _TrelloProgressPanel({
    required this.doneFraction,
    required this.done,
    required this.total,
  });

  final double doneFraction;
  final int done;
  final int total;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final border = cs.outlineVariant.withAlpha(100);

    final percent = (doneFraction * 100).round();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
        color: cs.surfaceContainerHighest.withAlpha(50),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.insights_rounded, size: 18, color: cs.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  t.aboutTrelloProgressTitle,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox.square(
            dimension: 122,
            child: Stack(
              alignment: Alignment.center,
              children: [
                _AnimatedRing(doneFraction: doneFraction),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DefaultTextStyle(
                      style:
                          theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                          ) ??
                          const TextStyle(),
                      child: _AnimatedIntText(value: percent, suffix: '%'),
                    ),
                    Text(
                      t.aboutTrelloCompletionLabel,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: cs.onSurface.withAlpha(170),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$done/$total',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: cs.onSurface.withAlpha(160),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedRing extends StatefulWidget {
  const _AnimatedRing({required this.doneFraction});

  final double doneFraction;

  @override
  State<_AnimatedRing> createState() => _AnimatedRingState();
}

class _AnimatedRingState extends State<_AnimatedRing> {
  double _from = 0;

  @override
  void didUpdateWidget(covariant _AnimatedRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    _from = oldWidget.doneFraction;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final grad = isDark
        ? BrandPalette.darkHeroGradient
        : BrandPalette.heroGradient;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: _from, end: widget.doneFraction),
      duration: CamMotion.slow,
      curve: CamMotion.emphasized,
      builder: (context, v, _) {
        return CustomPaint(
          painter: _RingPainter(
            doneFraction: v,
            background: theme.colorScheme.onSurface.withAlpha(isDark ? 18 : 14),
            openColor: BrandPalette.sunrise.withAlpha(isDark ? 60 : 55),
            gradient: grad,
          ),
          child: const SizedBox.expand(),
        );
      },
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.doneFraction,
    required this.background,
    required this.openColor,
    required this.gradient,
  });

  final double doneFraction;
  final Color background;
  final Color openColor;
  final LinearGradient gradient;

  @override
  void paint(Canvas canvas, Size size) {
    final d = math.min(size.width, size.height);
    final stroke = d * 0.10;
    final center = size.center(Offset.zero);
    final r = (d / 2) - stroke / 2;

    final rect = Rect.fromCircle(center: center, radius: r);

    final base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = background;
    canvas.drawArc(rect, 0, math.pi * 2, false, base);

    final open = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = openColor;
    canvas.drawArc(rect, -math.pi / 2, math.pi * 2, false, open);

    final done = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..shader = gradient.createShader(rect);

    final sweep = (math.pi * 2) * doneFraction.clamp(0, 1);
    if (sweep <= 0) return;
    canvas.drawArc(rect, -math.pi / 2, sweep, false, done);
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.doneFraction != doneFraction ||
      oldDelegate.background != background ||
      oldDelegate.openColor != openColor ||
      oldDelegate.gradient != gradient;
}

class _TrelloListRow extends StatelessWidget {
  const _TrelloListRow({required this.stat});

  final TrelloListStat stat;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final total = math.max(0, stat.totalCards);
    final open = math.max(0, stat.openCards);
    final done = math.max(0, stat.doneCards);
    final doneFrac = _safeFrac(done, total);

    final border = cs.outlineVariant.withAlpha(100);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
        color: cs.surfaceContainerHighest.withAlpha(40),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  stat.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              _MiniMetric(
                icon: Icons.pending_actions_rounded,
                color: BrandPalette.sunrise,
                value: open,
              ),
              const SizedBox(width: 8),
              _MiniMetric(
                icon: Icons.task_alt_rounded,
                color: BrandPalette.forest,
                value: done,
              ),
            ],
          ),
          const SizedBox(height: 10),
          _ProgressBar(doneFraction: doneFrac),
          const SizedBox(height: 6),
          Text(
            '$open/$total',
            style: theme.textTheme.labelSmall?.copyWith(
              color: cs.onSurface.withAlpha(160),
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniMetric extends StatelessWidget {
  const _MiniMetric({
    required this.icon,
    required this.color,
    required this.value,
  });

  final IconData icon;
  final Color color;
  final int value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withAlpha(90)),
        color: color.withAlpha(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            '$value',
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: cs.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.doneFraction});

  final double doneFraction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bg = BrandPalette.sunrise.withAlpha(isDark ? 22 : 18);
    final fgStart = BrandPalette.forest.withAlpha(isDark ? 220 : 200);
    final fgEnd = BrandPalette.ocean.withAlpha(isDark ? 220 : 200);

    return LayoutBuilder(
      builder: (context, constraints) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: Stack(
            children: [
              Container(height: 10, width: double.infinity, color: bg),
              Container(
                height: 10,
                width: constraints.maxWidth * doneFraction.clamp(0, 1),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [fgStart, fgEnd]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MoreListsHint extends StatelessWidget {
  const _MoreListsHint({required this.remaining});

  final int remaining;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Text(
        '+$remaining',
        style: theme.textTheme.labelSmall?.copyWith(
          color: cs.onSurface.withAlpha(140),
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _AnimatedIntText extends StatefulWidget {
  const _AnimatedIntText({required this.value, this.suffix});

  final int value;
  final String? suffix;

  @override
  State<_AnimatedIntText> createState() => _AnimatedIntTextState();
}

class _AnimatedIntTextState extends State<_AnimatedIntText> {
  int _from = 0;

  @override
  void didUpdateWidget(covariant _AnimatedIntText oldWidget) {
    super.didUpdateWidget(oldWidget);
    _from = oldWidget.value;
  }

  @override
  Widget build(BuildContext context) {
    final suffix = widget.suffix ?? '';
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(
        begin: _from.toDouble(),
        end: widget.value.toDouble(),
      ),
      duration: CamMotion.slow,
      curve: CamMotion.emphasized,
      builder: (context, v, _) => Text('${v.round()}$suffix'),
    );
  }
}

class _TrelloCardBackdrop extends StatelessWidget {
  const _TrelloCardBackdrop({required this.gradient});

  final LinearGradient gradient;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.topRight,
          radius: 1.1,
          colors: [gradient.colors.first.withAlpha(70), Colors.transparent],
        ),
      ),
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Container(
          width: 220,
          height: 220,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 0.9,
              colors: [cs.primary.withAlpha(40), Colors.transparent],
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> _copyToClipboard(
  BuildContext context,
  String label,
  String value,
) async {
  final t = AppLocalizations.of(context);
  await Clipboard.setData(ClipboardData(text: value));
  if (!context.mounted) return;
  ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(t.copiedMessage(label))));
}

String _formatDate(DateTime dt) {
  final y = dt.year.toString().padLeft(4, '0');
  final m = dt.month.toString().padLeft(2, '0');
  final d = dt.day.toString().padLeft(2, '0');
  final h = dt.hour.toString().padLeft(2, '0');
  final min = dt.minute.toString().padLeft(2, '0');
  return '$y-$m-$d $h:$min';
}
