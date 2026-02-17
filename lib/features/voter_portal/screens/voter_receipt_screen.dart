import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:camvote/gen/l10n/app_localizations.dart';

import '../../../shared/biometrics/biometric_gate.dart';
import '../../../shared/liveness/liveness_challenge_screen.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/branding/brand_backdrop.dart';
import '../../../core/branding/brand_header.dart';
import '../../../core/config/app_config.dart';
import '../../../core/motion/cam_reveal.dart';
import '../../../core/widgets/navigation/app_back_button.dart';
import '../../../core/widgets/qr/branded_qr_code.dart';
import '../domain/vote_receipt.dart';

class VoterReceiptScreen extends StatelessWidget {
  const VoterReceiptScreen({super.key, required this.receipt});

  final VoteReceipt receipt;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = AppLocalizations.of(context);
    final token = receipt.auditToken;
    final castAtLabel = _formatDateTime(context, receipt.castAt);

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: Text(t.voteReceiptTitle),
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
                    title: receipt.electionTitle,
                    subtitle: t.voteReceiptSubtitle,
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Stack(
                      children: [
                        if (AppConfig.hasReceiptWatermarkAsset)
                          Positioned(
                            right: 8,
                            top: 8,
                            child: Opacity(
                              opacity: 0.08,
                              child: Image.asset(
                                AppConfig.receiptWatermarkAsset,
                                width: 120,
                                height: 120,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) =>
                                    const SizedBox.shrink(),
                              ),
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                receipt.electionTitle,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text('${t.castAtLabel}: $castAtLabel'),
                              const SizedBox(height: 8),
                              Divider(color: theme.colorScheme.outlineVariant),
                              const SizedBox(height: 8),
                              _HashRow(
                                label: t.candidateHashLabel,
                                value: receipt.candidateHash,
                              ),
                              _HashRow(
                                label: t.partyHashLabel,
                                value: receipt.partyHash,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t.auditTokenLabel,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest
                                  .withAlpha(160),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: theme.colorScheme.outlineVariant
                                    .withAlpha(80),
                              ),
                            ),
                            child: SelectableText(
                              token,
                              style: theme.textTheme.bodyLarge,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Center(
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surface.withAlpha(245),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: theme.colorScheme.outlineVariant
                                      .withAlpha(90),
                                ),
                              ),
                              child: BrandedQrCode(
                                data: 'CAMVOTE_RECEIPT|$token',
                                size: 148,
                                logoScale: 0.16,
                                animatedFrame: true,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              SizedBox(
                                width: 180,
                                child: OutlinedButton.icon(
                                  onPressed: () async {
                                    final ok = await _confirmSensitive(context);
                                    if (!ok) return;
                                    await Clipboard.setData(
                                      ClipboardData(text: token),
                                    );
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(t.tokenCopied)),
                                    );
                                  },
                                  icon: const Icon(Icons.copy_rounded),
                                  label: Text(t.copyAction),
                                ),
                              ),
                              SizedBox(
                                width: 180,
                                child: FilledButton.icon(
                                  onPressed: () async {
                                    final ok = await _confirmSensitive(context);
                                    if (!ok) return;
                                    await SharePlus.instance.share(
                                      ShareParams(
                                        text: t.receiptShareMessage(token),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.share_outlined),
                                  label: Text(t.shareAction),
                                ),
                              ),
                              SizedBox(
                                width: 220,
                                child: FilledButton.icon(
                                  onPressed: () async {
                                    final ok = await _confirmSensitive(context);
                                    if (!ok) return;
                                    await Printing.layoutPdf(
                                      onLayout: (format) => _buildPdf(
                                        format,
                                        receipt,
                                        t,
                                        castAtLabel,
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.print_outlined),
                                  label: Text(t.printReceiptAction),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  CamReveal(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          t.receiptSafetyNote,
                          style: theme.textTheme.bodyMedium,
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

  Future<bool> _confirmSensitive(BuildContext context) async {
    final t = AppLocalizations.of(context);
    final bio = BiometricGate();
    final supported = await bio.isSupported();
    if (!supported) {
      if (!context.mounted) return false;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.biometricNotAvailable)));
      return false;
    }
    final bioOk = await bio.requireBiometric(reason: t.receiptBiometricReason);
    if (!bioOk) {
      if (!context.mounted) return false;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.biometricVerificationFailed)));
      return false;
    }

    if (!context.mounted) return false;
    final liveOk = await LivenessChallengeScreen.run(context);
    if (!liveOk) {
      if (!context.mounted) return false;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.livenessCheckFailed)));
      return false;
    }
    return true;
  }

  Future<Uint8List> _buildPdf(
    PdfPageFormat format,
    VoteReceipt receipt,
    AppLocalizations t,
    String castAtLabel,
  ) async {
    final doc = pw.Document();
    final watermark = await _loadWatermark();

    doc.addPage(
      pw.Page(
        pageFormat: format,
        build: (_) => pw.Stack(
          children: [
            if (watermark != null)
              pw.Positioned(
                right: 0,
                top: 0,
                child: pw.Opacity(
                  opacity: 0.08,
                  child: pw.Image(
                    watermark,
                    width: 140,
                    height: 140,
                    fit: pw.BoxFit.contain,
                  ),
                ),
              ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  t.receiptPdfTitle,
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 12),
                pw.Text('${t.electionLabel}: ${receipt.electionTitle}'),
                pw.Text('${t.castAtLabel}: $castAtLabel'),
                pw.SizedBox(height: 10),
                pw.Text('${t.candidateHashLabel}: ${receipt.candidateHash}'),
                pw.Text('${t.partyHashLabel}: ${receipt.partyHash}'),
                pw.SizedBox(height: 10),
                pw.Text('${t.auditTokenLabel}: ${receipt.auditToken}'),
                pw.SizedBox(height: 12),
                pw.Text(t.receiptPrivacyNote),
              ],
            ),
          ],
        ),
      ),
    );

    return doc.save();
  }

  Future<pw.ImageProvider?> _loadWatermark() async {
    if (!AppConfig.hasReceiptWatermarkAsset) return null;
    try {
      final data = await rootBundle.load(AppConfig.receiptWatermarkAsset);
      return pw.MemoryImage(data.buffer.asUint8List());
    } catch (_) {
      return null;
    }
  }

  String _formatDateTime(BuildContext context, DateTime value) {
    final date = MaterialLocalizations.of(context).formatMediumDate(value);
    final time = MaterialLocalizations.of(
      context,
    ).formatTimeOfDay(TimeOfDay.fromDateTime(value));
    return '$date $time';
  }
}

class _HashRow extends StatelessWidget {
  const _HashRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.onSurface.withAlpha(170),
              ),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
