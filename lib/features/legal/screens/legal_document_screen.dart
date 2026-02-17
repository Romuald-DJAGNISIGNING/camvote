import 'package:camvote/core/errors/error_message.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/branding/brand_backdrop.dart';
import '../../../core/branding/brand_header.dart';
import '../../../core/config/app_config.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/motion/cam_reveal.dart';
import '../../../core/utils/external_links.dart';
import '../../../core/widgets/sections/cam_section_header.dart';
import '../../../core/widgets/loaders/cameroon_election_loader.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../notifications/widgets/notification_app_bar.dart';
import '../models/legal_document.dart';

class LegalDocumentScreen extends StatefulWidget {
  const LegalDocumentScreen({super.key, required this.document});

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
    _contentFuture = _resolveContent();
  }

  Future<String> _resolveContent() async {
    if (widget.document.hasInlineContent) {
      return widget.document.content!.trim();
    }
    final path = widget.document.assetPath;
    if (path == null || path.trim().isEmpty) return '';
    return _loadDocument(path);
  }

  Future<String> _loadDocument(String assetPath) async {
    final data = await rootBundle.load(assetPath);
    final bytes = data.buffer.asUint8List();
    try {
      return utf8.decode(bytes);
    } catch (_) {
      return latin1.decode(bytes, allowInvalid: true);
    }
  }

  Future<void> _openSource(BuildContext context, String url) async {
    final ok = await openExternalLink(context, url, showError: false);
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
                  child: Text(safeErrorMessage(context, snapshot.error)),
                );
              }
              final content = snapshot.data ?? '';
              if (content.trim().isEmpty) {
                return Center(child: Text(t.missingDocumentData));
              }
              final blocks = _parseBlocks(content);
              final query = _query.trim().toLowerCase();
              final results = query.isEmpty
                  ? blocks
                  : blocks.where((b) => b.searchText.contains(query)).toList();

              return ListView(
                padding: EdgeInsets.zero,
                children: [
                  CamStagger(
                    children: [
                      const SizedBox(height: 6),
                      BrandHeader(
                        title: widget.document.title,
                        subtitle: widget.document.subtitle,
                      ),
                      const SizedBox(height: 12),
                      if (widget.document.sourceUrl.trim().isNotEmpty)
                        Card(
                          child: ListTile(
                            leading: const Icon(Icons.language_outlined),
                            title: Text(widget.document.sourceLabel),
                            subtitle: Text(widget.document.sourceUrl),
                            trailing: TextButton(
                              onPressed: () => _openSource(
                                context,
                                widget.document.sourceUrl,
                              ),
                              child: Text(t.openWebsite),
                            ),
                          ),
                        ),
                      if (widget.document.sourceUrl.trim().isNotEmpty)
                        const SizedBox(height: 12),
                      TextField(
                        onChanged: (value) => setState(() => _query = value),
                        textInputAction: TextInputAction.search,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.search),
                          hintText: t.legalSearchHint,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (query.isNotEmpty) ...[
                        CamSectionHeader(
                          title: t.legalSearchResults(results.length),
                          icon: Icons.search,
                        ),
                        if (results.isEmpty)
                          _EmptyState(message: t.legalSearchEmpty)
                        else
                          ...results.map(
                            (block) => _WatermarkedCard(
                              child: _BlockBody(
                                block: block,
                                onOpen: _openSource,
                              ),
                            ),
                          ),
                      ] else
                        _WatermarkedCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: _buildBlocks(
                              context,
                              t,
                              blocks,
                              onOpen: _openSource,
                            ),
                          ),
                        ),
                      const SizedBox(height: 18),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  List<_DocBlock> _parseBlocks(String text) {
    final lines = text.split(RegExp(r'\r?\n'));
    final blocks = <_DocBlock>[];
    final urlRegex = RegExp(r'(https?://\S+)');

    bool titleAdded = false;
    _DocBlock? last;

    for (final rawLine in lines) {
      final trimmed = rawLine.trim();
      if (trimmed.isEmpty) {
        last = null;
        continue;
      }

      if (!titleAdded) {
        blocks.add(_DocBlock(type: _DocBlockType.title, text: trimmed));
        titleAdded = true;
        last = blocks.last;
        continue;
      }

      if (_isHeading(trimmed)) {
        final text = trimmed.replaceAll(RegExp(r':$'), '').trim();
        blocks.add(_DocBlock(type: _DocBlockType.heading, text: text));
        last = blocks.last;
        continue;
      }

      final numberedMatch = RegExp(r'^\d+\)\s*(.*)$').firstMatch(trimmed);
      if (numberedMatch != null) {
        final text = numberedMatch.group(1)?.trim() ?? '';
        blocks.add(_DocBlock(type: _DocBlockType.subheading, text: text));
        last = blocks.last;
        continue;
      }

      if (trimmed.startsWith('-') || trimmed.startsWith('•')) {
        var bulletText = trimmed.substring(1).trim();
        String? url;
        final match = urlRegex.firstMatch(bulletText);
        if (match != null) {
          url = match.group(1);
          bulletText = bulletText.replaceAll(url!, '').trim();
          bulletText = bulletText.replaceAll(RegExp(r':$'), '').trim();
        }
        final block = _DocBlock(
          type: _DocBlockType.bullet,
          text: bulletText,
          url: url,
        );
        blocks.add(block);
        last = block;
        continue;
      }

      if (last != null &&
          (last.type == _DocBlockType.paragraph ||
              last.type == _DocBlockType.bullet)) {
        last.text = '${last.text} $trimmed'.trim();
        continue;
      }

      blocks.add(_DocBlock(type: _DocBlockType.paragraph, text: trimmed));
      last = blocks.last;
    }

    return blocks;
  }

  bool _isHeading(String text) => text.endsWith(':') && text.length <= 32;

  List<Widget> _buildBlocks(
    BuildContext context,
    AppLocalizations t,
    List<_DocBlock> blocks, {
    required Future<void> Function(BuildContext, String) onOpen,
  }) {
    final widgets = <Widget>[];
    for (final block in blocks) {
      final top = switch (block.type) {
        _DocBlockType.title => 0.0,
        _DocBlockType.heading => 18.0,
        _DocBlockType.subheading => 12.0,
        _DocBlockType.paragraph => 8.0,
        _DocBlockType.bullet => 6.0,
      };
      if (widgets.isNotEmpty) {
        widgets.add(SizedBox(height: top));
      }
      widgets.add(_BlockBody(block: block, onOpen: onOpen));
    }
    return widgets;
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

enum _DocBlockType { title, heading, subheading, paragraph, bullet }

class _DocBlock {
  _DocBlock({required this.type, required this.text, this.url});

  final _DocBlockType type;
  String text;
  final String? url;

  String get searchText => '${text.toLowerCase()} ${(url ?? '').toLowerCase()}';
}

class _WatermarkedCard extends StatelessWidget {
  const _WatermarkedCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final watermark = AppConfig.receiptWatermarkAsset;
    final showWatermark = watermark.trim().isNotEmpty;
    final cs = Theme.of(context).colorScheme;

    return Card(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      cs.surfaceContainerHighest.withAlpha(120),
                      cs.surface.withAlpha(0),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            if (showWatermark)
              Positioned.fill(
                child: IgnorePointer(
                  child: Opacity(
                    opacity: 0.06,
                    child: Padding(
                      padding: const EdgeInsets.all(28),
                      child: Image.asset(
                        watermark,
                        fit: BoxFit.contain,
                        color: cs.onSurface.withAlpha(64),
                        colorBlendMode: BlendMode.srcIn,
                        errorBuilder: (context, error, stackTrace) =>
                            const SizedBox.shrink(),
                      ),
                    ),
                  ),
                ),
              ),
            Padding(padding: const EdgeInsets.all(16), child: child),
          ],
        ),
      ),
    );
  }
}

class _BlockBody extends StatelessWidget {
  const _BlockBody({required this.block, required this.onOpen});

  final _DocBlock block;
  final Future<void> Function(BuildContext, String) onOpen;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    switch (block.type) {
      case _DocBlockType.title:
        return Text(
          block.text,
          style: theme.textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.w800,
            height: 1.15,
          ),
        );
      case _DocBlockType.heading:
        return Row(
          children: [
            Text(
              block.text.toUpperCase(),
              style: theme.textTheme.titleSmall?.copyWith(
                letterSpacing: 1.1,
                color: cs.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(height: 1, color: cs.primary.withAlpha(64)),
            ),
          ],
        );
      case _DocBlockType.subheading:
        return Text(
          block.text,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: cs.onSurface.withAlpha(200),
          ),
        );
      case _DocBlockType.paragraph:
        return SelectableText(
          block.text,
          textAlign: TextAlign.justify,
          style: theme.textTheme.bodyLarge?.copyWith(
            height: 1.65,
            color: cs.onSurface.withAlpha(210),
          ),
        );
      case _DocBlockType.bullet:
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                color: cs.primary,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SelectableText(
                    block.text,
                    textAlign: TextAlign.justify,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      height: 1.6,
                      color: cs.onSurface.withAlpha(210),
                    ),
                  ),
                  if (block.url != null && block.url!.isNotEmpty)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        style: TextButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                        ),
                        onPressed: () => onOpen(context, block.url!),
                        icon: const Icon(Icons.open_in_new, size: 16),
                        label: Text(t.openWebsite),
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
    }
  }
}
