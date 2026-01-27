import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:camvote/gen/l10n/app_localizations.dart';

import '../models/public_models.dart';
import 'cameroon_regions_map.dart';

class ResultsRegionMapCard extends StatefulWidget {
  const ResultsRegionMapCard({
    super.key,
    required this.winners,
    required this.labelsByRegionCode,
    required this.title,
    required this.subtitle,
    this.emptyMessage,
    this.nationalWinnerName,
  });

  final List<RegionalWinner> winners;
  final Map<String, String> labelsByRegionCode;

  final String title;
  final String subtitle;
  final String? emptyMessage;

  /// Optional (for a small badge)
  final String? nationalWinnerName;

  @override
  State<ResultsRegionMapCard> createState() => _ResultsRegionMapCardState();
}

class _ResultsRegionMapCardState extends State<ResultsRegionMapCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5200),
    )..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = AppLocalizations.of(context);

    // Build region fill + tags
    final fillByCode = <String, Color>{};
    final tagByCode = <String, String>{};

    for (final w in widget.winners) {
      fillByCode[w.regionCode] = w.winnerColor;
      tagByCode[w.regionCode] = _tagFromName(w.winnerName);
    }

    // Spotlight cycles through regions (winner spotlight animation)
    final allCodes = CameroonRegionsMap.regions.map((e) => e.code).toList();

    final hasData = widget.winners.isNotEmpty;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withAlpha(160),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                if (widget.nationalWinnerName != null &&
                    widget.nationalWinnerName!.trim().isNotEmpty)
                  _Pill(
                    text: widget.nationalWinnerName!,
                    icon: Icons.emoji_events_rounded,
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Map + legend
            LayoutBuilder(
              builder: (context, c) {
                final h = math.max(240.0, c.maxWidth * 0.62);

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Map
                    Expanded(
                      flex: 3,
                      child: SizedBox(
                        height: h,
                        child: AnimatedBuilder(
                          animation: _c,
                          builder: (context, child) {
                            final tValue =
                                Curves.easeInOutCubic.transform(_c.value);
                            final idx = (tValue * allCodes.length).floor().clamp(
                              0,
                              allCodes.length - 1,
                            );
                            final highlighted =
                                hasData ? allCodes[idx] : null;

                            return ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: Stack(
                                children: [
                                  Container(
                                    color: theme
                                        .colorScheme.surfaceContainerHighest
                                        .withAlpha(70),
                                    padding: const EdgeInsets.all(8),
                                    child: CameroonRegionsMap(
                                      fillByCode: fillByCode,
                                      labelsByCode: widget.labelsByRegionCode,
                                      winnerTagByCode: tagByCode,
                                      highlightedCode: highlighted,
                                      onRegionTap: hasData
                                          ? (code) =>
                                              _showRegionDetails(context, code)
                                          : null,
                                    ),
                                  ),
                                  if (!hasData)
                                    Positioned.fill(
                                      child: Container(
                                        color: theme.colorScheme.surface
                                            .withAlpha(180),
                                        child: Center(
                                          child: Text(
                                            widget.emptyMessage ??
                                                t.noData,
                                            textAlign: TextAlign.center,
                                            style: theme.textTheme.bodyMedium
                                                ?.copyWith(
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Legend
                    Expanded(
                      flex: 2,
                      child: _Legend(winners: widget.winners),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 10),
            Text(
              t.mapTapHint,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withAlpha(150),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRegionDetails(BuildContext context, String regionCode) {
    final theme = Theme.of(context);
    final t = AppLocalizations.of(context);
    final label = widget.labelsByRegionCode[regionCode] ?? regionCode;

    final w = widget.winners.firstWhere(
      (x) => x.regionCode == regionCode,
      orElse: () => const RegionalWinner(
        regionCode: '',
        winnerName: '—',
        winnerColor: Colors.grey,
        totalVotesInRegion: 0,
        winnerVotesInRegion: 0,
      ),
    );

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) {
        final share = w.totalVotesInRegion <= 0
            ? 0.0
            : (w.winnerVotesInRegion / w.totalVotesInRegion) * 100;

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: w.winnerColor.withAlpha(230),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      w.winnerName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Text(
                    '${share.toStringAsFixed(1)}%',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _kv(t.winnerVotesLabel, w.winnerVotesInRegion.toString()),
              _kv(t.totalVotesLabel, w.totalVotesInRegion.toString()),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Widget _kv(String k, String v) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: Text(
              k,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.onSurface.withAlpha(160),
              ),
            ),
          ),
          Text(
            v,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  String _tagFromName(String name) {
    final cleaned = name.trim();
    if (cleaned.isEmpty) return '';
    final parts = cleaned.split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts.first
          .substring(0, math.min(3, parts.first.length))
          .toUpperCase();
    }
    final a = parts.first.isNotEmpty ? parts.first[0] : '';
    final b = parts.last.isNotEmpty ? parts.last[0] : '';
    final t = ('$a$b').toUpperCase();
    return t.isEmpty
        ? cleaned.substring(0, math.min(3, cleaned.length)).toUpperCase()
        : t;
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.winners});

  final List<RegionalWinner> winners;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = AppLocalizations.of(context);

    // group by winner name + color
    final map = <String, _LegendRow>{};
    for (final w in winners) {
      final key = '${w.winnerName}__${w.winnerColor.toARGB32()}';
      map.putIfAbsent(
        key,
        () => _LegendRow(
          name: w.winnerName,
          color: w.winnerColor,
          regionsWon: 0,
          votes: 0,
        ),
      );
      final r = map[key]!;
      map[key] = r.copyWith(
        regionsWon: r.regionsWon + 1,
        votes: r.votes + w.winnerVotesInRegion,
      );
    }

    final rows = map.values.toList()
      ..sort((a, b) => b.regionsWon.compareTo(a.regionsWon));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.mapLegendTitle,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        ...rows.map(
          (r) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: r.color.withAlpha(230),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    r.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Text(
                  '${r.regionsWon}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: theme.colorScheme.onSurface.withAlpha(170),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _LegendRow {
  const _LegendRow({
    required this.name,
    required this.color,
    required this.regionsWon,
    required this.votes,
  });

  final String name;
  final Color color;
  final int regionsWon;
  final int votes;

  _LegendRow copyWith({
    String? name,
    Color? color,
    int? regionsWon,
    int? votes,
  }) {
    return _LegendRow(
      name: name ?? this.name,
      color: color ?? this.color,
      regionsWon: regionsWon ?? this.regionsWon,
      votes: votes ?? this.votes,
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.text, required this.icon});

  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: theme.colorScheme.surfaceContainerHighest.withAlpha(130),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withAlpha(90),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 6),
          Text(
            text,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
