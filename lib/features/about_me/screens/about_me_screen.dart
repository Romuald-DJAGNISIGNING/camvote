import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

import 'package:camvote/gen/l10n/app_localizations.dart';
import 'package:camvote/core/errors/error_message.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/branding/brand_backdrop.dart';
import '../../../core/branding/brand_header.dart';
import '../../../core/branding/brand_logo.dart';
import '../../../core/branding/brand_palette.dart';
import '../../../core/motion/cam_reveal.dart';
import '../../../core/widgets/loaders/cameroon_election_loader.dart';
import '../providers/about_me_providers.dart';
import '../models/about_profile.dart';
import '../models/trello_stats.dart';
import '../../notifications/widgets/notification_app_bar.dart';

const _aboutProfileVideoAsset = 'assets/videos/DJAGNI_SIGNING_ROMUALD.mp4';

class AboutMeScreen extends ConsumerWidget {
  const AboutMeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final trelloAsync = ref.watch(trelloStatsProvider);
    final aboutAsync = ref.watch(aboutProfileProvider);
    final fallback = _buildProfile(t);
    final resolvedProfile = aboutAsync.asData?.value ?? fallback;
    final profileLoadError = aboutAsync.hasError ? aboutAsync.error : null;

    return Scaffold(
      appBar: NotificationAppBar(title: Text(t.about)),
      body: BrandBackdrop(
        child: ResponsiveContent(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              CamStagger(
                children: [
                  const SizedBox(height: 6),
                  BrandHeader(
                    title: t.aboutBuilderTitle,
                    subtitle: t.aboutBuilderSubtitle,
                  ),
                  const SizedBox(height: 12),
                  if (aboutAsync.isLoading)
                    _LoadingInfoCard(
                      title: t.aboutProfileLoadingTitle,
                      body: t.aboutProfileLoadingBody,
                      icon: Icons.sync,
                    ),
                  if (profileLoadError != null)
                    _InfoCard(
                      title: t.aboutProfileUnavailableTitle,
                      body: t.aboutProfileUnavailableBody(
                        safeErrorMessage(context, profileLoadError),
                      ),
                      icon: Icons.warning_amber,
                    ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _HeroProfile(profile: resolvedProfile),
                      const SizedBox(height: 16),
                      _SectionTitle(title: t.aboutVisionMissionTitle),
                      const SizedBox(height: 8),
                      _InfoCard(
                        title: t.aboutVisionTitle,
                        body: resolvedProfile.vision,
                        icon: Icons.visibility_outlined,
                      ),
                      const SizedBox(height: 10),
                      _InfoCard(
                        title: t.aboutMissionTitle,
                        body: resolvedProfile.mission,
                        icon: Icons.flag_outlined,
                      ),
                      const SizedBox(height: 16),
                      _SectionTitle(title: t.aboutContactSocialTitle),
                      const SizedBox(height: 8),
                      _LinkTile(
                        label: t.aboutProfileEmailLabel,
                        value: resolvedProfile.email,
                      ),
                      _LinkTile(
                        label: t.aboutProfileLinkedInLabel,
                        value: resolvedProfile.linkedin,
                      ),
                      _LinkTile(
                        label: t.aboutProfileGitHubLabel,
                        value: resolvedProfile.github,
                      ),
                      _LinkTile(
                        label: t.aboutProfilePortfolioLabel,
                        value: resolvedProfile.portfolio,
                      ),
                      const SizedBox(height: 16),
                      _SectionTitle(title: t.aboutProductFocusTitle),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: resolvedProfile.focusTags
                            .map((t) => _Tag(t))
                            .toList(),
                      ),
                      const SizedBox(height: 16),
                      _SectionTitle(title: t.aboutSkillsHobbiesTitle),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: resolvedProfile.hobbies
                            .map((t) => _Tag(t))
                            .toList(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  _SectionTitle(title: t.aboutTrelloTitle),
                  const SizedBox(height: 8),
                  trelloAsync.when(
                    loading: () => _LoadingInfoCard(
                      title: t.aboutTrelloLoadingTitle,
                      body: t.aboutTrelloLoadingBody,
                      icon: Icons.sync,
                    ),
                    error: (_, _) => _InfoCard(
                      title: t.aboutTrelloUnavailableTitle,
                      body: t.genericErrorLabel,
                      icon: Icons.warning_amber,
                    ),
                    data: (stats) {
                      if (stats == null) {
                        return _InfoCard(
                          title: t.aboutTrelloNotConfiguredTitle,
                          body: t.aboutTrelloNotConfiguredBody,
                          icon: Icons.link_off,
                        );
                      }
                      return _TrelloStatsCard(stats: stats);
                    },
                  ),
                  const SizedBox(height: 16),
                  _InfoCard(
                    title: t.aboutWhyCamVoteTitle,
                    body: t.aboutWhyCamVoteBody,
                    icon: Icons.how_to_vote_outlined,
                  ),
                  const SizedBox(height: 18),
                  const SizedBox(height: 10),
                  _FooterNote(name: resolvedProfile.name),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

AboutProfile _buildProfile(AppLocalizations t) {
  return AboutProfile(
    name: t.aboutProfileName,
    title: t.aboutProfileTitle,
    tagline: t.aboutProfileTagline,
    vision: t.aboutProfileVision,
    mission: t.aboutProfileMission,
    email: t.aboutProfileEmailValue,
    linkedin: t.aboutProfileLinkedInValue,
    github: t.aboutProfileGitHubValue,
    portfolio: t.aboutProfilePortfolioValue,
    focusTags: [
      t.aboutTagSecureVoting,
      t.aboutTagBiometrics,
      t.aboutTagAuditTrails,
      t.aboutTagOfflineFirst,
      t.aboutTagAccessibility,
      t.aboutTagLocalization,
    ],
    hobbies: [
      t.aboutHobbyMusic,
      t.aboutHobbyReading,
      t.aboutHobbyWriting,
      t.aboutHobbySinging,
      t.aboutHobbyCooking,
      t.aboutHobbyCoding,
      t.aboutHobbySleeping,
    ],
  );
}

class _ProfileHeader extends StatelessWidget {
  final String name;
  final String title;

  const _ProfileHeader({required this.name, required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        const CamVoteLogo(size: 56),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: theme.textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(title, style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}

class _HeroProfile extends StatelessWidget {
  const _HeroProfile({required this.profile});

  final AboutProfile profile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: BrandPalette.heroGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: BrandPalette.softShadow,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 520;
          final videoSize = isNarrow ? 72.0 : 92.0;
          final content = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ProfileHeader(name: profile.name, title: profile.title),
              const SizedBox(height: 12),
              Text(
                profile.tagline,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withAlpha(220),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _ActionChip(
                    icon: Icons.email_outlined,
                    label: t.aboutCopyEmail,
                    value: profile.email,
                  ),
                  _ActionChip(
                    icon: Icons.link_outlined,
                    label: t.aboutCopyLinkedIn,
                    value: profile.linkedin,
                  ),
                  _ActionChip(
                    icon: Icons.code,
                    label: t.aboutCopyGitHub,
                    value: profile.github,
                  ),
                ],
              ),
            ],
          );

          if (isNarrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                content,
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: _AnimatedProfileVideo(
                    name: profile.name,
                    assetPath: _aboutProfileVideoAsset,
                    size: videoSize,
                  ),
                ),
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: content),
              const SizedBox(width: 16),
              _AnimatedProfileVideo(
                name: profile.name,
                assetPath: _aboutProfileVideoAsset,
                size: videoSize,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _FooterNote extends StatelessWidget {
  const _FooterNote({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final year = DateTime.now().year;
    return Text(
      t.aboutFooterBuiltBy(name, year),
      style: Theme.of(
        context,
      ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String body;
  final IconData? icon;

  const _InfoCard({required this.title, required this.body, this.icon});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 18),
                  const SizedBox(width: 8),
                ],
                Flexible(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(body),
          ],
        ),
      ),
    );
  }
}

class _LoadingInfoCard extends StatelessWidget {
  final String title;
  final String body;
  final IconData? icon;

  const _LoadingInfoCard({required this.title, required this.body, this.icon});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 360;
            final headerRow = Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 18),
                  const SizedBox(width: 8),
                ],
                Flexible(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
              ],
            );

            if (isNarrow) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  headerRow,
                  const SizedBox(height: 8),
                  const Align(
                    alignment: Alignment.centerRight,
                    child: CamElectionLoader(size: 18, strokeWidth: 2.4),
                  ),
                  const SizedBox(height: 6),
                  Text(body),
                ],
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: headerRow),
                    const CamElectionLoader(size: 18, strokeWidth: 2.4),
                  ],
                ),
                const SizedBox(height: 6),
                Text(body),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _LinkTile extends StatelessWidget {
  final String label;
  final String value;

  const _LinkTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(_iconFor(label)),
        title: Text(label),
        subtitle: Text(value),
        trailing: const Icon(Icons.copy_rounded, size: 18),
        onTap: () async {
          await _copy(context, label, value);
        },
      ),
    );
  }

  IconData _iconFor(String label) {
    final lower = label.toLowerCase();
    if (lower.contains('email')) return Icons.email_outlined;
    if (lower.contains('linkedin')) return Icons.work_outline;
    if (lower.contains('github')) return Icons.code;
    if (lower.contains('portfolio')) return Icons.web;
    return Icons.link;
  }
}

class _Tag extends StatelessWidget {
  final String label;
  const _Tag(this.label);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: cs.primary.withAlpha(20),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: cs.primary.withAlpha(80)),
      ),
      child: Text(label, style: Theme.of(context).textTheme.labelMedium),
    );
  }
}

class _TrelloStatsCard extends StatelessWidget {
  final TrelloStats stats;

  const _TrelloStatsCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.dashboard_outlined, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    stats.boardName,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                IconButton(
                  tooltip: t.aboutCopyBoardUrl,
                  onPressed: () =>
                      _copy(context, t.aboutBoardUrlLabel, stats.boardUrl),
                  icon: const Icon(Icons.link),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _StatsRow(stats: stats),
            if (stats.lastActivityAt != null) ...[
              const SizedBox(height: 8),
              Text(
                '${t.aboutLastActivityLabel}: ${_formatDate(stats.lastActivityAt!)}',
              ),
            ],
            const SizedBox(height: 12),
            Text(
              t.aboutTopListsLabel,
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 6),
            ...stats.lists.take(5).map((l) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Expanded(child: Text(l.name)),
                    Text('${l.openCards}/${l.totalCards}'),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.stats});

  final TrelloStats stats;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 420;
        if (isNarrow) {
          return Column(
            children: [
              _StatPill(
                label: t.aboutStatTotal,
                value: stats.totalCards.toString(),
                color: BrandPalette.ocean,
              ),
              const SizedBox(height: 8),
              _StatPill(
                label: t.aboutStatOpen,
                value: stats.openCards.toString(),
                color: BrandPalette.sunrise,
              ),
              const SizedBox(height: 8),
              _StatPill(
                label: t.aboutStatDone,
                value: stats.doneCards.toString(),
                color: BrandPalette.forest,
              ),
            ],
          );
        }
        return Row(
          children: [
            Expanded(
              child: _StatPill(
                label: t.aboutStatTotal,
                value: stats.totalCards.toString(),
                color: BrandPalette.ocean,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _StatPill(
                label: t.aboutStatOpen,
                value: stats.openCards.toString(),
                color: BrandPalette.sunrise,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _StatPill(
                label: t.aboutStatDone,
                value: stats.doneCards.toString(),
                color: BrandPalette.forest,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withAlpha(90)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: theme.textTheme.labelSmall),
        ],
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      onPressed: () => _copy(context, label, value),
    );
  }
}

class _AnimatedProfileVideo extends StatefulWidget {
  const _AnimatedProfileVideo({
    required this.name,
    required this.assetPath,
    this.size = 92,
  });

  final String name;
  final String assetPath;
  final double size;

  @override
  State<_AnimatedProfileVideo> createState() => _AnimatedProfileVideoState();
}

class _AnimatedProfileVideoState extends State<_AnimatedProfileVideo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _floatController;
  VideoPlayerController? _videoController;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat(reverse: true);

    _videoController = VideoPlayerController.asset(widget.assetPath);
    _videoController!
        .initialize()
        .then((_) async {
          await _videoController?.setLooping(true);
          await _videoController?.setVolume(0);
          if (!mounted) return;
          setState(() {});
          await _videoController?.play();
        })
        .catchError((_) {
          if (!mounted) return;
          setState(() => _failed = true);
        });
  }

  @override
  void dispose() {
    _floatController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading =
        !_failed &&
        (_videoController == null || !_videoController!.value.isInitialized);
    final media = _failed
        ? _fallback(context, loading: false)
        : isLoading
        ? _fallback(context, loading: true)
        : _videoFrame(context);

    return AnimatedBuilder(
      animation: _floatController,
      builder: (context, child) {
        final t = _floatController.value;
        final float = math.sin(t * math.pi * 2) * 5;
        final scale = 1 + (math.cos(t * math.pi * 2) * 0.015);
        return Transform.translate(
          offset: Offset(0, float),
          child: Transform.scale(scale: scale, child: child),
        );
      },
      child: media,
    );
  }

  Widget _videoFrame(BuildContext context) {
    final controller = _videoController;
    if (controller == null || !controller.value.isInitialized) {
      return _fallback(context, loading: true);
    }
    return _framed(
      context,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: controller.value.size.width,
            height: controller.value.size.height,
            child: VideoPlayer(controller),
          ),
        ),
      ),
    );
  }

  Widget _fallback(BuildContext context, {required bool loading}) {
    final theme = Theme.of(context);
    final initial = widget.name.isNotEmpty ? widget.name[0] : '?';
    return _framed(
      context,
      child: Center(
        child: loading
            ? const CamElectionLoader(size: 28, strokeWidth: 3)
            : Text(
                initial,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
      ),
    );
  }

  Widget _framed(BuildContext context, {required Widget child}) {
    final theme = Theme.of(context);
    final radius = widget.size * 0.22;
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(radius + 6),
        border: Border.all(
          color: theme.colorScheme.primary.withAlpha(120),
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withAlpha(35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius + 4),
        child: child,
      ),
    );
  }
}

Future<void> _copy(BuildContext context, String label, String value) async {
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
