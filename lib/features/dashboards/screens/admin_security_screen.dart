import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/branding/brand_backdrop.dart';
import '../../../core/branding/brand_header.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/widgets/loaders/cameroon_election_loader.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../notifications/widgets/notification_app_bar.dart';
import '../../tools/providers/tools_providers.dart';

class AdminSecurityScreen extends ConsumerWidget {
  const AdminSecurityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final risks = ref.watch(adminDeviceRisksProvider);
    final t = AppLocalizations.of(context);

    return Scaffold(
      appBar: NotificationAppBar(title: Text(t.adminSecurityTitle)),
      body: BrandBackdrop(
        child: ResponsiveContent(
          child: risks.when(
            loading: () => const Center(child: CamElectionLoader()),
            error: (e, _) => Center(child: Text(t.errorWithDetails(e.toString()))),
            data: (items) => ListView(
              padding: EdgeInsets.zero,
              children: [
                const SizedBox(height: 6),
                BrandHeader(
                  title: t.adminSecurityTitle,
                  subtitle: t.adminSecuritySubtitle,
                ),
                const SizedBox(height: 12),
                if (items.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(t.noData),
                    ),
                  )
                else
                  ...items.map(
                    (item) => Card(
                      child: ListTile(
                        leading: const Icon(Icons.privacy_tip_outlined),
                        title: Text(item.label.isEmpty ? item.deviceId : item.label),
                        subtitle: Text(item.reason),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              t.securityStrikesLabel(item.strikes),
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                            Text(
                              item.status,
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
