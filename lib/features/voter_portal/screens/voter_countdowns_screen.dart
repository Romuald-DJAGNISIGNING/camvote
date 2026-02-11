import 'package:camvote/core/errors/error_message.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/branding/brand_backdrop.dart';
import '../../../core/branding/brand_header.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/motion/cam_reveal.dart';
import '../../../core/routing/route_paths.dart';
import '../../../core/widgets/loaders/cameroon_election_loader.dart';
import '../../../core/widgets/sections/cam_section_header.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../domain/election.dart';
import '../domain/voter_countdown_profile.dart';
import '../providers/voter_portal_providers.dart';

const _kEligibilityAge = 20;

class VoterCountdownsScreen extends ConsumerStatefulWidget {
  const VoterCountdownsScreen({super.key});

  @override
  ConsumerState<VoterCountdownsScreen> createState() =>
      _VoterCountdownsScreenState();
}

class _VoterCountdownsScreenState extends ConsumerState<VoterCountdownsScreen> {
  Timer? _ticker;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final electionsAsync = ref.watch(voterElectionsProvider);
    final profileAsync = ref.watch(voterCountdownProfileProvider);

    if (electionsAsync.isLoading && profileAsync.isLoading) {
      return const Center(child: CamElectionLoader());
    }

    final elections = electionsAsync.asData?.value ?? const <Election>[];
    final profile = profileAsync.asData?.value;

    final items = _buildCountdowns(context, t, _now, elections, profile);

    final electionItems = items.where((item) => item.kind.isElection).toList();
    final personalItems = items.where((item) => !item.kind.isElection).toList();

    final nextItem = items.isEmpty
        ? null
        : (items.toList()..sort(
                (a, b) => a.remaining(_now).compareTo(b.remaining(_now)),
              ))
              .first;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(t.countdownsTitle),
      ),
      body: BrandBackdrop(
        child: ResponsiveContent(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              CamStagger(
                children: [
                  const SizedBox(height: 6),
                  BrandHeader(
                    title: t.countdownsTitle,
                    subtitle: t.countdownsSubtitle,
                  ),
                  const SizedBox(height: 12),
                  if (electionsAsync.hasError)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          safeErrorMessage(context, electionsAsync.error),
                        ),
                      ),
                    ),
                  if (profileAsync.hasError)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          safeErrorMessage(context, profileAsync.error),
                        ),
                      ),
                    ),
                  if (items.isEmpty)
                    _EmptyCountdownState(
                      title: t.countdownNoTimersTitle,
                      body: t.countdownNoTimersBody,
                    )
                  else ...[
                    if (nextItem != null)
                      _CountdownHeroCard(item: nextItem, now: _now),
                    if (electionItems.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      CamSectionHeader(
                        title: t.countdownElectionsSectionTitle,
                        icon: Icons.how_to_vote_outlined,
                      ),
                      const SizedBox(height: 6),
                      ...electionItems.map(
                        (item) => _CountdownCard(item: item, now: _now),
                      ),
                    ],
                    if (personalItems.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      CamSectionHeader(
                        title: t.countdownPersonalSectionTitle,
                        icon: Icons.person_outline,
                      ),
                      const SizedBox(height: 6),
                      ...personalItems.map(
                        (item) => _CountdownCard(item: item, now: _now),
                      ),
                    ],
                  ],
                  const SizedBox(height: 20),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<_CountdownItem> _buildCountdowns(
    BuildContext context,
    AppLocalizations t,
    DateTime now,
    List<Election> elections,
    VoterCountdownProfile? profile,
  ) {
    final items = <_CountdownItem>[];

    for (final election in elections) {
      if (election.status == ElectionStatus.upcoming) {
        items.add(
          _CountdownItem(
            id: 'open_${election.id}',
            kind: _CountdownKind.electionOpen,
            title: election.title,
            subtitle: t.countdownElectionOpensTitle,
            targetAt: election.opensAt,
            icon: Icons.how_to_vote_outlined,
          ),
        );
      } else if (election.status == ElectionStatus.open) {
        items.add(
          _CountdownItem(
            id: 'close_${election.id}',
            kind: _CountdownKind.electionClose,
            title: election.title,
            subtitle: t.countdownElectionClosesTitle,
            targetAt: election.closesAt,
            icon: Icons.timer_outlined,
          ),
        );
      }

      final registrationDeadline = election.registrationDeadline;
      if (registrationDeadline != null && !registrationDeadline.isBefore(now)) {
        items.add(
          _CountdownItem(
            id: 'registration_${election.id}',
            kind: _CountdownKind.registrationDeadline,
            title: election.title,
            subtitle: t.countdownRegistrationDeadlineTitle,
            targetAt: registrationDeadline,
            icon: Icons.assignment_outlined,
          ),
        );
      }

      final campaignStartsAt = election.campaignStartsAt;
      if (campaignStartsAt != null && !campaignStartsAt.isBefore(now)) {
        items.add(
          _CountdownItem(
            id: 'campaign_start_${election.id}',
            kind: _CountdownKind.campaignStart,
            title: election.title,
            subtitle: t.countdownCampaignStartsTitle,
            targetAt: campaignStartsAt,
            icon: Icons.campaign_outlined,
          ),
        );
      }

      final campaignEndsAt = election.campaignEndsAt;
      if (campaignEndsAt != null && !campaignEndsAt.isBefore(now)) {
        items.add(
          _CountdownItem(
            id: 'campaign_end_${election.id}',
            kind: _CountdownKind.campaignEnd,
            title: election.title,
            subtitle: t.countdownCampaignEndsTitle,
            targetAt: campaignEndsAt,
            icon: Icons.campaign_outlined,
          ),
        );
      }

      final resultsPublishAt = election.resultsPublishAt;
      if (resultsPublishAt != null && !resultsPublishAt.isBefore(now)) {
        items.add(
          _CountdownItem(
            id: 'results_${election.id}',
            kind: _CountdownKind.resultsPublish,
            title: election.title,
            subtitle: t.countdownResultsPublishTitle,
            targetAt: resultsPublishAt,
            icon: Icons.bar_chart_outlined,
          ),
        );
      }

      final runoffOpensAt = election.runoffOpensAt;
      if (runoffOpensAt != null && !runoffOpensAt.isBefore(now)) {
        items.add(
          _CountdownItem(
            id: 'runoff_open_${election.id}',
            kind: _CountdownKind.runoffOpen,
            title: election.title,
            subtitle: t.countdownRunoffOpensTitle,
            targetAt: runoffOpensAt,
            icon: Icons.how_to_vote_outlined,
          ),
        );
      }

      final runoffClosesAt = election.runoffClosesAt;
      if (runoffClosesAt != null && !runoffClosesAt.isBefore(now)) {
        items.add(
          _CountdownItem(
            id: 'runoff_close_${election.id}',
            kind: _CountdownKind.runoffClose,
            title: election.title,
            subtitle: t.countdownRunoffClosesTitle,
            targetAt: runoffClosesAt,
            icon: Icons.timer_outlined,
          ),
        );
      }
    }

    if (profile != null) {
      final cardExpiry = profile.cardExpiry;
      if (cardExpiry != null) {
        items.add(
          _CountdownItem(
            id: 'card_expiry',
            kind: _CountdownKind.cardExpiry,
            title: t.countdownCardExpiryTitle,
            subtitle: t.countdownCardExpiryBody(
              _formatDate(context, cardExpiry),
            ),
            targetAt: cardExpiry,
            icon: Icons.credit_card_outlined,
            actionLabel: t.countdownRenewCardAction,
            onAction: () => context.push(RoutePaths.register),
          ),
        );
      }

      final eligibleAt =
          profile.eligibleAt ?? _computeEligibilityDate(profile.dateOfBirth);
      if (profile.isPreEligible && eligibleAt != null) {
        final remaining = eligibleAt.difference(now);
        if (!remaining.isNegative || remaining.inDays >= -2) {
          items.add(
            _CountdownItem(
              id: 'eligibility',
              kind: _CountdownKind.eligibility,
              title: t.countdownEligibilityTitle,
              subtitle: t.countdownEligibilityBody(
                _formatDate(context, eligibleAt),
              ),
              targetAt: eligibleAt,
              icon: Icons.auto_awesome_outlined,
              celebrate: true,
            ),
          );
        }
      }

      if (profile.isSuspended && profile.suspensionEndsAt != null) {
        final endAt = profile.suspensionEndsAt!;
        final remaining = endAt.difference(now);
        if (!remaining.isNegative) {
          items.add(
            _CountdownItem(
              id: 'suspension',
              kind: _CountdownKind.suspension,
              title: t.countdownSuspensionTitle,
              subtitle: t.countdownSuspensionBody(_formatDate(context, endAt)),
              targetAt: endAt,
              icon: Icons.block_outlined,
            ),
          );
        }
      }
    }

    return items;
  }

  DateTime? _computeEligibilityDate(DateTime? dob) {
    if (dob == null) return null;
    return DateTime(dob.year + _kEligibilityAge, dob.month, dob.day);
  }

  String _formatDate(BuildContext context, DateTime value) {
    return MaterialLocalizations.of(context).formatMediumDate(value);
  }
}

enum _CountdownKind {
  electionOpen,
  electionClose,
  registrationDeadline,
  campaignStart,
  campaignEnd,
  resultsPublish,
  runoffOpen,
  runoffClose,
  cardExpiry,
  eligibility,
  suspension,
}

extension on _CountdownKind {
  bool get isElection => switch (this) {
    _CountdownKind.electionOpen ||
    _CountdownKind.electionClose ||
    _CountdownKind.registrationDeadline ||
    _CountdownKind.campaignStart ||
    _CountdownKind.campaignEnd ||
    _CountdownKind.resultsPublish ||
    _CountdownKind.runoffOpen ||
    _CountdownKind.runoffClose => true,
    _ => false,
  };
}

class _CountdownItem {
  final String id;
  final _CountdownKind kind;
  final String title;
  final String subtitle;
  final DateTime targetAt;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool celebrate;

  const _CountdownItem({
    required this.id,
    required this.kind,
    required this.title,
    required this.subtitle,
    required this.targetAt,
    required this.icon,
    this.actionLabel,
    this.onAction,
    this.celebrate = false,
  });

  Duration remaining(DateTime now) => targetAt.difference(now);
}

class _CountdownHeroCard extends StatelessWidget {
  const _CountdownHeroCard({required this.item, required this.now});

  final _CountdownItem item;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final tone = _CountdownTone.of(context, item.kind);
    final remaining = item.remaining(now);

    return Card(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            colors: tone.gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.white.withAlpha(30),
                  child: Icon(item.icon, color: Colors.white),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    item.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              item.subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white.withAlpha(220),
              ),
            ),
            const SizedBox(height: 12),
            _CountdownDigits(
              remaining: remaining,
              accent: Colors.white,
              hero: true,
            ),
            if (item.celebrate) _CelebrateBanner(show: remaining.isNegative),
            if (item.actionLabel != null && item.onAction != null) ...[
              const SizedBox(height: 12),
              FilledButton(
                onPressed: item.onAction,
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: tone.primary,
                ),
                child: Text(item.actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CountdownCard extends StatelessWidget {
  const _CountdownCard({required this.item, required this.now});

  final _CountdownItem item;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final tone = _CountdownTone.of(context, item.kind);
    final remaining = item.remaining(now);
    final expired = remaining.isNegative;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: tone.primary.withAlpha(18),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(item.icon, color: tone.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.subtitle,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                if (expired)
                  Chip(
                    label: Text(t.countdownExpiredLabel),
                    backgroundColor: tone.primary.withAlpha(18),
                    labelStyle: TextStyle(color: tone.primary),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            _CountdownDigits(remaining: remaining, accent: tone.primary),
            if (item.kind == _CountdownKind.cardExpiry &&
                _isExpirySoon(remaining)) ...[
              const SizedBox(height: 10),
              Text(
                t.countdownCardExpiryWarning,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            if (item.celebrate) _CelebrateBanner(show: remaining.isNegative),
            if (item.actionLabel != null && item.onAction != null) ...[
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: item.onAction,
                icon: const Icon(Icons.refresh_outlined),
                label: Text(item.actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }

  bool _isExpirySoon(Duration remaining) {
    if (remaining.isNegative) return true;
    return remaining.inDays <= 90;
  }
}

class _CountdownDigits extends StatelessWidget {
  const _CountdownDigits({
    required this.remaining,
    required this.accent,
    this.hero = false,
  });

  final Duration remaining;
  final Color accent;
  final bool hero;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final safe = remaining.isNegative ? Duration.zero : remaining;
    final days = safe.inDays;
    final hours = safe.inHours % 24;
    final minutes = safe.inMinutes % 60;
    final seconds = safe.inSeconds % 60;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _DigitPill(
          label: t.nextElectionCountdownLabelDays,
          value: days.toString(),
          accent: accent,
          hero: hero,
        ),
        _DigitPill(
          label: t.nextElectionCountdownLabelHours,
          value: _two(hours),
          accent: accent,
          hero: hero,
        ),
        _DigitPill(
          label: t.nextElectionCountdownLabelMinutes,
          value: _two(minutes),
          accent: accent,
          hero: hero,
        ),
        _DigitPill(
          label: t.nextElectionCountdownLabelSeconds,
          value: _two(seconds),
          accent: accent,
          hero: hero,
        ),
      ],
    );
  }

  String _two(int v) => v.toString().padLeft(2, '0');
}

class _DigitPill extends StatelessWidget {
  const _DigitPill({
    required this.label,
    required this.value,
    required this.accent,
    this.hero = false,
  });

  final String label;
  final String value;
  final Color accent;
  final bool hero;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyle = hero
        ? theme.textTheme.headlineSmall
        : theme.textTheme.titleMedium;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: accent.withAlpha(hero ? 28 : 16),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withAlpha(80)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 320),
            transitionBuilder: (child, animation) => ScaleTransition(
              scale: CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutBack,
              ),
              child: child,
            ),
            child: Text(
              value,
              key: ValueKey(value),
              style: textStyle?.copyWith(
                fontWeight: FontWeight.w900,
                color: hero ? Colors.white : accent,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: hero ? Colors.white.withAlpha(230) : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _CelebrateBanner extends StatelessWidget {
  const _CelebrateBanner({required this.show});

  final bool show;

  @override
  Widget build(BuildContext context) {
    if (!show) return const SizedBox.shrink();
    final t = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.9, end: 1),
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeOutBack,
        builder: (context, value, child) =>
            Transform.scale(scale: value, child: child),
        child: Row(
          children: [
            const Icon(Icons.celebration_outlined, color: Colors.orange),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                t.countdownEligibilityCelebrate,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyCountdownState extends StatelessWidget {
  const _EmptyCountdownState({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            const Icon(Icons.timer_off_outlined),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(body),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CountdownTone {
  final Color primary;
  final List<Color> gradient;

  const _CountdownTone({required this.primary, required this.gradient});

  static _CountdownTone of(BuildContext context, _CountdownKind kind) {
    final cs = Theme.of(context).colorScheme;
    switch (kind) {
      case _CountdownKind.electionOpen:
        return _CountdownTone(
          primary: cs.primary,
          gradient: [cs.primary.withAlpha(200), cs.tertiary.withAlpha(180)],
        );
      case _CountdownKind.electionClose:
        return _CountdownTone(
          primary: cs.error,
          gradient: [cs.error.withAlpha(210), cs.primary.withAlpha(140)],
        );
      case _CountdownKind.registrationDeadline:
        return _CountdownTone(
          primary: cs.tertiary,
          gradient: [cs.tertiary.withAlpha(200), cs.primary.withAlpha(140)],
        );
      case _CountdownKind.campaignStart:
        return _CountdownTone(
          primary: cs.secondary,
          gradient: [cs.secondary.withAlpha(210), cs.primary.withAlpha(150)],
        );
      case _CountdownKind.campaignEnd:
        return _CountdownTone(
          primary: Colors.deepOrange,
          gradient: [
            Colors.deepOrange.withAlpha(210),
            Colors.orange.withAlpha(160),
          ],
        );
      case _CountdownKind.resultsPublish:
        return _CountdownTone(
          primary: cs.secondary,
          gradient: [cs.secondary.withAlpha(210), cs.tertiary.withAlpha(140)],
        );
      case _CountdownKind.runoffOpen:
        return _CountdownTone(
          primary: cs.primary,
          gradient: [cs.primary.withAlpha(200), cs.secondary.withAlpha(150)],
        );
      case _CountdownKind.runoffClose:
        return _CountdownTone(
          primary: cs.error,
          gradient: [cs.error.withAlpha(210), cs.primary.withAlpha(140)],
        );
      case _CountdownKind.cardExpiry:
        return _CountdownTone(
          primary: Colors.orange,
          gradient: [
            Colors.orange.withAlpha(210),
            Colors.deepOrange.withAlpha(160),
          ],
        );
      case _CountdownKind.eligibility:
        return _CountdownTone(
          primary: cs.secondary,
          gradient: [cs.secondary.withAlpha(210), cs.primary.withAlpha(150)],
        );
      case _CountdownKind.suspension:
        return _CountdownTone(
          primary: cs.outline,
          gradient: [cs.outline.withAlpha(200), cs.surfaceTint.withAlpha(150)],
        );
    }
  }
}

