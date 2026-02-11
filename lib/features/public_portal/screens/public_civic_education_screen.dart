import 'package:camvote/core/errors/error_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/branding/brand_backdrop.dart';
import '../../../core/branding/brand_header.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/motion/cam_reveal.dart';
import '../../../core/widgets/loaders/cameroon_election_loader.dart';
import '../../../core/widgets/sections/cam_section_header.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../notifications/widgets/notification_app_bar.dart';
import '../../tools/providers/tools_providers.dart';

class PublicCivicEducationScreen extends ConsumerWidget {
  const PublicCivicEducationScreen({super.key});

  Future<void> _openSource(BuildContext context, String url) async {
    if (url.trim().isEmpty) return;
    final uri = Uri.parse(url);
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).openLinkFailed)),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lessons = ref.watch(publicCivicEducationProvider);
    final t = AppLocalizations.of(context);

    return Scaffold(
      appBar: NotificationAppBar(title: Text(t.publicCivicEducationTitle)),
      body: BrandBackdrop(
        child: ResponsiveContent(
          child: lessons.when(
            loading: () => const Center(child: CamElectionLoader()),
            error: (e, _) =>
                Center(child: Text(safeErrorMessage(context, e))),
            data: (items) => ListView(
              padding: EdgeInsets.zero,
              children: [
                CamStagger(
                  children: [
                    const SizedBox(height: 6),
                    BrandHeader(
                      title: t.publicCivicEducationTitle,
                      subtitle: t.publicCivicEducationSubtitle,
                    ),
                    const SizedBox(height: 12),
                    CamSectionHeader(
                      title: t.publicCivicEducationTitle,
                      subtitle: t.publicCivicEducationSubtitle,
                      icon: Icons.school_outlined,
                    ),
                    const SizedBox(height: 6),
                    if (items.isEmpty)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(t.noData),
                        ),
                      )
                    else
                      ...items.map(
                        (item) => CamReveal(
                          child: Card(
                            child: ListTile(
                              leading: const Icon(Icons.school_outlined),
                              title: Text(
                                item.title,
                                style: Theme.of(
                                  context,
                                ).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                              subtitle: Text(item.summary),
                              trailing: const Icon(
                                Icons.open_in_new,
                                size: 18,
                              ),
                              onTap: () =>
                                  _openSource(context, item.sourceUrl),
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
      ),
    );
  }
}


