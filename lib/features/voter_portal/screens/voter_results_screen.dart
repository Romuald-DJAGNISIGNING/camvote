import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/loaders/cameroon_election_loader.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../domain/election.dart';
import '../providers/voter_portal_providers.dart';
import '../domain/vote_receipt.dart';
import 'voter_receipt_screen.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/branding/brand_backdrop.dart';
import '../../../core/branding/brand_header.dart';

class VoterResultsScreen extends ConsumerWidget {
  const VoterResultsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final electionsAsync = ref.watch(voterElectionsProvider);
    final receipts = ref.watch(voteReceiptsProvider);

    return electionsAsync.when(
      loading: () => const Center(child: CamElectionLoader()),
      error: (e, _) => Center(child: Text(t.errorWithDetails(e.toString()))),
      data: (elections) {
        final closed = elections.where((e) => e.status == ElectionStatus.closed);
        final open = elections.where((e) => e.status == ElectionStatus.open);

        return BrandBackdrop(
          child: ResponsiveContent(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const SizedBox(height: 6),
                BrandHeader(
                  title: t.voterResults,
                  subtitle: t.voterResultsSubtitle,
                ),
                const SizedBox(height: 12),
                if (open.isNotEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(t.resultsPublicPortalNote),
                    ),
                  ),
                const SizedBox(height: 12),
                Text(
                  t.pastElectionsTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                if (closed.isEmpty)
                  Text(t.noClosedElections)
                else
                  ...closed.map((e) => Card(
                        child: ListTile(
                          leading: const Icon(Icons.history),
                          title: Text(e.title),
                          subtitle:
                              Text('${t.electionStatusClosed} • ${e.scopeLabel}'),
                        ),
                      )),
                const SizedBox(height: 16),
                Text(
                  t.yourReceiptsTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                if (receipts.isEmpty)
                  Text(t.noReceiptsYet)
                else
                  ...receipts.map((r) => _ReceiptTile(receipt: r)),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ReceiptTile extends StatelessWidget {
  final VoteReceipt receipt;
  const _ReceiptTile({required this.receipt});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final shortToken = receipt.auditToken.substring(0, 12);
    return Card(
      child: ListTile(
        leading: const Icon(Icons.receipt_long_outlined),
        title: Text(receipt.electionTitle),
        subtitle: Text(t.auditTokenShortLabel('$shortToken...')),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => VoterReceiptScreen(receipt: receipt),
          ),
        ),
      ),
    );
  }
}
