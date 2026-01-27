import 'package:flutter/material.dart';
import 'package:camvote/gen/l10n/app_localizations.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/branding/brand_backdrop.dart';
import '../../../core/branding/brand_header.dart';
import '../../notifications/widgets/notification_app_bar.dart';

class PublicElectionsInfoScreen extends StatelessWidget {
  const PublicElectionsInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return Scaffold(
      appBar: NotificationAppBar(title: Text(t.publicElectionsInfoTitle)),
      body: BrandBackdrop(
        child: ResponsiveContent(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const SizedBox(height: 6),
              BrandHeader(
                title: t.publicElectionsInfoTitle,
                subtitle: t.electionsInfoHeadline,
              ),
              const SizedBox(height: 14),
              _InfoTile(
                title: t.electionTypePresidential,
                body: t.electionTypePresidentialBody,
              ),
              _InfoTile(
                title: t.electionTypeLegislative,
                body: t.electionTypeLegislativeBody,
              ),
              _InfoTile(
                title: t.electionTypeMunicipal,
                body: t.electionTypeMunicipalBody,
              ),
              _InfoTile(
                title: t.electionTypeRegional,
                body: t.electionTypeRegionalBody,
              ),
              _InfoTile(
                title: t.electionTypeSenatorial,
                body: t.electionTypeSenatorialBody,
              ),
              const SizedBox(height: 14),
              Text(
                t.guidelinesTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              _Bullet(text: t.guidelineAgeRules),
              _Bullet(text: t.guidelineOnePersonOneVote),
              _Bullet(text: t.guidelineSecrecy),
              _Bullet(text: t.guidelineFraudReporting),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String title;
  final String body;

  const _InfoTile({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        title: Text(title),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [Text(body)],
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  final String text;
  const _Bullet({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
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
    );
  }
}
