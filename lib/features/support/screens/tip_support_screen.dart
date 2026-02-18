import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:camvote/gen/l10n/app_localizations.dart';

import '../../../core/branding/brand_backdrop.dart';
import '../../../core/branding/brand_header.dart';
import '../../../core/config/app_config.dart';
import '../../../core/errors/error_message.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/motion/cam_motion.dart';
import '../../../core/offline/offline_status_providers.dart';
import '../../../core/theme/role_theme.dart';
import '../../../core/widgets/feedback/cam_toast.dart';
import '../../../core/widgets/loaders/camvote_pulse_loading.dart';
import '../../../core/widgets/qr/branded_qr_code.dart';
import '../../auth/providers/auth_providers.dart';
import '../../notifications/domain/cam_notification.dart';
import '../../notifications/providers/notifications_providers.dart';
import '../../notifications/widgets/notification_app_bar.dart';
import '../models/tip_models.dart';
import '../providers/tip_providers.dart';
import '../utils/tip_checkout_links.dart';
import '../utils/tip_input_constraints.dart';

class TipSupportScreen extends ConsumerStatefulWidget {
  const TipSupportScreen({super.key});

  @override
  ConsumerState<TipSupportScreen> createState() => _TipSupportScreenState();
}

class _TipSupportScreenState extends ConsumerState<TipSupportScreen> {
  static const List<int> _quickAmounts = <int>[2000, 5000, 10000, 20000, 50000];
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _amountCtrl = TextEditingController(text: '5000');
  final _messageCtrl = TextEditingController();
  final _referenceCtrl = TextEditingController();
  final _proofNoteCtrl = TextEditingController();
  String _currency = 'XAF';
  TipProviderChannel _channel = TipProviderChannel.tapTapSend;
  bool _anonymous = false;
  String _activeTipId = '';
  final Set<String> _notified = <String>{};
  bool _submittingProof = false;
  bool _uploadingProof = false;
  final List<String> _proofAttachments = <String>[];
  Timer? _statusPollTimer;
  int _statusPollAttempts = 0;
  static const Duration _statusPollInterval = Duration(seconds: 10);
  static const int _statusPollMaxAttempts = 18;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final state = GoRouterState.of(context);
      final tipId = state.uri.queryParameters['tipId']?.trim() ?? '';
      if (tipId.isNotEmpty) {
        _activeTipId = tipId;
        ref.read(tipStatusProvider.notifier).refresh(tipId);
        _startStatusPolling(tipId);
      }
    });
  }

  @override
  void dispose() {
    _stopStatusPolling();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _amountCtrl.dispose();
    _messageCtrl.dispose();
    _referenceCtrl.dispose();
    _proofNoteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final checkoutState = ref.watch(tipCheckoutProvider);
    final statusState = ref.watch(tipStatusProvider);
    final authState = ref.watch(authControllerProvider);
    final offline = ref.watch(isOfflineProvider);
    final pendingOfflineTipCount =
        ref.watch(pendingOfflineTipQueueProvider).asData?.value ?? 0;
    final selectedAmount = int.tryParse(_amountCtrl.text.trim()) ?? 0;
    final isSignedIn = authState.asData?.value.user != null;
    final isSubmitting = checkoutState.isLoading;
    final session = checkoutState.asData?.value;
    final isTapTapSession =
        session?.provider.toLowerCase().trim() == 'taptap_send';
    final isRemitlySession =
        session?.provider.toLowerCase().trim() == 'remitly';
    final providerKey = session?.provider.toLowerCase().trim() ?? '';
    final isMaxItQrSession =
        providerKey == 'maxit_qr' || providerKey == 'maxit';
    final sessionQrValue = session?.qrUrl?.trim() ?? '';
    final configuredMaxItQrImage = AppConfig.maxItTipQrImageUrl.trim();
    final maxItQrPayload = sessionQrValue.isNotEmpty
        ? sessionQrValue
        : configuredMaxItQrImage;
    final hasMaxItQr = isMaxItQrSession && maxItQrPayload.isNotEmpty;
    final statusResult = statusState.asData?.value;
    final statusPollingProgress = (_statusPollAttempts / _statusPollMaxAttempts)
        .clamp(0.0, 1.0);
    final showStatusPollingProgress =
        _activeTipId.isNotEmpty &&
        _statusPollAttempts > 0 &&
        _statusPollAttempts < _statusPollMaxAttempts &&
        !(statusResult?.isSuccess ?? false);

    ref.listen<AsyncValue<TipStatusResult?>>(tipStatusProvider, (
      previous,
      next,
    ) {
      final result = next.asData?.value;
      if (result == null) return;
      if (result.isSuccess && result.tipId == _activeTipId.trim()) {
        _stopStatusPolling();
      }
      unawaited(_handleTipStatusSideEffects(result));
    });
    ref.listen<AsyncValue<TipCheckoutSession?>>(tipCheckoutProvider, (
      previous,
      next,
    ) {
      final error = next.asError;
      if (error == null) return;
      final message = safeErrorMessage(
        context,
        error.error,
        fallback: error.error.toString(),
      );
      CamToast.show(context, message: message);
    });

    return Scaffold(
      appBar: NotificationAppBar(title: Text(t.supportCamVoteTitle)),
      body: Stack(
        children: [
          BrandBackdrop(
            child: ResponsiveContent(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  const SizedBox(height: 6),
                  BrandHeader(
                    title: t.supportCamVoteHeaderTitle,
                    subtitle: t.supportCamVoteHeaderSubtitle,
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t.supportCamVoteImpactTitle,
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 6),
                          Text(t.supportCamVoteImpactIntro),
                          const SizedBox(height: 10),
                          _ImpactLine(
                            icon: Icons.verified_user_outlined,
                            text: t.supportCamVoteImpactSecurity,
                          ),
                          const SizedBox(height: 6),
                          _ImpactLine(
                            icon: Icons.bolt_outlined,
                            text: t.supportCamVoteImpactReliability,
                          ),
                          const SizedBox(height: 6),
                          _ImpactLine(
                            icon: Icons.public_outlined,
                            text: t.supportCamVoteImpactCommunity,
                          ),
                          const SizedBox(height: 6),
                          _ImpactLine(
                            icon: Icons.visibility_outlined,
                            text: t.supportCamVoteImpactTransparency,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (pendingOfflineTipCount > 0) ...[
                    const SizedBox(height: 12),
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.cloud_upload_outlined),
                        title: Text(t.helpSupportOfflineQueueTitle),
                        subtitle: Text(
                          offline
                              ? t.offlineBannerOfflineBodyCount(
                                  pendingOfflineTipCount,
                                )
                              : t.offlineBannerPendingBodyCount(
                                  pendingOfflineTipCount,
                                ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t.tipChoosePaymentChannel,
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 10),
                          SegmentedButton<TipProviderChannel>(
                            segments: [
                              ButtonSegment(
                                value: TipProviderChannel.tapTapSend,
                                label: Text(t.tipChannelElyonpay),
                                icon: Icon(Icons.send_to_mobile),
                              ),
                              ButtonSegment(
                                value: TipProviderChannel.remitly,
                                label: Text(t.tipChannelRemitly),
                                icon: Icon(Icons.payments_outlined),
                              ),
                              ButtonSegment(
                                value: TipProviderChannel.maxItQr,
                                label: Text(t.tipChannelMaxItQr),
                                icon: Icon(Icons.qr_code_2),
                              ),
                            ],
                            selected: {_channel},
                            onSelectionChanged: (value) {
                              final next = value.first;
                              if (next == _channel) return;
                              _stopStatusPolling();
                              unawaited(HapticFeedback.selectionClick());
                              setState(() {
                                _channel = next;
                                _activeTipId = '';
                                _statusPollAttempts = 0;
                                _referenceCtrl.clear();
                                _proofNoteCtrl.clear();
                                _proofAttachments.clear();
                              });
                              ref.read(tipCheckoutProvider.notifier).clear();
                              ref.read(tipStatusProvider.notifier).clear();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            SwitchListTile.adaptive(
                              value: _anonymous,
                              contentPadding: EdgeInsets.zero,
                              title: Text(t.tipAnonymousTitle),
                              subtitle: Text(t.tipAnonymousSubtitle),
                              onChanged: (value) {
                                setState(() => _anonymous = value);
                              },
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _nameCtrl,
                              enabled: !_anonymous,
                              decoration: InputDecoration(
                                labelText: _anonymous
                                    ? t.tipNameHiddenLabel
                                    : t.fullName,
                              ),
                              validator: (value) {
                                if (_anonymous) return null;
                                return (value == null || value.trim().isEmpty)
                                    ? t.requiredField
                                    : null;
                              },
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                              controller: _emailCtrl,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                labelText: t.helpSupportEmailLabel,
                              ),
                              validator: (value) {
                                final normalized = sanitizeTipEmail(
                                  value?.trim() ?? '',
                                );
                                if (normalized.isEmpty) return null;
                                return isValidTipEmail(normalized)
                                    ? null
                                    : t.invalidEmailAddress;
                              },
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _amountCtrl,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    decoration: InputDecoration(
                                      labelText: t.tipAmountLabel,
                                    ),
                                    validator: (value) {
                                      final amount = int.tryParse(
                                        value?.trim() ?? '',
                                      );
                                      if (amount == null ||
                                          !isTipAmountInRange(amount)) {
                                        return t.tipAmountInvalid;
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(width: 10),
                                SizedBox(
                                  width: 110,
                                  child: DropdownButtonFormField<String>(
                                    initialValue: _currency,
                                    decoration: InputDecoration(
                                      labelText: t.tipCurrencyLabel,
                                    ),
                                    items: const [
                                      DropdownMenuItem(
                                        value: 'XAF',
                                        child: Text('XAF'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'USD',
                                        child: Text('USD'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'EUR',
                                        child: Text('EUR'),
                                      ),
                                    ],
                                    onChanged: (value) {
                                      if (value == null) return;
                                      setState(() => _currency = value);
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  for (final quickAmount in _quickAmounts)
                                    ChoiceChip(
                                      selected: selectedAmount == quickAmount,
                                      label: Text(
                                        _formatTipAmountLabel(quickAmount),
                                      ),
                                      onSelected: (_) {
                                        _setQuickAmount(quickAmount);
                                      },
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                              controller: _messageCtrl,
                              maxLines: 3,
                              decoration: InputDecoration(
                                labelText: t.tipPersonalMessageLabel,
                              ),
                            ),
                            const SizedBox(height: 14),
                            FilledButton.icon(
                              onPressed: isSubmitting ? null : _startTipFlow,
                              icon: Icon(
                                _channel == TipProviderChannel.maxItQr
                                    ? Icons.qr_code
                                    : Icons.open_in_new,
                              ),
                              label: Text(
                                _channel == TipProviderChannel.tapTapSend
                                    ? t.tipPayWithElyonpay
                                    : _channel == TipProviderChannel.remitly
                                    ? t.tipPayWithRemitly
                                    : t.tipGenerateMaxItQr,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (session != null) ...[
                    const SizedBox(height: 12),
                    _TipSessionCard(
                      session: session,
                      t: t,
                      onOpenCheckout:
                          (providerKey == 'taptap_send' ||
                              providerKey == 'remitly')
                          ? () => _openCheckoutForSession(session)
                          : null,
                      onOpenDeepLink:
                          (providerKey == 'maxit_qr' ||
                                  providerKey == 'maxit') &&
                              session.deepLink != null
                          ? () => _openUrl(session.deepLink!)
                          : null,
                    ),
                  ],
                  if (session != null &&
                      (isTapTapSession || isRemitlySession)) ...[
                    const SizedBox(height: 12),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isRemitlySession
                                  ? t.tipRemitlyInstructionsTitle
                                  : t.tipTapTapSendInstructionsTitle,
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              isRemitlySession
                                  ? t.tipRemitlyInstructionsBody
                                  : t.tipTapTapSendInstructionsBody,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _referenceCtrl,
                              decoration: InputDecoration(
                                labelText: t.tipReferenceLabel,
                                hintText: t.tipReferenceHint,
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                              controller: _proofNoteCtrl,
                              maxLines: 3,
                              decoration: InputDecoration(
                                labelText: t.tipProofNoteLabel,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              t.tipReceiptOptionalTitle,
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              t.tipReceiptOptionalBody,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: 8),
                            if (_proofAttachments.isNotEmpty)
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  for (
                                    int i = 0;
                                    i < _proofAttachments.length;
                                    i += 1
                                  )
                                    InputChip(
                                      label: Text(
                                        '${t.tipReceiptLabel} ${i + 1}',
                                      ),
                                      onDeleted: () {
                                        setState(() {
                                          _proofAttachments.removeAt(i);
                                        });
                                      },
                                    ),
                                ],
                              ),
                            const SizedBox(height: 8),
                            OutlinedButton.icon(
                              onPressed: _uploadingProof
                                  ? null
                                  : () => _addReceipt(isSignedIn),
                              icon: _uploadingProof
                                  ? const SizedBox(
                                      height: 16,
                                      width: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.upload_file_outlined),
                              label: Text(t.tipReceiptUploadAction),
                            ),
                            const SizedBox(height: 12),
                            FilledButton.icon(
                              onPressed: _submittingProof
                                  ? null
                                  : _submitTapTapSendProof,
                              icon: _submittingProof
                                  ? const SizedBox(
                                      height: 16,
                                      width: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.verified_outlined),
                              label: Text(t.tipSubmitProof),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  if (hasMaxItQr) ...[
                    const SizedBox(height: 12),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Text(
                              t.tipScanMaxItQr,
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 12),
                            _TipQrVisual(payload: maxItQrPayload, size: 210),
                          ],
                        ),
                      ),
                    ),
                  ],
                  if (_activeTipId.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t.tipPaymentTrackingTitle,
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '${t.tipReferenceLabel}: $_activeTipId',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                ),
                                OutlinedButton.icon(
                                  onPressed: () => ref
                                      .read(tipStatusProvider.notifier)
                                      .refresh(_activeTipId),
                                  icon: const Icon(Icons.refresh),
                                  label: Text(t.tipCheckStatus),
                                ),
                              ],
                            ),
                            if (showStatusPollingProgress) ...[
                              const SizedBox(height: 8),
                              LinearProgressIndicator(
                                value: statusPollingProgress,
                              ),
                            ],
                            const SizedBox(height: 8),
                            AnimatedSwitcher(
                              duration: CamMotion.medium,
                              switchInCurve: CamMotion.emphasized,
                              switchOutCurve: Curves.easeIn,
                              child: statusState.when(
                                data: (result) {
                                  if (result == null) {
                                    return Text(
                                      t.tipWaitingConfirmation,
                                      key: const ValueKey('tip_status_waiting'),
                                    );
                                  }
                                  return _TipStatusPanel(
                                    key: ValueKey(
                                      'tip_status_${result.tipId}_${result.status}',
                                    ),
                                    result: result,
                                    t: t,
                                  );
                                },
                                loading: () => Padding(
                                  key: const ValueKey('tip_status_loading'),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  child: CamVotePulseLoading(
                                    title: t.tipCheckingPayment,
                                    compact: true,
                                  ),
                                ),
                                error: (error, _) => Text(
                                  error.toString(),
                                  key: const ValueKey('tip_status_error'),
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                ],
              ),
            ),
          ),
          if (isSubmitting)
            Positioned.fill(
              child: CamVoteLoadingOverlay(
                title: t.tipPreparingSecurePaymentTitle,
                subtitle: t.tipPreparingSecurePaymentSubtitle,
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _startTipFlow() async {
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) return;
    final amount = int.tryParse(_amountCtrl.text.trim()) ?? 0;
    if (!isTipAmountInRange(amount)) {
      final t = AppLocalizations.of(context);
      CamToast.show(context, message: t.tipAmountInvalid);
      return;
    }
    final t = AppLocalizations.of(context);
    final senderEmail = sanitizeTipEmail(_emailCtrl.text);
    if (senderEmail.isNotEmpty && !isValidTipEmail(senderEmail)) {
      CamToast.show(context, message: t.invalidEmailAddress);
      return;
    }
    final senderName = _anonymous
        ? t.tipAnonymousSupporterName
        : _nameCtrl.text.trim();
    final controller = ref.read(tipCheckoutProvider.notifier);
    TipCheckoutSession? session;
    switch (_channel) {
      case TipProviderChannel.tapTapSend:
        session = await controller.createTapTapSend(
          senderName: senderName,
          senderEmail: senderEmail,
          amount: amount,
          currency: _currency,
          anonymous: _anonymous,
          message: _messageCtrl.text.trim(),
        );
        break;
      case TipProviderChannel.remitly:
        session = await controller.createRemitly(
          senderName: senderName,
          senderEmail: senderEmail,
          amount: amount,
          currency: _currency,
          anonymous: _anonymous,
          message: _messageCtrl.text.trim(),
        );
        break;
      case TipProviderChannel.maxItQr:
        session = await controller.createMaxItQr(
          senderName: senderName,
          senderEmail: senderEmail,
          amount: amount,
          currency: _currency,
          anonymous: _anonymous,
          message: _messageCtrl.text.trim(),
        );
        break;
    }
    if (!mounted || session == null) return;
    _stopStatusPolling();
    session = _normalizeSessionForSelectedChannel(session);
    ref.read(tipCheckoutProvider.notifier).setSession(session);

    final tipId = session.tipId;
    setState(() {
      _activeTipId = tipId;
      _statusPollAttempts = 0;
    });
    if (tipId.isNotEmpty) {
      _startStatusPolling(tipId);
    }

    if (_channel == TipProviderChannel.tapTapSend ||
        _channel == TipProviderChannel.remitly) {
      await _openCheckoutForSession(session);
    } else if (session.deepLink != null &&
        session.deepLink!.trim().isNotEmpty) {
      await _openUrl(session.deepLink!);
    }

    if (_activeTipId.isNotEmpty) {
      await ref.read(tipStatusProvider.notifier).refresh(_activeTipId);
    }
  }

  void _setQuickAmount(int amount) {
    setState(() {
      _amountCtrl.text = '$amount';
    });
  }

  TipCheckoutSession _normalizeSessionForSelectedChannel(
    TipCheckoutSession session,
  ) {
    final recipientNumber = session.orangeMoneyNumber?.trim().isNotEmpty == true
        ? session.orangeMoneyNumber!.trim()
        : AppConfig.tipOrangeMoneyNumber.trim();
    final recipientName = session.orangeMoneyOwner?.trim().isNotEmpty == true
        ? session.orangeMoneyOwner!.trim()
        : AppConfig.tipOrangeMoneyName.trim();
    final amount = session.amount > 0
        ? session.amount
        : (int.tryParse(_amountCtrl.text.trim()) ?? 0);
    final currency = session.currency.trim().isNotEmpty
        ? session.currency.trim().toUpperCase()
        : _currency.trim().toUpperCase();
    if (_channel == TipProviderChannel.maxItQr) {
      final qrUrl = session.qrUrl?.trim().isNotEmpty == true
          ? session.qrUrl
          : AppConfig.maxItTipQrImageUrl.trim();
      return session.copyWith(provider: 'maxit_qr', qrUrl: qrUrl);
    }

    final checkoutProvider = _channel == TipProviderChannel.remitly
        ? TipCheckoutProvider.remitly
        : TipCheckoutProvider.tapTapSend;
    final fallbackLinks = buildFallbackTipCheckoutLinks(
      provider: checkoutProvider,
      tipId: session.tipId,
      amount: amount,
      currency: currency,
      recipientName: recipientName,
      recipientNumber: recipientNumber,
    );
    final checkout =
        isExpectedTipCheckoutUrl(
          provider: checkoutProvider,
          url: session.checkoutUrl,
        )
        ? session.checkoutUrl
        : fallbackLinks.checkoutUrl;
    final deepLink =
        isExpectedTipDeepLink(provider: checkoutProvider, url: session.deepLink)
        ? session.deepLink
        : fallbackLinks.deepLink;
    return session.copyWith(
      provider: checkoutProvider.apiValue,
      checkoutUrl: checkout,
      deepLink: deepLink,
    );
  }

  Future<void> _submitTapTapSendProof() async {
    final t = AppLocalizations.of(context);
    final tipId = _activeTipId.trim();
    if (tipId.isEmpty) {
      CamToast.show(context, message: t.tipReferenceMissing);
      return;
    }
    final reference = _referenceCtrl.text.trim();
    if (reference.isEmpty) {
      CamToast.show(context, message: t.tipReferenceMissing);
      return;
    }

    setState(() => _submittingProof = true);
    try {
      final proof = await ref
          .read(tipRepositoryProvider)
          .submitTapTapSendProof(
            tipId: tipId,
            reference: reference,
            note: _proofNoteCtrl.text.trim(),
            attachments: _proofAttachments,
          );
      if (!mounted) return;
      if (proof.queuedOffline) {
        final queueId = proof.offlineQueueId.isEmpty
            ? t.unknown
            : proof.offlineQueueId;
        CamToast.show(
          context,
          message:
              '${t.helpSupportOfflineQueueTitle}. ${t.trackingIdLabel}: $queueId',
          type: CamToastType.info,
        );
      } else {
        CamToast.show(context, message: t.tipSubmittedBody);
        await ref.read(tipStatusProvider.notifier).refresh(tipId);
      }
    } catch (error) {
      if (!mounted) return;
      CamToast.show(context, message: safeErrorMessage(context, error));
    } finally {
      if (mounted) {
        setState(() => _submittingProof = false);
      }
    }
  }

  Future<void> _addReceipt(bool isSignedIn) async {
    final t = AppLocalizations.of(context);
    if (!isSignedIn) {
      CamToast.show(context, message: t.authRequired);
      return;
    }
    setState(() => _uploadingProof = true);
    try {
      final picker = ImagePicker();
      final file = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (file == null) return;
      final url = await ref.read(tipRepositoryProvider).uploadReceipt(file);
      if (!mounted) return;
      setState(() => _proofAttachments.add(url));
    } catch (error) {
      if (!mounted) return;
      CamToast.show(context, message: safeErrorMessage(context, error));
    } finally {
      if (mounted) {
        setState(() => _uploadingProof = false);
      }
    }
  }

  Future<bool> _openUrl(
    String url, {
    bool showError = true,
    bool preferSelfOnWeb = false,
  }) async {
    final t = AppLocalizations.of(context);
    final trimmed = url.trim();
    final uri = Uri.tryParse(trimmed);
    if (uri == null) {
      if (showError) {
        CamToast.show(context, message: t.openLinkFailed);
      }
      return false;
    }
    var opened = false;
    if (kIsWeb) {
      final primary = preferSelfOnWeb ? '_self' : '_blank';
      final secondary = preferSelfOnWeb ? '_blank' : '_self';
      opened = await launchUrl(
        uri,
        mode: LaunchMode.platformDefault,
        webOnlyWindowName: primary,
      );
      if (!opened) {
        opened = await launchUrl(
          uri,
          mode: LaunchMode.platformDefault,
          webOnlyWindowName: secondary,
        );
      }
    } else {
      opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    if (!opened && showError && mounted) {
      CamToast.show(context, message: t.openLinkFailed);
    }
    return opened;
  }

  Future<void> _openCheckoutForSession(TipCheckoutSession session) async {
    final t = AppLocalizations.of(context);
    final provider = tipCheckoutProviderFromValue(session.provider);
    if (provider != null) {
      final fullRecipientNumber =
          session.orangeMoneyNumber?.trim().isNotEmpty == true
          ? session.orangeMoneyNumber!.trim()
          : AppConfig.tipOrangeMoneyNumber.trim();
      final recipientName = session.orangeMoneyOwner?.trim().isNotEmpty == true
          ? session.orangeMoneyOwner!.trim()
          : AppConfig.tipOrangeMoneyName.trim();
      final maskedRecipientNumber =
          session.orangeMoneyMaskedNumber?.trim().isNotEmpty == true
          ? session.orangeMoneyMaskedNumber!.trim()
          : _maskPhoneNumber(fullRecipientNumber);
      final amount = session.amount > 0
          ? session.amount
          : (int.tryParse(_amountCtrl.text.trim()) ?? 0);
      final currency = session.currency.trim().isNotEmpty
          ? session.currency.trim().toUpperCase()
          : _currency.trim().toUpperCase();
      final rawCheckout = session.checkoutUrl?.trim() ?? '';
      final canUseCheckout = isExpectedTipCheckoutUrl(
        provider: provider,
        url: rawCheckout,
      );
      final sanitizedCheckout = canUseCheckout
          ? maybeUpgradeMaskedRecipientNumberInCheckoutUrl(
              rawCheckout,
              fullRecipientNumber: fullRecipientNumber,
            )
          : rawCheckout;
      final fallbackLinks = buildFallbackTipCheckoutLinks(
        provider: provider,
        tipId: session.tipId,
        amount: amount,
        currency: currency,
        recipientName: recipientName,
        recipientNumber: fullRecipientNumber.isNotEmpty
            ? fullRecipientNumber
            : maskedRecipientNumber,
      );
      final checkout = canUseCheckout
          ? sanitizedCheckout
          : fallbackLinks.checkoutUrl;
      final rawDeepLink = session.deepLink?.trim() ?? '';
      final canUseDeepLink = isExpectedTipDeepLink(
        provider: provider,
        url: rawDeepLink,
      );
      final deepLink = canUseDeepLink
          ? rawDeepLink
          : buildFallbackTipCheckoutLinks(
              provider: provider,
              tipId: session.tipId,
              amount: amount,
              currency: currency,
              recipientName: recipientName,
              recipientNumber: fullRecipientNumber,
            ).deepLink;
      final shouldTryDeepLinkFirst = !kIsWeb || _isLikelyMobileWebBrowser();

      if (shouldTryDeepLinkFirst && deepLink.isNotEmpty) {
        final openedDeepLink = await _openUrl(
          deepLink,
          showError: false,
          preferSelfOnWeb: true,
        );
        if (openedDeepLink) {
          return;
        }
      }

      if (checkout.isNotEmpty) {
        final openedCheckout = await _openUrl(checkout, showError: false);
        if (openedCheckout) {
          return;
        }
      }

      if (!shouldTryDeepLinkFirst && deepLink.isNotEmpty) {
        final openedDeepLink = await _openUrl(
          deepLink,
          showError: false,
          preferSelfOnWeb: true,
        );
        if (openedDeepLink) {
          return;
        }
      }

      if (mounted) {
        CamToast.show(context, message: t.openLinkFailed);
      }
      return;
    }

    final checkout = session.checkoutUrl?.trim() ?? '';
    if (checkout.isNotEmpty) {
      await _openUrl(checkout);
      return;
    }

    CamToast.show(context, message: t.openLinkFailed);
  }

  bool _isLikelyMobileWebBrowser() {
    if (!kIsWeb) return false;
    final platform = defaultTargetPlatform;
    if (platform == TargetPlatform.android || platform == TargetPlatform.iOS) {
      return true;
    }
    final shortestSide = MediaQuery.sizeOf(context).shortestSide;
    return shortestSide < 700;
  }

  void _startStatusPolling(String tipId) {
    final normalized = tipId.trim();
    if (normalized.isEmpty) return;
    if (_statusPollTimer != null) return;

    _statusPollAttempts = 0;
    _statusPollTimer = Timer.periodic(_statusPollInterval, (timer) {
      if (!mounted) {
        timer.cancel();
        _statusPollTimer = null;
        return;
      }
      final currentState = ref.read(tipStatusProvider).asData?.value;
      final alreadyConfirmed =
          currentState?.tipId == normalized && currentState?.isSuccess == true;
      if (alreadyConfirmed || _statusPollAttempts >= _statusPollMaxAttempts) {
        timer.cancel();
        _statusPollTimer = null;
        return;
      }
      _statusPollAttempts += 1;
      ref.read(tipStatusProvider.notifier).refresh(normalized);
    });
  }

  void _stopStatusPolling() {
    _statusPollTimer?.cancel();
    _statusPollTimer = null;
    _statusPollAttempts = 0;
  }

  Future<void> _handleTipStatusSideEffects(TipStatusResult result) async {
    if (!result.isSuccess || _notified.contains(result.tipId) || !mounted) {
      return;
    }
    final t = AppLocalizations.of(context);
    _notified.add(result.tipId);
    await ref.read(tipStatusProvider.notifier).notifySuccess(result.tipId);
    if (!mounted) return;

    final auth = ref.read(authControllerProvider).asData?.value;
    final role = auth?.user?.role ?? AppRole.public;
    final audience = switch (role) {
      AppRole.admin => CamAudience.admin,
      AppRole.observer => CamAudience.observer,
      AppRole.voter => CamAudience.voter,
      _ => CamAudience.public,
    };
    final displayName = result.anonymous
        ? t.tipAnonymousSupporterName
        : result.senderName;
    final fallbackThankYou = t.tipThankYouBodyAmount(
      displayName,
      result.amount,
      result.currency,
    );
    final fallbackNotificationBody = t.tipNotificationReceivedBodyAmount(
      displayName,
      result.amount,
      result.currency,
    );
    await ref
        .read(notificationsControllerProvider.notifier)
        .add(
          id: 'tip_success_${result.tipId}',
          type: CamNotificationType.success,
          audience: audience,
          title: t.tipNotificationReceivedTitle,
          body: result.thankYouMessage ?? fallbackNotificationBody,
          route: '/support/tip?tipId=${result.tipId}',
          alsoPush: true,
        );
    if (!mounted) return;
    await HapticFeedback.mediumImpact();
    if (!mounted) return;
    await CamToast.celebrate(
      context,
      title: t.tipThankYouTitle(displayName),
      message: result.thankYouMessage ?? fallbackThankYou,
    );
  }
}

class _TipSessionCard extends StatelessWidget {
  const _TipSessionCard({
    required this.session,
    required this.t,
    this.onOpenCheckout,
    this.onOpenDeepLink,
  });

  final TipCheckoutSession session;
  final AppLocalizations t;
  final VoidCallback? onOpenCheckout;
  final VoidCallback? onOpenDeepLink;

  @override
  Widget build(BuildContext context) {
    final configNumber = AppConfig.tipOrangeMoneyNumber.trim();
    final configOwner = AppConfig.tipOrangeMoneyName.trim();
    final apiMoneyNumber = session.orangeMoneyNumber?.trim() ?? '';
    final apiMaskedNumber = session.orangeMoneyMaskedNumber?.trim() ?? '';
    final fullMoneyNumber = apiMoneyNumber.isNotEmpty
        ? apiMoneyNumber
        : configNumber;
    final canShowMoneyNumber =
        apiMoneyNumber.isNotEmpty || AppConfig.tipOrangeMoneyNumberPublic;
    final maskedMoneyNumber = apiMaskedNumber.isNotEmpty
        ? apiMaskedNumber
        : _maskPhoneNumber(fullMoneyNumber);
    final moneyNumber = canShowMoneyNumber
        ? fullMoneyNumber
        : maskedMoneyNumber;
    final moneyOwner = (session.orangeMoneyOwner?.trim().isNotEmpty ?? false)
        ? session.orangeMoneyOwner!.trim()
        : configOwner;
    final ownerFallback = t.tipRecipientNameNotConfigured;
    final ownerName = moneyOwner.isEmpty ? ownerFallback : moneyOwner;
    final providerKey = session.provider.toLowerCase().trim();
    final providerLabel = switch (providerKey) {
      'taptap_send' => t.tipChannelElyonpay,
      'remitly' => t.tipChannelRemitly,
      'maxit_qr' => t.tipChannelMaxItQr,
      'maxit' => t.tipChannelMaxItQr,
      _ => session.provider.toUpperCase(),
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t.tipSelectedChannel,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(t.tipProviderLabel(providerLabel)),
            Text(t.tipIdLabel(session.tipId)),
            if (session.anonymous)
              Text(
                t.tipAnonymousModeEnabled,
                style: Theme.of(context).textTheme.labelMedium,
              ),
            if (moneyNumber.isNotEmpty || moneyOwner.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                t.tipDestinationOrangeMoneyCameroon,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              Text(t.tipRecipientNameLabel(ownerName)),
              if (moneyNumber.isNotEmpty)
                Text(
                  t.tipRecipientNumberLabel(moneyNumber),
                  style: Theme.of(context).textTheme.bodySmall,
                )
              else
                Text(
                  t.tipPhoneHiddenHint,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              if (!canShowMoneyNumber && moneyNumber.isNotEmpty)
                Text(
                  t.tipPhoneHiddenHint,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              if (fullMoneyNumber.isNotEmpty)
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () async {
                      await Clipboard.setData(
                        ClipboardData(text: fullMoneyNumber),
                      );
                      if (!context.mounted) return;
                      CamToast.show(
                        context,
                        message: t.copiedMessage(t.tipMsisdnLabel),
                      );
                    },
                    icon: const Icon(Icons.copy_all_outlined, size: 16),
                    label: Text(t.copyAction),
                  ),
                ),
              const SizedBox(height: 4),
              Text(t.tipVerifyRecipientNameHint),
            ],
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (onOpenCheckout != null)
                  FilledButton.icon(
                    onPressed: onOpenCheckout,
                    icon: const Icon(Icons.open_in_new),
                    label: Text(t.tipOpenPayment),
                  ),
                if (onOpenDeepLink != null)
                  OutlinedButton.icon(
                    onPressed: onOpenDeepLink,
                    icon: const Icon(Icons.phone_android),
                    label: Text(t.tipOpenMaxIt),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TipStatusPanel extends StatelessWidget {
  const _TipStatusPanel({super.key, required this.result, required this.t});

  final TipStatusResult result;
  final AppLocalizations t;

  @override
  Widget build(BuildContext context) {
    final success = result.isSuccess;
    final normalized = result.status.trim().toLowerCase();
    final isSubmitted = normalized == 'submitted';
    final statusLabel = success
        ? t.tipPaymentConfirmed
        : isSubmitted
        ? t.tipPaymentSubmitted
        : t.tipPaymentAwaitingConfirmation;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: success
              ? Theme.of(context).colorScheme.tertiary
              : Theme.of(context).colorScheme.outlineVariant,
        ),
        color: success
            ? Theme.of(context).colorScheme.tertiaryContainer.withAlpha(80)
            : Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest.withAlpha(80),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            statusLabel,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            t.tipStatusSummary(
              result.amount,
              result.currency,
              result.provider.toUpperCase(),
            ),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (isSubmitted && !success) ...[
            const SizedBox(height: 6),
            Text(t.tipSubmittedBody),
          ],
          if (result.receiptUrls.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              t.tipReceiptUploadedCount(result.receiptUrls.length),
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ],
          if (result.thankYouMessage != null &&
              result.thankYouMessage!.trim().isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(result.thankYouMessage!),
          ],
        ],
      ),
    );
  }
}

class _ImpactLine extends StatelessWidget {
  const _ImpactLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18),
        const SizedBox(width: 8),
        Expanded(child: Text(text)),
      ],
    );
  }
}

class _TipQrVisual extends StatelessWidget {
  const _TipQrVisual({required this.payload, required this.size});

  final String payload;
  final double size;

  @override
  Widget build(BuildContext context) {
    final trimmed = payload.trim();
    if (trimmed.toLowerCase().startsWith('asset:')) {
      final assetPath = trimmed.substring(6).trim();
      if (assetPath.isNotEmpty) {
        return _AssetQrImage(assetPath: assetPath, size: size);
      }
    }

    if (_isLikelyImageQrPayload(payload)) {
      return _NetworkQrImage(payload: payload, size: size);
    }

    return BrandedQrCode(data: payload, size: size, animatedFrame: true);
  }
}

class _AssetQrImage extends StatelessWidget {
  const _AssetQrImage({required this.assetPath, required this.size});

  final String assetPath;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CamVoteAnimatedQrFrame(
        size: size,
        child: ColoredBox(
          color: Colors.white,
          child: Image.asset(
            assetPath,
            width: (size - 16).clamp(48, size).toDouble(),
            height: (size - 16).clamp(48, size).toDouble(),
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
            errorBuilder: (_, error, stackTrace) => Center(
              child: Icon(
                Icons.broken_image_outlined,
                size: 28,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NetworkQrImage extends StatelessWidget {
  const _NetworkQrImage({required this.payload, required this.size});

  final String payload;
  final double size;

  @override
  Widget build(BuildContext context) {
    final uri = Uri.tryParse(payload.trim());
    final qrSize = (size - 16).clamp(48, size).toDouble();
    if (uri == null || (!uri.hasScheme && !uri.path.contains('.'))) {
      return BrandedQrCode(data: payload, size: size, animatedFrame: true);
    }
    return Center(
      child: CamVoteAnimatedQrFrame(
        size: size,
        child: ColoredBox(
          color: Colors.white,
          child: Image.network(
            uri.toString(),
            width: qrSize,
            height: qrSize,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
            errorBuilder: (_, error, stackTrace) =>
                BrandedQrCode(data: payload, size: size, animatedFrame: true),
          ),
        ),
      ),
    );
  }
}

String _maskPhoneNumber(String input) {
  final trimmed = input.trim();
  if (trimmed.isEmpty) return '';
  final digits = trimmed.replaceAll(RegExp(r'[^0-9]'), '');
  if (digits.isEmpty) return '';
  final keepStart = digits.length >= 3 ? 3 : 1;
  final keepEnd = digits.length >= 2 ? 2 : 1;
  final hiddenCountRaw = digits.length - keepStart - keepEnd;
  final hiddenCount = hiddenCountRaw > 0 ? hiddenCountRaw : 0;
  final start = digits.substring(0, keepStart);
  final end = digits.substring(digits.length - keepEnd);
  final hasPlusPrefix = trimmed.startsWith('+');
  final stars = hiddenCount == 0 ? '' : ('*' * hiddenCount);
  return '${hasPlusPrefix ? '+' : ''}$start$stars$end';
}

bool _isLikelyImageQrPayload(String value) {
  final raw = value.trim().toLowerCase();
  if (raw.isEmpty) return false;
  if (raw.startsWith('data:image/')) return true;
  if (!(raw.startsWith('http://') || raw.startsWith('https://'))) return false;
  return raw.endsWith('.png') ||
      raw.endsWith('.jpg') ||
      raw.endsWith('.jpeg') ||
      raw.endsWith('.webp') ||
      raw.contains('image') ||
      raw.contains('format=png') ||
      raw.contains('qr');
}

String _formatTipAmountLabel(int amount) {
  final digits = amount.toString();
  final out = StringBuffer();
  for (var i = 0; i < digits.length; i += 1) {
    out.write(digits[i]);
    final remaining = digits.length - i - 1;
    if (remaining > 0 && remaining % 3 == 0) {
      out.write(' ');
    }
  }
  return out.toString();
}
