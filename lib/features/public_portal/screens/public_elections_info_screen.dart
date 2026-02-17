import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:camvote/gen/l10n/app_localizations.dart';
import 'package:camvote/core/errors/error_message.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/branding/brand_backdrop.dart';
import '../../../core/branding/brand_header.dart';
import '../../../core/widgets/loaders/cameroon_election_loader.dart';
import '../../../core/motion/cam_reveal.dart';
import '../../../core/utils/external_links.dart';
import '../../../core/widgets/sections/cam_section_header.dart';
import '../../notifications/widgets/notification_app_bar.dart';
import '../models/public_models.dart';
import '../providers/public_portal_providers.dart';

class PublicElectionsInfoScreen extends ConsumerWidget {
  const PublicElectionsInfoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final infoAsync = ref.watch(publicElectionsInfoProvider);
    final fallback = _fallbackInfo(t);

    return Scaffold(
      appBar: NotificationAppBar(title: Text(t.publicElectionsInfoTitle)),
      body: BrandBackdrop(
        child: ResponsiveContent(
          child: infoAsync.when(
            loading: () => const Center(child: CamElectionLoader()),
            error: (e, _) => _InfoView(info: fallback, error: e),
            data: (info) => _InfoView(info: info ?? fallback),
          ),
        ),
      ),
    );
  }
}

class _InfoView extends StatelessWidget {
  const _InfoView({required this.info, this.error});

  final PublicElectionsInfoState info;
  final Object? error;

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
    final dateFormat = DateFormat.yMMMd(t.localeName);
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        CamStagger(
          children: [
            const SizedBox(height: 6),
            BrandHeader(
              title: info.title.isEmpty
                  ? t.publicElectionsInfoTitle
                  : info.title,
              subtitle: info.subtitle.isEmpty
                  ? t.electionsInfoHeadline
                  : info.subtitle,
            ),
            const SizedBox(height: 14),
            if (info.lastUpdated != null)
              Align(
                alignment: Alignment.centerLeft,
                child: Chip(
                  label: Text(
                    '${t.lastUpdated}: ${dateFormat.format(info.lastUpdated!)}',
                  ),
                ),
              ),
            if (info.lastUpdated != null) const SizedBox(height: 10),
            if (error != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(safeErrorMessage(context, error)),
                ),
              ),
            ...info.sections.map(
              (section) => _InfoTile(
                title: section.title,
                body: section.body,
                sourceLabel: section.sourceLabel,
                sourceUrl: section.sourceUrl,
                onOpen: () => _openSource(context, section.sourceUrl),
              ),
            ),
            const SizedBox(height: 10),
            CamSectionHeader(
              title: t.guidelinesTitle,
              icon: Icons.rule_folder_outlined,
            ),
            const SizedBox(height: 4),
            ...info.guidelines.map(
              (g) => _Bullet(
                text: g.text,
                sourceLabel: g.sourceLabel,
                sourceUrl: g.sourceUrl,
                onOpen: () => _openSource(context, g.sourceUrl),
              ),
            ),
            const SizedBox(height: 18),
          ],
        ),
      ],
    );
  }
}

PublicElectionsInfoState _fallbackInfo(AppLocalizations t) {
  return PublicElectionsInfoState(
    title: t.publicElectionsInfoTitle,
    subtitle: t.electionsInfoHeadline,
    sections: [
      PublicElectionsInfoSection(
        id: 'presidential',
        title: t.electionTypePresidential,
        body: t.electionTypePresidentialBody,
        sourceUrl: t.legalSourceElecamUrl,
        sourceLabel: t.legalSourceElecamLabel,
      ),
      PublicElectionsInfoSection(
        id: 'legislative',
        title: t.electionTypeLegislative,
        body: t.electionTypeLegislativeBody,
        sourceUrl: t.legalSourceElecamUrl,
        sourceLabel: t.legalSourceElecamLabel,
      ),
      PublicElectionsInfoSection(
        id: 'municipal',
        title: t.electionTypeMunicipal,
        body: t.electionTypeMunicipalBody,
        sourceUrl: t.legalSourceElecamUrl,
        sourceLabel: t.legalSourceElecamLabel,
      ),
      PublicElectionsInfoSection(
        id: 'regional',
        title: t.electionTypeRegional,
        body: t.electionTypeRegionalBody,
        sourceUrl: t.legalSourceElecamUrl,
        sourceLabel: t.legalSourceElecamLabel,
      ),
      PublicElectionsInfoSection(
        id: 'senatorial',
        title: t.electionTypeSenatorial,
        body: t.electionTypeSenatorialBody,
        sourceUrl: t.legalSourceElecamUrl,
        sourceLabel: t.legalSourceElecamLabel,
      ),
    ],
    guidelines: [
      PublicElectionsInfoGuideline(
        text: t.guidelineAgeRules,
        sourceUrl: t.legalSourceElecamUrl,
        sourceLabel: t.legalSourceElecamLabel,
      ),
      PublicElectionsInfoGuideline(
        text: t.guidelineOnePersonOneVote,
        sourceUrl: t.legalSourceElecamUrl,
        sourceLabel: t.legalSourceElecamLabel,
      ),
      PublicElectionsInfoGuideline(
        text: t.guidelineSecrecy,
        sourceUrl: t.legalSourceElecamUrl,
        sourceLabel: t.legalSourceElecamLabel,
      ),
      PublicElectionsInfoGuideline(
        text: t.guidelineFraudReporting,
        sourceUrl: t.legalSourceElecamUrl,
        sourceLabel: t.legalSourceElecamLabel,
      ),
    ],
    lastUpdated: null,
  );
}

class _InfoTile extends StatelessWidget {
  final String title;
  final String body;
  final String sourceLabel;
  final String sourceUrl;
  final VoidCallback? onOpen;

  const _InfoTile({
    required this.title,
    required this.body,
    required this.sourceLabel,
    required this.sourceUrl,
    this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        title: Text(title),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          Text(body),
          if (sourceUrl.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: onOpen,
                icon: const Icon(Icons.link),
                label: Text(
                  sourceLabel.isEmpty
                      ? AppLocalizations.of(context).openWebsite
                      : sourceLabel,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  final String text;
  final String sourceLabel;
  final String sourceUrl;
  final VoidCallback? onOpen;
  const _Bullet({
    required this.text,
    required this.sourceLabel,
    required this.sourceUrl,
    this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 6),
                child: Icon(Icons.circle, size: 8),
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(text)),
            ],
          ),
          if (sourceUrl.trim().isNotEmpty)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: onOpen,
                icon: const Icon(Icons.link, size: 16),
                label: Text(sourceLabel.isEmpty ? t.openWebsite : sourceLabel),
              ),
            ),
        ],
      ),
    );
  }
}
