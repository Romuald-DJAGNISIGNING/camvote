import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../gen/l10n/app_localizations.dart';
import '../../notifications/widgets/notification_app_bar.dart';
import '../providers/voter_portal_providers.dart';
import 'voter_elections_screen.dart';
import 'voter_home_screen.dart';
import 'voter_profile_screen.dart';
import 'voter_results_screen.dart';
import 'voter_vote_screen.dart';

class VoterShell extends ConsumerWidget {
  const VoterShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final index = ref.watch(voterTabIndexProvider);

    final pages = const <Widget>[
      VoterHomeScreen(),
      VoterElectionsScreen(),
      VoterVoteScreen(),
      VoterResultsScreen(),
      VoterProfileScreen(),
    ];

    return Scaffold(
      appBar: NotificationAppBar(title: Text(l10n.voterPortalTitle)),
      body: pages[index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) =>
            ref.read(voterTabIndexProvider.notifier).setIndex(i),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: l10n.voterHome,
          ),
          NavigationDestination(
            icon: const Icon(Icons.ballot_outlined),
            selectedIcon: const Icon(Icons.ballot),
            label: l10n.voterElections,
          ),
          NavigationDestination(
            icon: const Icon(Icons.how_to_vote_outlined),
            selectedIcon: const Icon(Icons.how_to_vote),
            label: l10n.voterVote,
          ),
          NavigationDestination(
            icon: const Icon(Icons.query_stats_outlined),
            selectedIcon: const Icon(Icons.query_stats),
            label: l10n.voterResults,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person),
            label: l10n.voterProfile,
          ),
        ],
      ),
    );
  }
}
