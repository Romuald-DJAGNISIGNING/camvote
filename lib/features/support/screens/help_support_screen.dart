import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camvote/gen/l10n/app_localizations.dart';

import '../../../core/config/app_config.dart';
import '../../../core/branding/brand_backdrop.dart';
import '../../../core/branding/brand_header.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/motion/cam_reveal.dart';
import '../../../core/widgets/loaders/cameroon_election_loader.dart';
import '../models/support_ticket.dart';
import '../providers/support_providers.dart';
import '../../notifications/widgets/notification_app_bar.dart';

class HelpSupportScreen extends ConsumerStatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  ConsumerState<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends ConsumerState<HelpSupportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _regCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();
  SupportCategory _category = SupportCategory.registration;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _regCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final submitState = ref.watch(supportTicketProvider);
    final isLoading = submitState.isLoading;

    return Scaffold(
      appBar: NotificationAppBar(title: Text(t.helpSupportTitle)),
      body: BrandBackdrop(
        child: ResponsiveContent(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              CamStagger(
                padding: EdgeInsets.zero,
                children: [
                  const SizedBox(height: 6),
                  BrandHeader(
                    title: t.helpSupportTitle,
                    subtitle: t.helpSupportSubtitle,
                  ),
                  const SizedBox(height: 12),
                  if (AppConfig.hasSupportContact)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t.helpSupportEmergencyTitle,
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 6),
                            if (AppConfig.supportEmail.trim().isNotEmpty)
                              Text(
                                '${t.helpSupportEmailLabel}: ${AppConfig.supportEmail}',
                              ),
                            if (AppConfig.supportHotline.trim().isNotEmpty)
                              Text(
                                '${t.helpSupportHotlineLabel}: ${AppConfig.supportHotline}',
                              ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),
                  const _FaqCard(),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _nameCtrl,
                              textInputAction: TextInputAction.next,
                              autofillHints: const [AutofillHints.name],
                              decoration: InputDecoration(
                                labelText: t.fullName,
                              ),
                              validator: (v) => v == null || v.trim().isEmpty
                                  ? t.requiredField
                                  : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _emailCtrl,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              autofillHints: const [AutofillHints.email],
                              decoration: InputDecoration(
                                labelText: t.helpSupportEmailLabel,
                              ),
                              validator: (v) => v == null || v.trim().isEmpty
                                  ? t.requiredField
                                  : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _regCtrl,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                labelText: t.helpSupportRegistrationIdLabel,
                              ),
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<SupportCategory>(
                              initialValue: _category,
                              decoration: InputDecoration(
                                labelText: t.helpSupportCategoryLabel,
                              ),
                              items: SupportCategory.values
                                  .map(
                                    (c) => DropdownMenuItem(
                                      value: c,
                                      child: Text(c.labelFor(t)),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) =>
                                  setState(() => _category = v ?? _category),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _messageCtrl,
                              maxLines: 5,
                              textCapitalization: TextCapitalization.sentences,
                              textInputAction: TextInputAction.newline,
                              decoration: InputDecoration(
                                labelText: t.helpSupportMessageLabel,
                              ),
                              validator: (v) => v == null || v.trim().isEmpty
                                  ? t.requiredField
                                  : null,
                            ),
                            const SizedBox(height: 16),
                            FilledButton.icon(
                              onPressed: isLoading ? null : _submit,
                              icon: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                child: isLoading
                                    ? const CamElectionLoader(
                                        size: 18,
                                        strokeWidth: 2.4,
                                      )
                                    : const Icon(Icons.support_agent),
                              ),
                              label: Text(
                                isLoading
                                    ? t.helpSupportSubmitting
                                    : t.helpSupportSubmit,
                              ),
                            ),
                          ],
                        ),
                      ),
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

  Future<void> _submit() async {
    final t = AppLocalizations.of(context);
    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;

    final ticket = SupportTicket(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      registrationId: _regCtrl.text.trim(),
      category: _category,
      message: _messageCtrl.text.trim(),
    );

    final result =
        await ref.read(supportTicketProvider.notifier).submit(ticket);
    if (!mounted) return;

    if (result == null || result.status == 'error') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result?.message ?? t.helpSupportSubmissionFailed)),
      );
      return;
    }

    _formKey.currentState?.reset();
    _messageCtrl.clear();
    _regCtrl.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          t.helpSupportTicketReceived(
            result.ticketId.isEmpty ? t.unknown : result.ticketId,
          ),
        ),
      ),
    );
  }
}

class _FaqCard extends StatelessWidget {
  const _FaqCard();

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Card(
      child: ExpansionTile(
        title: Text(t.helpSupportFaqTitle),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          Text(t.helpSupportFaqRegistration),
          const SizedBox(height: 6),
          Text(t.helpSupportFaqLiveness),
          const SizedBox(height: 6),
          Text(t.helpSupportFaqReceipt),
        ],
      ),
    );
  }
}
