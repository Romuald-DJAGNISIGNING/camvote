import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:camvote/gen/l10n/app_localizations.dart';
import '../models/public_models.dart';
import '../providers/public_portal_providers.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/widgets/feedback/cam_toast.dart';
import '../../../core/widgets/loaders/cameroon_election_loader.dart';
import '../../../core/motion/cam_reveal.dart';
import '../../notifications/widgets/notification_app_bar.dart';
import '../../../core/branding/brand_backdrop.dart';
import '../../../core/branding/brand_header.dart';

class PublicVerifyRegistrationScreen extends ConsumerStatefulWidget {
  const PublicVerifyRegistrationScreen({super.key});

  @override
  ConsumerState<PublicVerifyRegistrationScreen> createState() => _PublicVerifyRegistrationScreenState();
}

class _PublicVerifyRegistrationScreenState extends ConsumerState<PublicVerifyRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _regCtrl = TextEditingController();
  DateTime? _dob;
  PublicVoterLookupResult? _result;
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _regCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final limiter = ref.watch(lookupLimiterProvider);

    return Scaffold(
      appBar: NotificationAppBar(title: Text(t.verifyRegistrationTitle)),
      body: BrandBackdrop(
        child: ResponsiveContent(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              CamStagger(
                children: [
                  const SizedBox(height: 6),
                  BrandHeader(
                    title: t.verifyRegistrationTitle,
                    subtitle: t.verifyRegistrationSub,
                  ),
                  const SizedBox(height: 12),
                  _AlertCard(
                    tone: _AlertTone.info,
                    body: t.verifyPrivacyNote,
                  ),
                  const SizedBox(height: 12),
                  if (limiter.blocked)
                    _AlertCard(
                      tone: _AlertTone.error,
                      body:
                          '${t.verifyAttemptLimitBody} ${t.cooldown}: ${limiter.cooldown.inMinutes} min',
                    ),
                  if (limiter.blocked) const SizedBox(height: 12),
                  if (_error != null && _error!.isNotEmpty)
                    _AlertCard(
                      tone: _AlertTone.error,
                      body: '${t.error}: $_error',
                    ),
                  if (_error != null && _error!.isNotEmpty)
                    const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _regCtrl,
                              decoration: InputDecoration(
                                labelText: t.verifyFormRegNumber,
                                prefixIcon: const Icon(Icons.badge_outlined),
                              ),
                              validator: (v) {
                                final val = (v ?? '').trim();
                                if (val.isEmpty) return t.requiredField;
                                if (val.length < 4) return t.invalidRegNumber;
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            _DobPicker(
                              value: _dob,
                              onChanged: (d) => setState(() => _dob = d),
                            ),
                            const SizedBox(height: 14),
                            FilledButton.icon(
                              onPressed: limiter.blocked || _submitting
                                  ? null
                                  : () => _submit(context),
                              icon: _submitting
                                  ? const CamElectionLoader(
                                      size: 18,
                                      strokeWidth: 2,
                                    )
                                  : const Icon(Icons.search),
                              label:
                                  Text(_submitting ? t.loading : t.verifySubmit),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_result != null)
                    CamReveal(child: _ResultCard(result: _result!)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit(BuildContext context) async {
    final t = AppLocalizations.of(context);

    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;

    if (_dob == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.selectDob)));
      return;
    }

    ref.read(lookupLimiterProvider.notifier).recordAttempt();

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      final repo = ref.read(publicPortalRepositoryProvider);
      final res = await repo.lookupVoter(
        regNumber: _regCtrl.text.trim(),
        dob: _dob!,
      );
      if (!context.mounted) return;
      if (!mounted) return;
      setState(() => _result = res);
      if (res.status == PublicVoterLookupStatus.eligible) {
        CamToast.celebrate(
          context,
          title: t.verifyStatusEligible,
          message: t.verifyEligibleToastMessage,
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }
}

class _DobPicker extends StatelessWidget {
  final DateTime? value;
  final ValueChanged<DateTime> onChanged;

  const _DobPicker({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () async {
        final now = DateTime.now();
        final picked = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime(now.year - 20, 1, 1),
          firstDate: DateTime(1900, 1, 1),
          lastDate: now,
        );
        if (picked != null) onChanged(picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: t.verifyFormDob,
          prefixIcon: const Icon(Icons.cake_outlined),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: Text(
          value == null
              ? t.tapToSelect
              : '${value!.year.toString().padLeft(4, '0')}-${value!.month.toString().padLeft(2, '0')}-${value!.day.toString().padLeft(2, '0')}',
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final PublicVoterLookupResult result;

  const _ResultCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final expiryLabel = result.cardExpiry == null
        ? null
        : MaterialLocalizations.of(context).formatMediumDate(
            result.cardExpiry!,
          );

    String statusLabel(PublicVoterLookupStatus s) => switch (s) {
          PublicVoterLookupStatus.notFound => t.verifyStatusNotFound,
          PublicVoterLookupStatus.pendingVerification => t.verifyStatusPending,
          PublicVoterLookupStatus.registeredPreEligible => t.verifyStatusRegisteredPreEligible,
          PublicVoterLookupStatus.eligible => t.verifyStatusEligible,
          PublicVoterLookupStatus.voted => t.verifyStatusVoted,
          PublicVoterLookupStatus.suspended => t.verifyStatusSuspended,
          PublicVoterLookupStatus.deceased => t.verifyStatusDeceased,
          PublicVoterLookupStatus.archived => t.verifyStatusArchived,
        };

    final cs = Theme.of(context).colorScheme;

    final icon = switch (result.status) {
      PublicVoterLookupStatus.eligible || PublicVoterLookupStatus.registeredPreEligible => Icons.verified_outlined,
      PublicVoterLookupStatus.voted => Icons.check_circle_outline,
      PublicVoterLookupStatus.pendingVerification => Icons.hourglass_empty,
      PublicVoterLookupStatus.notFound => Icons.search_off,
      PublicVoterLookupStatus.suspended => Icons.block_outlined,
      PublicVoterLookupStatus.deceased => Icons.remove_circle_outline,
      PublicVoterLookupStatus.archived => Icons.archive_outlined,
    };

    final tone = switch (result.status) {
      PublicVoterLookupStatus.eligible || PublicVoterLookupStatus.registeredPreEligible => cs.primary,
      PublicVoterLookupStatus.voted => Colors.green,
      PublicVoterLookupStatus.pendingVerification => Colors.orange,
      PublicVoterLookupStatus.notFound => cs.outline,
      PublicVoterLookupStatus.suspended => cs.error,
      PublicVoterLookupStatus.deceased => cs.error,
      PublicVoterLookupStatus.archived => cs.secondary,
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: tone.withValues(alpha: 0.12),
              child: Icon(icon, color: tone),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.verifyResultTitle, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 6),
                  Text('${t.maskedName}: ${result.maskedName}'),
                  Text('${t.maskedRegNumber}: ${result.maskedRegNumber}'),
                  const SizedBox(height: 6),
                  Text('${t.status}: ${statusLabel(result.status)}'),
                  if (expiryLabel != null) ...[
                    const SizedBox(height: 6),
                    Text('${t.cardExpiry}: $expiryLabel'),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _AlertTone { error, info }

class _AlertCard extends StatelessWidget {
  const _AlertCard({required this.body, required this.tone});

  final String body;
  final _AlertTone tone;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final colors = tone == _AlertTone.error
        ? (cs.errorContainer, cs.onErrorContainer)
        : (cs.primaryContainer, cs.onPrimaryContainer);
    return Card(
      color: colors.$1,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Text(
          body,
          style: TextStyle(color: colors.$2),
        ),
      ),
    );
  }
}
