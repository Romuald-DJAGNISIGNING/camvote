import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/cam_theme.dart';
import 'core/widgets/buttons/cam_button.dart';
import 'core/widgets/cards/stat_card.dart';
import 'core/widgets/cards/candidate_card.dart';
import 'core/widgets/loaders/cam_election_loader.dart';
import 'core/constants/app_constants.dart';

void main() {
  runApp(const ProviderScope(child: CamVoteApp()));
}

class CamVoteApp extends StatelessWidget {
  const CamVoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CamVote',
      debugShowCheckedModeBanner: false,
      theme: CamTheme.lightTheme,
      home: const TestWidgetsScreen(),
    );
  }
}

class TestWidgetsScreen extends StatelessWidget {
  const TestWidgetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CamVote - Widget Test'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Display electoral law info
            Text(
              'Cameroon Electoral System',
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Registration Age: ${AppConstants.minimumRegistrationAge}+ | '
              'Voting Age: ${AppConstants.minimumVotingAge}+',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            
            // Stat Cards
            const StatCard(
              title: 'Total Registered Voters',
              value: '7,234,567',
              icon: Icons.how_to_vote,
            ),
            const SizedBox(height: 16),
            
            // Candidate Card
            CandidateCard(
              candidateName: 'Paul Biya',
              party: 'CPDM - Cameroon People\'s Democratic Movement',
              isSelected: true,
              onTap: () {},
            ),
            const SizedBox(height: 16),
            
            // Loader (in a container)
            const SizedBox(
              height: 150,
              child: CamElectionLoader(
                message: 'Loading election data...',
              ),
            ),
            const SizedBox(height: 16),
            
            // Button
            CamButton(
              label: 'All Widgets Working!',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ Block 1 Part 2 Complete!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}