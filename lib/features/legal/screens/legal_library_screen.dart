import 'package:camvote/core/errors/error_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/branding/brand_backdrop.dart';
import '../../../core/branding/brand_header.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/motion/cam_reveal.dart';
import '../../../core/routing/route_paths.dart';
import '../../../core/widgets/loaders/cameroon_election_loader.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../notifications/widgets/notification_app_bar.dart';
import '../models/legal_document.dart';
import '../providers/legal_providers.dart';

class LegalLibraryScreen extends ConsumerWidget {
  const LegalLibraryScreen({super.key});

  Future<void> _openUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).openLinkFailed)),
      );
    }
  }

  List<LegalDocument> _fallbackDocs(AppLocalizations t) {
    return [
      LegalDocument(
        id: 'electoral_code_en',
        title: t.legalElectoralCodeTitle,
        subtitle: t.legalDocumentSubtitle(t.languageEnglish),
        assetPath: 'assets/laws/electoral_code_en.txt',
        sourceUrl: 'https://portail.elecam.cm/download/electoral-code-2/',
        sourceLabel: t.legalSourceElecamLabel,
        languageCode: 'en',
      ),
      LegalDocument(
        id: 'electoral_code_fr',
        title: t.legalElectoralCodeTitle,
        subtitle: t.legalDocumentSubtitle(t.languageFrench),
        assetPath: 'assets/laws/electoral_code_fr.txt',
        sourceUrl: 'https://portail.elecam.cm/download/code-electoral/',
        sourceLabel: t.legalSourceElecamLabel,
        languageCode: 'fr',
      ),
    ];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final docsAsync = ref.watch(legalDocumentsProvider);

    return Scaffold(
      appBar: NotificationAppBar(title: Text(t.legalHubTitle)),
      body: BrandBackdrop(
        child: ResponsiveContent(
          child: docsAsync.when(
            loading: () => const Center(child: CamElectionLoader()),
            error: (e, _) => _buildContent(
              context,
              t,
              docs: _fallbackDocs(t),
              error: e,
            ),
            data: (docs) {
              final resolved = docs.isEmpty ? _fallbackDocs(t) : docs;
              return _buildContent(
                context,
                t,
                docs: resolved,
                showFallbackNote: docs.isEmpty,
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    AppLocalizations t, {
    required List<LegalDocument> docs,
    Object? error,
    bool showFallbackNote = false,
  }) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        CamStagger(
          padding: EdgeInsets.zero,
          children: [
            const SizedBox(height: 6),
            BrandHeader(title: t.legalHubTitle, subtitle: t.legalHubSubtitle),
            const SizedBox(height: 12),
            if (error != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(safeErrorMessage(context, error)),
                ),
              ),
            if (error != null) const SizedBox(height: 12),
            if (showFallbackNote)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(t.missingDocumentData),
                ),
              ),
            if (showFallbackNote) const SizedBox(height: 12),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.account_balance_outlined),
                    title: Text(t.legalSourcesTitle),
                    subtitle: Text(t.legalSourcesSubtitle),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.link),
                    title: Text(t.legalSourceElecamLabel),
                    subtitle: Text(t.legalSourceElecamUrl),
                    trailing: TextButton(
                      onPressed: () =>
                          _openUrl(context, t.legalSourceElecamUrl),
                      child: Text(t.openWebsite),
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.link),
                    title: Text(t.legalSourceAssnatLabel),
                    subtitle: Text(t.legalSourceAssnatUrl),
                    trailing: TextButton(
                      onPressed: () =>
                          _openUrl(context, t.legalSourceAssnatUrl),
                      child: Text(t.openWebsite),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ...docs.map(
              (doc) => Card(
                child: ListTile(
                  leading: const Icon(Icons.menu_book_outlined),
                  title: Text(doc.title),
                  subtitle: Text(doc.subtitle),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Chip(
                        label: Text(doc.languageCode.toUpperCase()),
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                  onTap: () =>
                      context.push(RoutePaths.legalDocument, extra: doc),
                ),
              ),
            ),
            const SizedBox(height: 18),
          ],
        ),
      ],
    );
  }
}


