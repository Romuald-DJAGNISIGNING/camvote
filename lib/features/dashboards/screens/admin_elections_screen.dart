import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camvote/gen/l10n/app_localizations.dart';

import '../models/admin_models.dart';
import '../providers/admin_providers.dart';
import '../../notifications/widgets/notification_app_bar.dart';
import '../../../core/widgets/loaders/cameroon_election_loader.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/branding/brand_backdrop.dart';
import '../../../core/branding/brand_header.dart';

class AdminElectionsScreen extends ConsumerWidget {
  const AdminElectionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final elections = ref.watch(electionsProvider);
    final t = AppLocalizations.of(context);

    return Scaffold(
      appBar: NotificationAppBar(title: Text(t.adminElectionManagementTitle)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openCreateElection(context, ref),
        icon: const Icon(Icons.add),
        label: Text(t.adminCreateElection),
      ),
      body: elections.when(
        data: (items) {
          return BrandBackdrop(
            child: ResponsiveContent(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  const SizedBox(height: 6),
                  BrandHeader(
                    title: t.adminElectionManagementTitle,
                    subtitle: t.adminElectionManagementSubtitle,
                  ),
                  const SizedBox(height: 16),
                  if (items.isEmpty)
                    Text(t.noElectionsYet)
                  else
                    ...items.map((e) {
                      final typeLabel = _electionTypeLabel(t, e.type);
                      final scopeLabel = _scopeLabel(t, e.scope);
                      final ballotLabel = _ballotLabel(t, e.ballotType);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  e.title,
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                if (e.description.isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  Text(e.description),
                                ],
                                const SizedBox(height: 8),
                                _Row(
                                  label: t.opensLabel,
                                  value: _formatDateTime(context, e.startAt),
                                ),
                                _Row(
                                  label: t.closesLabel,
                                  value: _formatDateTime(context, e.endAt),
                                ),
                                if (e.registrationDeadline != null)
                                  _Row(
                                    label: t.registrationDeadlineTitle,
                                    value: _formatDateTime(
                                      context,
                                      e.registrationDeadline!,
                                    ),
                                  ),
                                if (scopeLabel.isNotEmpty || e.location.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: Wrap(
                                      spacing: 8,
                                      runSpacing: 6,
                                      children: [
                                        if (scopeLabel.isNotEmpty)
                                          _chip(context, scopeLabel),
                                        if (e.location.isNotEmpty)
                                          _chip(context, e.location),
                                      ],
                                    ),
                                  ),
                                const SizedBox(height: 6),
                                Wrap(
                                  spacing: 10,
                                  runSpacing: 6,
                                  children: [
                                    _chip(context, typeLabel),
                                    _chip(context, e.isClosed ? t.electionStatusClosed : t.electionStatusLive),
                                    if (ballotLabel.isNotEmpty)
                                      _chip(context, ballotLabel),
                                    _chip(
                                      context,
                                      t.candidatesCountLabel(e.candidates.length),
                                    ),
                                    _chip(context, t.votesCountLabel(e.totalVotes)),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: FilledButton.tonalIcon(
                                    onPressed: () =>
                                        _openAddCandidate(context, ref, e.id),
                                    icon: const Icon(Icons.person_add_alt_1),
                                    label: Text(t.addCandidate),
                                  ),
                                ),
                                if (e.candidates.isNotEmpty) ...[
                                  const SizedBox(height: 10),
                                  const Divider(),
                                  const SizedBox(height: 8),
                                  Text(
                                    t.candidatesLabel,
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 8),
                                  ...e.candidates.map(
                                    (c) => ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      leading: CircleAvatar(
                                        backgroundColor: Color(c.partyColor),
                                        child: Text(
                                          c.partyAcronym,
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      title: Text(c.fullName),
                                      subtitle: Text(
                                        '${c.partyName} (${c.partyAcronym})'
                                        '${c.runningMate.isEmpty ? '' : '\n${t.candidateRunningMateLabel}: ${c.runningMate}'}',
                                      ),
                                      trailing: c.slogan.isEmpty
                                          ? null
                                          : Text(
                                              c.slogan,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .labelMedium
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                            ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                ],
              ),
            ),
          );
        },
        error: (e, _) => Center(child: Text(t.errorWithDetails(e.toString()))),
        loading: () => const Center(child: CamElectionLoader()),
      ),
    );
  }

  Widget _chip(BuildContext context, String text) {
    return Chip(
      label: Text(text),
      shape: const StadiumBorder(),
    );
  }

  Future<void> _openCreateElection(BuildContext context, WidgetRef ref) async {
    final titleCtrl = TextEditingController();
    final descriptionCtrl = TextEditingController();
    final locationCtrl = TextEditingController();
    final eligibilityCtrl = TextEditingController();
    final timezoneCtrl = TextEditingController(text: _defaultTimezoneLabel());
    ElectionType type = ElectionType.presidential;
    String scope = '';
    String ballotType = '';

    DateTime startAt = DateTime.now().add(const Duration(hours: 1));
    DateTime endAt = DateTime.now().add(const Duration(hours: 8));
    DateTime? registrationDeadline;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) {
        final local = AppLocalizations.of(ctx);
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 12,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: StatefulBuilder(
            builder: (ctx, setState) {
              final startDateLabel = _formatDate(ctx, startAt);
              final endDateLabel = _formatDate(ctx, endAt);
              final startTimeLabel = _formatTime(ctx, startAt);
              final endTimeLabel = _formatTime(ctx, endAt);
              final deadlineLabel = registrationDeadline == null
                  ? ''
                  : _formatDateTime(ctx, registrationDeadline!);

              final scopeOptions = [
                _Option('national', local.electionScopeNational),
                _Option('regional', local.electionScopeRegional),
                _Option('municipal', local.electionScopeMunicipal),
                _Option('diaspora', local.electionScopeDiaspora),
                _Option('local', local.electionScopeLocal),
              ];

              final ballotOptions = [
                _Option('single_choice', local.electionBallotTypeSingle),
                _Option('ranked_choice', local.electionBallotTypeRanked),
                _Option('approval', local.electionBallotTypeApproval),
                _Option('runoff', local.electionBallotTypeRunoff),
              ];
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(local.adminCreateElection, style: Theme.of(ctx).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    TextField(
                      controller: titleCtrl,
                      decoration: InputDecoration(
                        labelText: local.electionTitleLabel,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descriptionCtrl,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: local.electionDescriptionLabel,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<ElectionType>(
                      initialValue: type,
                      decoration: InputDecoration(
                        labelText: local.electionTypeLabel,
                        border: const OutlineInputBorder(),
                      ),
                      items: ElectionType.values
                          .map((t) => DropdownMenuItem(
                                value: t,
                                child: Text(_electionTypeLabel(local, t)),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => type = v ?? type),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: scope.isEmpty ? null : scope,
                      decoration: InputDecoration(
                        labelText: local.electionScopeFieldLabel,
                        border: const OutlineInputBorder(),
                      ),
                    items: scopeOptions
                        .map(
                          (option) => DropdownMenuItem(
                            value: option.value,
                            child: Text(option.label),
                          ),
                        )
                        .toList(),
                      onChanged: (v) => setState(() => scope = v ?? ''),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: locationCtrl,
                      decoration: InputDecoration(
                        labelText: local.electionLocationLabel,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: ctx,
                                firstDate: DateTime.now().subtract(const Duration(days: 1)),
                                lastDate: DateTime.now().add(const Duration(days: 3650)),
                                initialDate: startAt,
                              );
                              if (picked == null) return;
                              setState(() {
                                startAt = DateTime(
                                  picked.year,
                                  picked.month,
                                  picked.day,
                                  startAt.hour,
                                  startAt.minute,
                                );
                                if (endAt.isBefore(startAt)) endAt = startAt.add(const Duration(hours: 2));
                              });
                            },
                            icon: const Icon(Icons.schedule),
                            label: Text(local.electionStartLabel(startDateLabel)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final picked = await showTimePicker(
                                context: ctx,
                                initialTime: TimeOfDay.fromDateTime(startAt),
                              );
                              if (picked == null) return;
                              setState(() {
                                startAt = DateTime(
                                  startAt.year,
                                  startAt.month,
                                  startAt.day,
                                  picked.hour,
                                  picked.minute,
                                );
                                if (endAt.isBefore(startAt)) {
                                  endAt = startAt.add(const Duration(hours: 2));
                                }
                              });
                            },
                            icon: const Icon(Icons.access_time),
                            label: Text(local.electionStartTimeLabel(startTimeLabel)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: ctx,
                                firstDate: DateTime.now().subtract(const Duration(days: 1)),
                                lastDate: DateTime.now().add(const Duration(days: 3650)),
                                initialDate: endAt,
                              );
                              if (picked == null) return;
                              setState(() {
                                endAt = DateTime(
                                  picked.year,
                                  picked.month,
                                  picked.day,
                                  endAt.hour,
                                  endAt.minute,
                                );
                                if (endAt.isBefore(startAt)) {
                                  endAt = startAt.add(const Duration(hours: 2));
                                }
                              });
                            },
                            icon: const Icon(Icons.event_busy),
                            label: Text(local.electionEndLabel(endDateLabel)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final picked = await showTimePicker(
                                context: ctx,
                                initialTime: TimeOfDay.fromDateTime(endAt),
                              );
                              if (picked == null) return;
                              setState(() {
                                endAt = DateTime(
                                  endAt.year,
                                  endAt.month,
                                  endAt.day,
                                  picked.hour,
                                  picked.minute,
                                );
                                if (endAt.isBefore(startAt)) {
                                  endAt = startAt.add(const Duration(hours: 2));
                                }
                              });
                            },
                            icon: const Icon(Icons.access_time_filled),
                            label: Text(local.electionEndTimeLabel(endTimeLabel)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: ctx,
                                firstDate: DateTime.now().subtract(const Duration(days: 1)),
                                lastDate: DateTime.now().add(const Duration(days: 3650)),
                                initialDate: registrationDeadline ?? startAt,
                              );
                              if (picked == null) return;
                              final time = registrationDeadline == null
                                  ? TimeOfDay.fromDateTime(startAt)
                                  : TimeOfDay.fromDateTime(registrationDeadline!);
                              setState(() {
                                registrationDeadline = DateTime(
                                  picked.year,
                                  picked.month,
                                  picked.day,
                                  time.hour,
                                  time.minute,
                                );
                              });
                            },
                            icon: const Icon(Icons.event_available),
                            label: Text(
                              registrationDeadline == null
                                  ? local.addRegistrationDeadline
                                  : local.registrationDeadlineLabel(deadlineLabel),
                            ),
                          ),
                        ),
                        if (registrationDeadline != null) ...[
                          const SizedBox(width: 12),
                          IconButton(
                            tooltip: local.clearDeadline,
                            onPressed: () => setState(() => registrationDeadline = null),
                            icon: const Icon(Icons.close_rounded),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: ballotType.isEmpty ? null : ballotType,
                      decoration: InputDecoration(
                        labelText: local.electionBallotTypeLabel,
                        border: const OutlineInputBorder(),
                      ),
                    items: ballotOptions
                        .map(
                          (option) => DropdownMenuItem(
                            value: option.value,
                            child: Text(option.label),
                          ),
                        )
                        .toList(),
                      onChanged: (v) => setState(() => ballotType = v ?? ''),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: eligibilityCtrl,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: local.electionEligibilityLabel,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: timezoneCtrl,
                      decoration: InputDecoration(
                        labelText: local.electionTimezoneLabel,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () async {
                          final title = titleCtrl.text.trim();
                          if (title.isEmpty) return;

                          Navigator.pop(ctx);
                          await ref.read(electionsProvider.notifier).createElection(
                                title: title,
                                type: type,
                                startAt: startAt,
                                endAt: endAt,
                                registrationDeadline: registrationDeadline,
                                description: descriptionCtrl.text.trim(),
                                scope: scope,
                                location: locationCtrl.text.trim(),
                                timezone: timezoneCtrl.text.trim(),
                                ballotType: ballotType,
                                eligibility: eligibilityCtrl.text.trim(),
                              );
                        },
                        child: Text(local.createAction),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );

    titleCtrl.dispose();
    descriptionCtrl.dispose();
    locationCtrl.dispose();
    eligibilityCtrl.dispose();
    timezoneCtrl.dispose();
  }

  Future<void> _openAddCandidate(BuildContext context, WidgetRef ref, String electionId) async {
    final nameCtrl = TextEditingController();
    final partyCtrl = TextEditingController();
    final acrCtrl = TextEditingController();
    final sloganCtrl = TextEditingController();
    final bioCtrl = TextEditingController();
    final campaignCtrl = TextEditingController();
    final avatarCtrl = TextEditingController();
    final runningMateCtrl = TextEditingController();
    final palette = _candidatePalette();
    int selectedColor = palette.first.toARGB32();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) {
        final local = AppLocalizations.of(ctx);
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 12,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: StatefulBuilder(
            builder: (ctx, setModalState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(local.addCandidate, style: Theme.of(ctx).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    TextField(
                      controller: nameCtrl,
                      decoration: InputDecoration(
                        labelText: local.fullName,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: partyCtrl,
                      decoration: InputDecoration(
                        labelText: local.partyNameLabel,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: acrCtrl,
                      decoration: InputDecoration(
                        labelText: local.partyAcronymLabel,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: sloganCtrl,
                      decoration: InputDecoration(
                        labelText: local.candidateSloganLabel,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: runningMateCtrl,
                      decoration: InputDecoration(
                        labelText: local.candidateRunningMateLabel,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: campaignCtrl,
                      decoration: InputDecoration(
                        labelText: local.candidateWebsiteLabel,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: avatarCtrl,
                      decoration: InputDecoration(
                        labelText: local.candidateAvatarUrlLabel,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: bioCtrl,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: local.candidateBioLabel,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        local.candidateColorLabel,
                        style: Theme.of(ctx).textTheme.labelLarge,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      children: palette.map((color) {
                        final selected = color.toARGB32() == selectedColor;
                        return InkWell(
                          onTap: () => setModalState(
                            () => selectedColor = color.toARGB32(),
                          ),
                          borderRadius: BorderRadius.circular(999),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: selected
                                    ? Theme.of(ctx).colorScheme.onSurface
                                    : Colors.transparent,
                                width: selected ? 2.5 : 1,
                              ),
                            ),
                            child: selected
                                ? const Icon(Icons.check, color: Colors.white)
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () async {
                          final full = nameCtrl.text.trim();
                          final party = partyCtrl.text.trim();
                          final acr = acrCtrl.text.trim();
                          if (full.isEmpty || party.isEmpty || acr.isEmpty) return;

                          final cand = Candidate(
                            id: 'cand_${DateTime.now().millisecondsSinceEpoch}',
                            fullName: full,
                            partyName: party,
                            partyAcronym: acr.toUpperCase(),
                            partyColor: selectedColor,
                            slogan: sloganCtrl.text.trim(),
                            bio: bioCtrl.text.trim(),
                            campaignUrl: campaignCtrl.text.trim(),
                            avatarUrl: avatarCtrl.text.trim(),
                            runningMate: runningMateCtrl.text.trim(),
                          );

                          Navigator.pop(ctx);
                          await ref.read(electionsProvider.notifier).addCandidate(
                                electionId: electionId,
                                candidate: cand,
                              );
                        },
                        child: Text(local.addAction),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );

    nameCtrl.dispose();
    partyCtrl.dispose();
    acrCtrl.dispose();
    sloganCtrl.dispose();
    bioCtrl.dispose();
    campaignCtrl.dispose();
    avatarCtrl.dispose();
    runningMateCtrl.dispose();
  }

  String _electionTypeLabel(AppLocalizations t, ElectionType type) {
    return switch (type) {
      ElectionType.presidential => t.electionTypePresidential,
      ElectionType.parliamentary => t.electionTypeParliamentary,
      ElectionType.municipal => t.electionTypeMunicipal,
      ElectionType.regional => t.electionTypeRegional,
      ElectionType.senatorial => t.electionTypeSenatorial,
      ElectionType.referendum => t.electionTypeReferendum,
    };
  }

  String _formatDate(BuildContext context, DateTime date) {
    return MaterialLocalizations.of(context).formatMediumDate(date);
  }

  String _formatTime(BuildContext context, DateTime date) {
    return MaterialLocalizations.of(context)
        .formatTimeOfDay(TimeOfDay.fromDateTime(date));
  }

  String _formatDateTime(BuildContext context, DateTime date) {
    final d = _formatDate(context, date);
    final t = _formatTime(context, date);
    return '$d • $t';
  }

  List<Color> _candidatePalette() {
    return const [
      Color(0xFF0A7D2E),
      Color(0xFFC62828),
      Color(0xFFF9A825),
      Color(0xFF1565C0),
      Color(0xFF6A1B9A),
      Color(0xFF00897B),
      Color(0xFFAD1457),
      Color(0xFF5E35B1),
    ];
  }

  String _defaultTimezoneLabel() {
    final now = DateTime.now();
    final offset = now.timeZoneOffset;
    final sign = offset.isNegative ? '-' : '+';
    final hours = offset.inHours.abs().toString().padLeft(2, '0');
    final minutes = (offset.inMinutes.abs() % 60).toString().padLeft(2, '0');
    final suffix = '$sign$hours:$minutes';
    final name = now.timeZoneName;
    return name.isEmpty ? 'UTC$suffix' : '$name (UTC$suffix)';
  }

  String _scopeLabel(AppLocalizations t, String value) {
    return switch (value.trim().toLowerCase()) {
      'national' => t.electionScopeNational,
      'regional' => t.electionScopeRegional,
      'municipal' => t.electionScopeMunicipal,
      'diaspora' => t.electionScopeDiaspora,
      'local' => t.electionScopeLocal,
      _ => value.trim(),
    };
  }

  String _ballotLabel(AppLocalizations t, String value) {
    return switch (value.trim().toLowerCase()) {
      'single_choice' => t.electionBallotTypeSingle,
      'ranked_choice' => t.electionBallotTypeRanked,
      'approval' => t.electionBallotTypeApproval,
      'runoff' => t.electionBallotTypeRunoff,
      _ => value.trim(),
    };
  }
}

class _Option {
  final String value;
  final String label;

  const _Option(this.value, this.label);
}

class _Row extends StatelessWidget {
  final String label;
  final String value;

  const _Row({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          Text(value),
        ],
      ),
    );
  }
}
