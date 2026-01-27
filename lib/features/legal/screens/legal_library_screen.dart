import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/branding/brand_backdrop.dart';
import '../../../core/branding/brand_header.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/motion/cam_reveal.dart';
import '../../../core/routing/route_paths.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../notifications/widgets/notification_app_bar.dart';
import '../models/legal_document.dart';

class LegalLibraryScreen extends StatelessWidget {
  const LegalLibraryScreen({super.key});

  Future<void> _openUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    final ok = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).openLinkFailed)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final docs = [
      LegalDocument(
        id: 'electoral_code_en',
        title: t.legalElectoralCodeTitle,
        subtitle: t.legalDocumentSubtitle(t.languageEnglish),
        assetPath: 'assets/laws/electoral_code_en.txt',
        sourceUrl:
            'https://portail.elecam.cm/download/electoral-code-2/',
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

    return Scaffold(
      appBar: NotificationAppBar(title: Text(t.legalHubTitle)),
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
                    title: t.legalHubTitle,
                    subtitle: t.legalHubSubtitle,
                  ),
                  const SizedBox(height: 12),
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
                          subtitle: const Text('https://portail.elecam.cm'),
                          trailing: TextButton(
                            onPressed: () =>
                                _openUrl(context, 'https://portail.elecam.cm'),
                            child: Text(t.openWebsite),
                          ),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.link),
                          title: Text(t.legalSourceAssnatLabel),
                          subtitle: const Text('https://www.assnat.cm'),
                          trailing: TextButton(
                            onPressed: () =>
                                _openUrl(context, 'https://www.assnat.cm'),
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
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push(
                          RoutePaths.legalDocument,
                          extra: doc,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
