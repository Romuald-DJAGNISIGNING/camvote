import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/branding/brand_backdrop.dart';
import '../../../core/branding/brand_header.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/widgets/loaders/cameroon_election_loader.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../notifications/widgets/notification_app_bar.dart';
import '../models/legal_document.dart';

class LegalDocumentScreen extends StatefulWidget {
  const LegalDocumentScreen({
    super.key,
    required this.document,
  });

  final LegalDocument document;

  @override
  State<LegalDocumentScreen> createState() => _LegalDocumentScreenState();
}

class _LegalDocumentScreenState extends State<LegalDocumentScreen> {
  late Future<String> _contentFuture;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _contentFuture = rootBundle.loadString(widget.document.assetPath);
  }

  Future<void> _openSource(BuildContext context, String url) async {
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

    return Scaffold(
      appBar: NotificationAppBar(title: Text(widget.document.title)),
      body: BrandBackdrop(
        child: ResponsiveContent(
          child: FutureBuilder<String>(
            future: _contentFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CamElectionLoader());
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    t.errorWithDetails(snapshot.error.toString()),
                  ),
                );
              }
              final content = snapshot.data ?? '';
              final paragraphs = _splitParagraphs(content);
              final query = _query.trim().toLowerCase();
              final results = query.isEmpty
                  ? paragraphs
                  : paragraphs
                      .where(
                        (p) => p.toLowerCase().contains(query),
                      )
                      .toList();

              return ListView(
                padding: EdgeInsets.zero,
                children: [
                  const SizedBox(height: 6),
                  BrandHeader(
                    title: widget.document.title,
                    subtitle: widget.document.subtitle,
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.language_outlined),
                      title: Text(widget.document.sourceLabel),
                      subtitle: Text(widget.document.sourceUrl),
                      trailing: TextButton(
                        onPressed: () =>
                            _openSource(context, widget.document.sourceUrl),
                        child: Text(t.openWebsite),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    onChanged: (value) =>
                        setState(() => _query = value),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: t.legalSearchHint,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (query.isNotEmpty) ...[
                    Text(
                      t.legalSearchResults(results.length),
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    if (results.isEmpty)
                      _EmptyState(message: t.legalSearchEmpty)
                    else
                      ...results.map(
                        (p) => Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(p),
                          ),
                        ),
                      ),
                  ] else
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: SelectableText(
                          content,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(height: 1.4),
                        ),
                      ),
                    ),
                  const SizedBox(height: 18),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  List<String> _splitParagraphs(String text) {
    return text
        .split(RegExp(r'\n{2,}'))
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .toList();
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.search_off),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }
}
