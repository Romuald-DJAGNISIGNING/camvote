import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:camvote/gen/l10n/app_localizations.dart';

import '../../../core/branding/brand_backdrop.dart';
import '../../../core/branding/brand_logo.dart';
import '../../../core/branding/brand_palette.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/routing/route_paths.dart';
import '../../../core/theme/role_theme.dart';
import '../../../core/widgets/feedback/cam_toast.dart';
import '../../../core/widgets/loaders/cameroon_election_loader.dart';
import '../../notifications/widgets/notification_app_bar.dart';
import '../providers/support_providers.dart';

class CamGuideScreen extends ConsumerStatefulWidget {
  const CamGuideScreen({super.key});

  @override
  ConsumerState<CamGuideScreen> createState() => _CamGuideScreenState();
}

class _CamGuideScreenState extends ConsumerState<CamGuideScreen> {
  final _inputCtrl = TextEditingController();
  final _inputFocusNode = FocusNode();
  final _scrollCtrl = ScrollController();
  final List<_CamGuideChatEntry> _entries = <_CamGuideChatEntry>[];
  String _lastIntentId = '';
  bool _initialized = false;
  bool _responding = false;
  bool _seedHandled = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) {
      _handleSeededQuestion();
      return;
    }
    _initialized = true;
    final locale = Localizations.localeOf(context);
    final role = ref.read(currentRoleProvider);
    final assistant = ref.read(camGuideAssistantProvider);
    final reply = assistant.reply(
      question: '',
      locale: locale,
      role: role,
      lastIntentId: _lastIntentId,
    );
    _entries.add(
      _CamGuideChatEntry.assistant(
        message: reply.answer,
        followUps: assistant.starterPrompts(locale, role),
        sourceHints: reply.sourceHints,
        confidence: reply.confidence,
      ),
    );
    _handleSeededQuestion();
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    _inputFocusNode.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final role = ref.watch(currentRoleProvider);
    final entry = _entryParam(context);
    final actions = _quickActionsForRole(t, role, entry);
    final cs = Theme.of(context).colorScheme;
    final viewport = MediaQuery.of(context).size;
    final isNarrow = viewport.width < 760;
    final chatHeight = isNarrow
        ? (viewport.height * 0.46).clamp(280.0, 460.0).toDouble()
        : (viewport.height * 0.52).clamp(320.0, 560.0).toDouble();

    return Scaffold(
      appBar: NotificationAppBar(
        title: Text(t.helpSupportAiTitle),
        showBell: false,
      ),
      body: BrandBackdrop(
        child: ResponsiveContent(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const SizedBox(height: 10),
              Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            BrandPalette.sunrise.withAlpha(235),
                            BrandPalette.ember.withAlpha(220),
                            BrandPalette.forest.withAlpha(225),
                          ],
                        ),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            tooltip: t.close,
                            onPressed: _closeCamGuide,
                            style: IconButton.styleFrom(
                              foregroundColor: Colors.white,
                              visualDensity: VisualDensity.compact,
                              padding: const EdgeInsets.all(6),
                            ),
                            icon: const Icon(
                              Icons.arrow_back_rounded,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 2),
                          const _CamGuideAvatar(size: 54),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  t.helpSupportAiTitle,
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w900,
                                      ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  t.helpSupportAiSubtitle,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: Colors.white.withAlpha(225),
                                      ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                tooltip: t.clearAll,
                                onPressed: _responding
                                    ? null
                                    : _resetConversation,
                                style: IconButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  visualDensity: VisualDensity.compact,
                                  padding: const EdgeInsets.all(6),
                                ),
                                icon: const Icon(
                                  Icons.refresh_rounded,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 4),
                              DecoratedBox(
                                decoration: BoxDecoration(
                                  color: Colors.white.withAlpha(36),
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                    color: Colors.white.withAlpha(90),
                                  ),
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  child: Icon(
                                    Icons.auto_awesome_rounded,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (actions.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final action in actions)
                              ActionChip(
                                avatar: Icon(action.icon, size: 18),
                                label: Text(action.label),
                                onPressed: () => context.go(action.route),
                              ),
                          ],
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        children: [
                          Container(
                            height: chatHeight,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  cs.surfaceContainerHighest.withAlpha(58),
                                  cs.surfaceContainer.withAlpha(28),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: cs.outlineVariant.withAlpha(95),
                              ),
                            ),
                            child: ListView.builder(
                              controller: _scrollCtrl,
                              itemCount:
                                  _entries.length + (_responding ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (_responding && index == _entries.length) {
                                  return Align(
                                    alignment: Alignment.centerLeft,
                                    child: Container(
                                      margin: const EdgeInsets.only(top: 8),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: cs.surfaceContainer,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: cs.outlineVariant.withAlpha(
                                            90,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const CamElectionLoader(
                                            size: 16,
                                            strokeWidth: 2.2,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(t.helpSupportAiThinking),
                                        ],
                                      ),
                                    ),
                                  );
                                }

                                final entry = _entries[index];
                                final align = entry.fromUser
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft;
                                final bg = entry.fromUser
                                    ? cs.primaryContainer.withAlpha(190)
                                    : cs.surfaceContainer;
                                final fg = entry.fromUser
                                    ? cs.onPrimaryContainer
                                    : cs.onSurfaceVariant;
                                return Align(
                                  alignment: align,
                                  child: Container(
                                    constraints: const BoxConstraints(
                                      maxWidth: 640,
                                    ),
                                    margin: const EdgeInsets.only(bottom: 8),
                                    padding: const EdgeInsets.fromLTRB(
                                      12,
                                      10,
                                      12,
                                      10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: bg,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: cs.outlineVariant.withAlpha(90),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (!entry.fromUser) ...[
                                          Row(
                                            children: [
                                              DecoratedBox(
                                                decoration: const BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Colors.white,
                                                ),
                                                child: const Padding(
                                                  padding: EdgeInsets.all(2),
                                                  child: CamVoteLogo(size: 18),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                'CamGuide',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .labelSmall
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.w800,
                                                    ),
                                              ),
                                              const Spacer(),
                                              if (entry.confidence > 0)
                                                DecoratedBox(
                                                  decoration: BoxDecoration(
                                                    color: cs.secondaryContainer
                                                        .withAlpha(130),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          999,
                                                        ),
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 8,
                                                          vertical: 3,
                                                        ),
                                                    child: Text(
                                                      '${(entry.confidence * 100).round()}%',
                                                      style: Theme.of(
                                                        context,
                                                      ).textTheme.labelSmall,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                        ],
                                        Text(
                                          entry.message,
                                          style: TextStyle(color: fg),
                                        ),
                                        if (!entry.fromUser &&
                                            entry.sourceHints.isNotEmpty) ...[
                                          const SizedBox(height: 8),
                                          Text(
                                            t.helpSupportAiSourcesLabel,
                                            style: Theme.of(
                                              context,
                                            ).textTheme.labelSmall,
                                          ),
                                          const SizedBox(height: 4),
                                          Wrap(
                                            spacing: 6,
                                            runSpacing: 6,
                                            children: [
                                              for (final source
                                                  in entry.sourceHints)
                                                Chip(
                                                  visualDensity:
                                                      VisualDensity.compact,
                                                  materialTapTargetSize:
                                                      MaterialTapTargetSize
                                                          .shrinkWrap,
                                                  label: Text(source),
                                                ),
                                            ],
                                          ),
                                        ],
                                        if (!entry.fromUser &&
                                            entry.followUps.isNotEmpty) ...[
                                          const SizedBox(height: 8),
                                          Text(
                                            t.helpSupportAiSuggestionsLabel,
                                            style: Theme.of(
                                              context,
                                            ).textTheme.labelSmall,
                                          ),
                                          const SizedBox(height: 4),
                                          Wrap(
                                            spacing: 6,
                                            runSpacing: 6,
                                            children: [
                                              for (final suggestion
                                                  in entry.followUps)
                                                ActionChip(
                                                  label: Text(suggestion),
                                                  onPressed: () =>
                                                      _askCamGuide(suggestion),
                                                ),
                                            ],
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _inputCtrl,
                                  focusNode: _inputFocusNode,
                                  textInputAction: TextInputAction.send,
                                  onSubmitted: (_) => _askCamGuide(),
                                  decoration: InputDecoration(
                                    hintText: t.helpSupportAiInputHint,
                                    prefixIcon: const Icon(
                                      Icons.chat_bubble_outline_rounded,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              FilledButton.icon(
                                onPressed: _responding
                                    ? null
                                    : () => _askCamGuide(),
                                icon: const Icon(Icons.send_rounded),
                                label: Text(t.helpSupportAiSend),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
            ],
          ),
        ),
      ),
    );
  }

  List<_CamGuideQuickAction> _quickActionsForRole(
    AppLocalizations t,
    AppRole role,
    String entry,
  ) {
    String withEntry(String path) {
      if (!path.contains('?')) return '$path?entry=$entry';
      return '$path&entry=$entry';
    }

    switch (role) {
      case AppRole.admin:
        return [
          _CamGuideQuickAction(
            label: t.adminDashboard,
            icon: Icons.admin_panel_settings_outlined,
            route: withEntry(RoutePaths.adminDashboard),
          ),
          _CamGuideQuickAction(
            label: t.adminActionElections,
            icon: Icons.how_to_vote_outlined,
            route: withEntry(RoutePaths.adminElections),
          ),
          _CamGuideQuickAction(
            label: t.adminActionVoters,
            icon: Icons.badge_outlined,
            route: withEntry(RoutePaths.adminVoters),
          ),
          _CamGuideQuickAction(
            label: t.adminObserverAccessTitle,
            icon: Icons.visibility_outlined,
            route: withEntry(RoutePaths.adminObservers),
          ),
          _CamGuideQuickAction(
            label: t.adminIncidentsTitle,
            icon: Icons.report_problem_outlined,
            route: withEntry(RoutePaths.adminIncidents),
          ),
          _CamGuideQuickAction(
            label: t.adminTipReviewTitle,
            icon: Icons.volunteer_activism_outlined,
            route: withEntry(RoutePaths.adminTips),
          ),
          _CamGuideQuickAction(
            label: t.adminSupportTitle,
            icon: Icons.support_agent_outlined,
            route: withEntry(RoutePaths.adminSupport),
          ),
          _CamGuideQuickAction(
            label: t.notificationsTitle,
            icon: Icons.notifications_outlined,
            route: withEntry(RoutePaths.notifications),
          ),
          _CamGuideQuickAction(
            label: t.settings,
            icon: Icons.settings_outlined,
            route: withEntry(RoutePaths.settings),
          ),
        ];
      case AppRole.observer:
        return [
          _CamGuideQuickAction(
            label: t.observerDashboard,
            icon: Icons.visibility_outlined,
            route: withEntry(RoutePaths.observerDashboard),
          ),
          _CamGuideQuickAction(
            label: t.observerReportIncidentTitle,
            icon: Icons.report_gmailerrorred_outlined,
            route: withEntry(RoutePaths.observerIncidentReport),
          ),
          _CamGuideQuickAction(
            label: t.observerIncidentTrackerTitle,
            icon: Icons.track_changes_outlined,
            route: withEntry(RoutePaths.observerIncidentTracker),
          ),
          _CamGuideQuickAction(
            label: t.observerChecklistTitle,
            icon: Icons.checklist_outlined,
            route: withEntry(RoutePaths.observerChecklist),
          ),
          _CamGuideQuickAction(
            label: t.observerTransparencyTitle,
            icon: Icons.visibility_outlined,
            route: withEntry(RoutePaths.observerTransparency),
          ),
          _CamGuideQuickAction(
            label: t.publicResultsTitle,
            icon: Icons.query_stats_outlined,
            route: withEntry(RoutePaths.publicResults),
          ),
          _CamGuideQuickAction(
            label: t.notificationsTitle,
            icon: Icons.notifications_outlined,
            route: withEntry(RoutePaths.notifications),
          ),
          _CamGuideQuickAction(
            label: t.helpSupportTitle,
            icon: Icons.help_outline,
            route: withEntry(RoutePaths.helpSupport),
          ),
          _CamGuideQuickAction(
            label: t.settings,
            icon: Icons.settings_outlined,
            route: withEntry(RoutePaths.settings),
          ),
        ];
      case AppRole.voter:
        return [
          _CamGuideQuickAction(
            label: t.registrationHubTitle,
            icon: Icons.how_to_reg_outlined,
            route: withEntry(RoutePaths.register),
          ),
          _CamGuideQuickAction(
            label: t.electoralCardTitle,
            icon: Icons.badge_outlined,
            route: withEntry(RoutePaths.voterCard),
          ),
          _CamGuideQuickAction(
            label: t.voteReceiptTitle,
            icon: Icons.receipt_long_outlined,
            route: withEntry(RoutePaths.voterReceipt),
          ),
          _CamGuideQuickAction(
            label: t.publicResultsTitle,
            icon: Icons.query_stats_outlined,
            route: withEntry(RoutePaths.publicResults),
          ),
          _CamGuideQuickAction(
            label: t.verifyRegistrationTitle,
            icon: Icons.verified_user_outlined,
            route: withEntry(RoutePaths.publicVerifyRegistration),
          ),
          _CamGuideQuickAction(
            label: t.votingCentersTitle,
            icon: Icons.location_on_outlined,
            route: withEntry(RoutePaths.publicVotingCenters),
          ),
          _CamGuideQuickAction(
            label: t.notificationsTitle,
            icon: Icons.notifications_outlined,
            route: withEntry(RoutePaths.notifications),
          ),
          _CamGuideQuickAction(
            label: t.helpSupportTitle,
            icon: Icons.help_outline,
            route: withEntry(RoutePaths.helpSupport),
          ),
          _CamGuideQuickAction(
            label: t.supportCamVoteTitle,
            icon: Icons.favorite_outline,
            route: withEntry(RoutePaths.supportTip),
          ),
        ];
      case AppRole.public:
        return [
          _CamGuideQuickAction(
            label: t.publicResultsTitle,
            icon: Icons.query_stats_outlined,
            route: withEntry(RoutePaths.publicResults),
          ),
          _CamGuideQuickAction(
            label: t.publicElectionsInfoTitle,
            icon: Icons.how_to_vote_outlined,
            route: withEntry(RoutePaths.publicElectionsInfo),
          ),
          _CamGuideQuickAction(
            label: t.verifyRegistrationTitle,
            icon: Icons.verified_user_outlined,
            route: withEntry(RoutePaths.publicVerifyRegistration),
          ),
          _CamGuideQuickAction(
            label: t.publicElectionCalendarTitle,
            icon: Icons.event_outlined,
            route: withEntry(RoutePaths.publicElectionCalendar),
          ),
          _CamGuideQuickAction(
            label: t.votingCentersTitle,
            icon: Icons.location_on_outlined,
            route: withEntry(RoutePaths.publicVotingCenters),
          ),
          _CamGuideQuickAction(
            label: t.publicCivicEducationTitle,
            icon: Icons.school_outlined,
            route: withEntry(RoutePaths.publicCivicEducation),
          ),
          _CamGuideQuickAction(
            label: t.legalHubTitle,
            icon: Icons.gavel_outlined,
            route: withEntry(RoutePaths.legalLibrary),
          ),
          _CamGuideQuickAction(
            label: t.helpSupportTitle,
            icon: Icons.help_outline,
            route: withEntry(RoutePaths.helpSupport),
          ),
          _CamGuideQuickAction(
            label: t.about,
            icon: Icons.info_outline,
            route: withEntry(RoutePaths.about),
          ),
        ];
    }
  }

  void _resetConversation() {
    setState(() {
      _entries.clear();
      _lastIntentId = '';
      _initialized = false;
      _seedHandled = false;
      _responding = false;
    });
    didChangeDependencies();
  }

  void _closeCamGuide() {
    if (!mounted) return;
    final nav = Navigator.of(context);
    if (nav.canPop()) {
      nav.pop();
      return;
    }
    final entry = _entryParam(context);
    context.go(
      entry == 'admin' ? RoutePaths.adminPortal : RoutePaths.webPortal,
    );
  }

  String _entryParam(BuildContext context) {
    try {
      final raw = GoRouterState.of(context).uri.queryParameters['entry'] ?? '';
      final trimmed = raw.trim().toLowerCase();
      if (trimmed == 'admin' || trimmed == 'general') return trimmed;
    } catch (_) {
      // Ignore.
    }
    return 'general';
  }

  void _handleSeededQuestion() {
    if (_seedHandled || !mounted) return;
    final query = GoRouterState.of(context).uri.queryParameters;
    final seeded = (query['q'] ?? '').trim();
    if (seeded.isEmpty) return;
    _seedHandled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await _askCamGuide(seeded);
    });
  }

  Future<void> _askCamGuide([String? seededQuestion]) async {
    final question = (seededQuestion ?? _inputCtrl.text).trim();
    if (question.isEmpty || _responding) return;

    setState(() {
      _entries.add(_CamGuideChatEntry.user(message: question));
      _responding = true;
      if (seededQuestion == null) {
        _inputCtrl.clear();
      }
    });
    _scrollToBottom();

    await Future<void>.delayed(const Duration(milliseconds: 180));
    if (!mounted) return;

    try {
      final locale = Localizations.localeOf(context);
      final role = ref.read(currentRoleProvider);
      final assistant = ref.read(camGuideAssistantProvider);
      final supportRepo = ref.read(supportRepositoryProvider);
      final reply = await supportRepo
          .askCamGuide(
            question: question,
            locale: locale,
            role: role,
            lastIntentId: _lastIntentId,
          )
          .catchError((_) {
            return assistant.reply(
              question: question,
              locale: locale,
              role: role,
              lastIntentId: _lastIntentId,
            );
          });
      if (!mounted) return;

      setState(() {
        if (reply.intentId.trim().isNotEmpty) {
          _lastIntentId = reply.intentId.trim();
        }
        _entries.add(
          _CamGuideChatEntry.assistant(
            message: reply.answer,
            followUps: reply.followUps,
            sourceHints: reply.sourceHints,
            confidence: reply.confidence,
          ),
        );
        _responding = false;
      });
      _scrollToBottom();
    } catch (_) {
      if (!mounted) return;
      setState(() => _responding = false);
      final t = AppLocalizations.of(context);
      CamToast.show(
        context,
        message: t.genericErrorLabel,
        type: CamToastType.error,
      );
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollCtrl.hasClients) return;
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
      );
    });
  }
}

class _CamGuideQuickAction {
  const _CamGuideQuickAction({
    required this.label,
    required this.icon,
    required this.route,
  });

  final String label;
  final IconData icon;
  final String route;
}

class _CamGuideAvatar extends StatefulWidget {
  const _CamGuideAvatar({required this.size});

  final double size;

  @override
  State<_CamGuideAvatar> createState() => _CamGuideAvatarState();
}

class _CamGuideAvatarState extends State<_CamGuideAvatar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final scale = 0.95 + (_controller.value * 0.1);
          final angle = _controller.value * math.pi * 2;
          final orbitRadius = widget.size * 0.36;
          final orbitOffset = Offset(
            math.cos(angle) * orbitRadius,
            math.sin(angle) * orbitRadius,
          );
          return Transform.scale(
            scale: scale,
            child: Stack(
              alignment: Alignment.center,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: BrandPalette.ember.withAlpha(95),
                        blurRadius: 20,
                        spreadRadius: 1,
                      ),
                    ],
                    gradient: BrandPalette.heroGradient,
                  ),
                  child: const SizedBox.expand(),
                ),
                Padding(
                  padding: const EdgeInsets.all(3),
                  child: DecoratedBox(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: CamVoteLogo(size: widget.size - 14),
                    ),
                  ),
                ),
                Transform.translate(
                  offset: orbitOffset,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: BrandPalette.forest,
                      boxShadow: [
                        BoxShadow(
                          color: BrandPalette.forest.withAlpha(120),
                          blurRadius: 12,
                          spreadRadius: 0.6,
                        ),
                      ],
                    ),
                    child: const SizedBox(
                      width: 10,
                      height: 10,
                      child: Icon(
                        Icons.auto_awesome,
                        size: 8,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CamGuideChatEntry {
  const _CamGuideChatEntry._({
    required this.fromUser,
    required this.message,
    required this.followUps,
    required this.sourceHints,
    this.confidence = 0,
  });

  factory _CamGuideChatEntry.user({required String message}) {
    return _CamGuideChatEntry._(
      fromUser: true,
      message: message,
      followUps: const <String>[],
      sourceHints: const <String>[],
      confidence: 0,
    );
  }

  factory _CamGuideChatEntry.assistant({
    required String message,
    required List<String> followUps,
    required List<String> sourceHints,
    required double confidence,
  }) {
    return _CamGuideChatEntry._(
      fromUser: false,
      message: message,
      followUps: followUps,
      sourceHints: sourceHints,
      confidence: confidence,
    );
  }

  final bool fromUser;
  final String message;
  final List<String> followUps;
  final List<String> sourceHints;
  final double confidence;
}
