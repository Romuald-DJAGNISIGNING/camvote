import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:camvote/gen/l10n/app_localizations.dart';

import '../../../core/config/app_config.dart';
import '../../../core/branding/brand_backdrop.dart';
import '../../../core/branding/brand_header.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/motion/cam_reveal.dart';
import '../../../core/routing/route_paths.dart';
import '../../../core/theme/role_theme.dart';
import '../../../core/utils/external_links.dart';
import '../../../core/widgets/feedback/cam_toast.dart';
import '../../../core/widgets/loaders/camvote_pulse_loading.dart';
import '../../../core/widgets/loaders/cameroon_election_loader.dart';
import '../../auth/providers/auth_providers.dart';
import '../../notifications/providers/notifications_providers.dart';
import '../../notifications/domain/cam_notification.dart';
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
  final _categoryFieldKey = GlobalKey<FormFieldState<SupportCategory>>();
  final _ticketFormCardKey = GlobalKey();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _regCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();
  final _messageFocusNode = FocusNode();
  SupportCategory _category = SupportCategory.registration;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _regCtrl.dispose();
    _messageCtrl.dispose();
    _messageFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final submitState = ref.watch(supportTicketProvider);
    final isLoading = submitState.isLoading;
    final pendingOfflineCount =
        ref.watch(pendingOfflineSupportTicketsProvider).asData?.value ?? 0;

    return Scaffold(
      appBar: NotificationAppBar(title: Text(t.helpSupportTitle)),
      body: Stack(
        children: [
          BrandBackdrop(
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
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
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
                                const SizedBox(height: 10),
                                Wrap(
                                  spacing: 10,
                                  runSpacing: 10,
                                  children: [
                                    FilledButton.icon(
                                      onPressed: _openLiveHelpDesk,
                                      icon: const Icon(Icons.support_agent),
                                      label: Text(t.helpSupportLiveHelpDesk),
                                    ),
                                    if (AppConfig.supportHotline
                                        .trim()
                                        .isNotEmpty)
                                      OutlinedButton.icon(
                                        onPressed: _openWhatsApp,
                                        icon: const Icon(Icons.chat_outlined),
                                        label: Text(t.helpSupportChatWhatsApp),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(height: 12),
                      const _FaqCard(),
                      if (pendingOfflineCount > 0) ...[
                        const SizedBox(height: 12),
                        Card(
                          child: ListTile(
                            leading: const Icon(Icons.cloud_upload_outlined),
                            title: Text(t.helpSupportOfflineQueueTitle),
                            subtitle: Text(
                              t.helpSupportOfflineQueueBodyCount(
                                pendingOfflineCount,
                              ),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      Card(
                        child: ListTile(
                          leading: const Icon(Icons.favorite_outline),
                          title: Text(t.supportCamVoteTitle),
                          subtitle: Text(t.supportCamVoteSubtitle),
                          trailing: const Icon(Icons.chevron_right_rounded),
                          onTap: () => context.push(RoutePaths.supportTip),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Card(
                        key: _ticketFormCardKey,
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
                                  validator: (v) =>
                                      v == null || v.trim().isEmpty
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
                                  validator: (v) {
                                    final value = (v ?? '').trim();
                                    if (value.isEmpty) {
                                      return t.requiredField;
                                    }
                                    if (!RegExp(
                                      r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
                                    ).hasMatch(value)) {
                                      return t.invalidEmailAddress;
                                    }
                                    return null;
                                  },
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
                                  key: _categoryFieldKey,
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
                                  onChanged: (v) => setState(
                                    () => _category = v ?? _category,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: _messageCtrl,
                                  focusNode: _messageFocusNode,
                                  maxLines: 5,
                                  textCapitalization:
                                      TextCapitalization.sentences,
                                  textInputAction: TextInputAction.newline,
                                  decoration: InputDecoration(
                                    labelText: t.helpSupportMessageLabel,
                                  ),
                                  validator: (v) =>
                                      v == null || v.trim().isEmpty
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
          if (isLoading)
            Positioned.fill(
              child: CamVoteLoadingOverlay(
                title: t.helpSupportSubmitting,
                subtitle: t.helpSupportSubtitle,
              ),
            ),
        ],
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

    final result = await ref
        .read(supportTicketProvider.notifier)
        .submit(ticket);
    if (!mounted) return;

    if (result == null || result.status == 'error') {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.helpSupportSubmissionFailed)));
      return;
    }

    final ticketId = result.ticketId.isEmpty ? t.unknown : result.ticketId;
    final queueId = result.offlineQueueId.isEmpty
        ? t.unknown
        : result.offlineQueueId;
    final successMessage = result.queuedOffline
        ? t.helpSupportTicketQueued(queueId)
        : t.helpSupportTicketReceived(ticketId);
    final role = ref.read(authControllerProvider).asData?.value.user?.role;
    final audience = switch (role) {
      AppRole.admin => CamAudience.admin,
      AppRole.observer => CamAudience.observer,
      AppRole.voter => CamAudience.voter,
      _ => CamAudience.public,
    };

    await ref
        .read(notificationsControllerProvider.notifier)
        .add(
          id: 'support_ticket_received_${result.ticketId.isEmpty ? queueId : result.ticketId}',
          type: result.queuedOffline
              ? CamNotificationType.info
              : CamNotificationType.success,
          audience: audience,
          title: t.helpSupportTitle,
          body: successMessage,
          route:
              '${RoutePaths.helpSupport}?ticketId=${result.ticketId}&queueId=${result.offlineQueueId}',
          alsoPush: true,
        );
    if (!mounted) return;

    FocusScope.of(context).unfocus();
    setState(() => _category = SupportCategory.registration);
    _categoryFieldKey.currentState?.didChange(SupportCategory.registration);
    _nameCtrl.clear();
    _emailCtrl.clear();
    _messageCtrl.clear();
    _regCtrl.clear();

    if (!mounted) return;
    if (result.queuedOffline) {
      CamToast.show(context, message: successMessage, type: CamToastType.info);
      return;
    }
    await CamToast.celebrate(
      context,
      title: t.helpSupportTitle,
      message: successMessage,
    );
  }

  Future<void> _openWhatsApp() async {
    final rawHotline = AppConfig.supportHotline.trim();
    if (rawHotline.isEmpty) return;
    final phone = _normalizePhoneNumber(rawHotline);
    if (phone.isEmpty) return;
    final t = AppLocalizations.of(context);
    final presetMessage = Uri.encodeComponent(t.helpSupportWhatsAppGreeting);
    final url = 'https://wa.me/$phone?text=$presetMessage';
    final launched = await openExternalLink(
      context,
      url,
      fallbackUrl:
          'https://api.whatsapp.com/send?phone=$phone&text=$presetMessage',
      showError: false,
    );
    if (launched || !mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(t.helpSupportWhatsAppOpenFailed)));
  }

  String _normalizePhoneNumber(String raw) {
    return raw.replaceAll(RegExp(r'[^0-9]'), '');
  }

  Future<void> _openLiveHelpDesk() async {
    final role = ref.read(currentRoleProvider);
    if (role == AppRole.admin) {
      if (!mounted) return;
      context.push(RoutePaths.adminSupport);
      return;
    }

    final targetContext = _ticketFormCardKey.currentContext;
    if (targetContext != null) {
      await Scrollable.ensureVisible(
        targetContext,
        alignment: 0.08,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    }
    if (!mounted) return;
    _messageFocusNode.requestFocus();
    final t = AppLocalizations.of(context);
    CamToast.show(context, message: t.helpSupportLiveHelpDeskHint);
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
          const SizedBox(height: 6),
          Text(t.helpSupportFaqObserverHowTo),
        ],
      ),
    );
  }
}
