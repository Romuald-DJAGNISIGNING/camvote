import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:camvote/gen/l10n/app_localizations.dart';

import '../../../core/routing/route_paths.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/branding/brand_backdrop.dart';
import '../../../core/branding/brand_header.dart';
import '../../centers/models/voting_center.dart';
import '../../centers/screens/voting_centers_map_screen.dart';
import '../domain/registration_identity.dart';
import '../providers/registration_providers.dart';
import '../../notifications/widgets/notification_app_bar.dart';

class VoterRegistrationDraftScreen extends ConsumerStatefulWidget {
  const VoterRegistrationDraftScreen({super.key});

  @override
  ConsumerState<VoterRegistrationDraftScreen> createState() =>
      _VoterRegistrationDraftScreenState();
}

class _VoterRegistrationDraftScreenState
    extends ConsumerState<VoterRegistrationDraftScreen> {
  final _nameCtrl = TextEditingController();
  final _placeCtrl = TextEditingController();
  final _nationalityCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Load saved draft once
    Future.microtask(() async {
      await ref.read(voterRegistrationDraftProvider.notifier).loadDraft();
      final draft = ref.read(voterRegistrationDraftProvider);
      _nameCtrl.text = draft.fullName;
      _placeCtrl.text = draft.placeOfBirth;
      _nationalityCtrl.text = draft.nationality;
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _placeCtrl.dispose();
    _nationalityCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final draft = ref.watch(voterRegistrationDraftProvider);
    final canContinue = draft.isValidBasicInfo;
    final dateLabel = _formatDob(context, draft.dateOfBirth);
    final center = draft.preferredCenter;

    return Scaffold(
      appBar: NotificationAppBar(
        title: Text(t.registrationDraftTitle),
        actions: [
          IconButton(
            tooltip: t.clearDraft,
            onPressed: () async =>
                ref.read(voterRegistrationDraftProvider.notifier).clearDraft(),
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: BrandBackdrop(
        child: ResponsiveContent(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const SizedBox(height: 6),
              BrandHeader(
                title: t.registrationDraftHeaderTitle,
                subtitle: t.registrationDraftHeaderSubtitle,
              ),
              const SizedBox(height: 12),
              Card(
                child: ListTile(
                  leading: Icon(draft.saved ? Icons.check_circle : Icons.edit),
                  title: Text(draft.saved ? t.draftSaved : t.draftNotSaved),
                  subtitle: Text(t.draftSavedSubtitle),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _nameCtrl,
                decoration: InputDecoration(
                  labelText: t.fullName,
                  border: const OutlineInputBorder(),
                ),
                onChanged: (v) => ref
                    .read(voterRegistrationDraftProvider.notifier)
                    .updateFullName(v),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _placeCtrl,
                decoration: InputDecoration(
                  labelText: t.placeOfBirth,
                  border: const OutlineInputBorder(),
                ),
                onChanged: (v) => ref
                    .read(voterRegistrationDraftProvider.notifier)
                    .updatePlaceOfBirth(v),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _nationalityCtrl,
                decoration: InputDecoration(
                  labelText: t.nationality,
                  border: const OutlineInputBorder(),
                ),
                onChanged: (v) => ref
                    .read(voterRegistrationDraftProvider.notifier)
                    .updateNationality(v),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: draft.regionCode,
                decoration: InputDecoration(
                  labelText: t.regionLabel,
                  border: const OutlineInputBorder(),
                ),
                items: _regionItems(t),
                onChanged: (v) {
                  if (v == null) return;
                  ref
                      .read(voterRegistrationDraftProvider.notifier)
                      .updateRegionCode(v);
                },
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () async {
                  final now = DateTime.now();
                  final initial = draft.dateOfBirth ??
                      DateTime(now.year - 20, now.month, now.day);

                  final picked = await showDatePicker(
                    context: context,
                    initialDate: initial,
                    firstDate: DateTime(1900),
                    lastDate: now,
                  );
                  if (picked == null) return;

                  ref
                      .read(voterRegistrationDraftProvider.notifier)
                      .updateDob(picked);
                },
                icon: const Icon(Icons.cake_outlined),
                label: Text(
                  dateLabel.isEmpty
                      ? t.pickDateOfBirth
                      : t.dateOfBirthWithValue(dateLabel),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.location_on_outlined),
                  title: Text(
                    center == null
                        ? t.votingCenterNotSelectedTitle
                        : t.votingCenterSelectedTitle,
                  ),
                  subtitle: Text(
                    center == null
                        ? t.votingCenterNotSelectedSubtitle
                        : '${center.name} • ${center.address}',
                  ),
                  trailing: IconButton(
                    tooltip: t.votingCenterSelectAction,
                    onPressed: () async {
                      final selected = await context.push<VotingCenter?>(
                        RoutePaths.publicVotingCenters,
                        extra: VotingCentersMapArgs(
                          selectMode: true,
                          selectedCenter: center,
                        ),
                      );
                      if (!context.mounted) return;
                      if (selected != null) {
                        ref
                            .read(voterRegistrationDraftProvider.notifier)
                            .updatePreferredCenter(selected);
                      }
                    },
                    icon: const Icon(Icons.map_outlined),
                  ),
                ),
              ),
              if (center != null) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () => ref
                        .read(voterRegistrationDraftProvider.notifier)
                        .clearPreferredCenter(),
                    icon: const Icon(Icons.close_rounded),
                    label: Text(t.clearSelection),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: draft.isValidBasicInfo
                          ? () async => ref
                                .read(voterRegistrationDraftProvider.notifier)
                                .saveDraft()
                          : null,
                      child: Text(t.saveDraft),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.tonal(
                      onPressed: canContinue
                          ? () {
                              final dob = draft.dateOfBirth;
                              if (dob == null) return;

                              context.push(
                                RoutePaths.voterDocumentOcr,
                                extra: RegistrationIdentity(
                                  fullName: draft.fullName.trim(),
                                  dateOfBirth: dob,
                                  placeOfBirth: draft.placeOfBirth.trim(),
                                  nationality: draft.nationality.trim(),
                                ),
                              );
                            }
                          : null,
                      child: Text(t.continueNext),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDob(BuildContext context, DateTime? dob) {
    if (dob == null) return '';
    return MaterialLocalizations.of(context).formatMediumDate(dob);
  }

  List<DropdownMenuItem<String>> _regionItems(AppLocalizations t) {
    return [
      DropdownMenuItem(value: 'AD', child: Text(t.regionAdamawa)),
      DropdownMenuItem(value: 'CE', child: Text(t.regionCentre)),
      DropdownMenuItem(value: 'ES', child: Text(t.regionEast)),
      DropdownMenuItem(value: 'EN', child: Text(t.regionFarNorth)),
      DropdownMenuItem(value: 'LT', child: Text(t.regionLittoral)),
      DropdownMenuItem(value: 'NO', child: Text(t.regionNorth)),
      DropdownMenuItem(value: 'NW', child: Text(t.regionNorthWest)),
      DropdownMenuItem(value: 'SU', child: Text(t.regionSouth)),
      DropdownMenuItem(value: 'SW', child: Text(t.regionSouthWest)),
      DropdownMenuItem(value: 'OU', child: Text(t.regionWest)),
    ];
  }
}
