import 'package:camvote/features/about_me/models/trello_stats.dart';
import 'package:camvote/features/about_me/widgets/trello_dashboard_card.dart';
import 'package:camvote/gen/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  TrelloStats sampleStats() {
    return TrelloStats(
      boardName: 'CamVote Roadmap',
      boardUrl: 'https://trello.com/b/camvote',
      lastActivityAt: DateTime(2026, 2, 18, 4, 40),
      totalCards: 42,
      openCards: 18,
      doneCards: 24,
      lists: const [
        TrelloListStat(name: 'List 1', totalCards: 12, openCards: 9),
        TrelloListStat(name: 'List 2', totalCards: 11, openCards: 8),
        TrelloListStat(name: 'List 3', totalCards: 10, openCards: 7),
        TrelloListStat(name: 'List 4', totalCards: 9, openCards: 6),
        TrelloListStat(name: 'List 5', totalCards: 8, openCards: 5),
        TrelloListStat(name: 'List 6', totalCards: 7, openCards: 3),
        TrelloListStat(name: 'List 7', totalCards: 6, openCards: 2),
      ],
    );
  }

  Future<void> pumpCard(WidgetTester tester, TrelloStats stats) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: TrelloDashboardCard(stats: stats),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows KPI stats and top lists, then expands all lists', (
    tester,
  ) async {
    await pumpCard(tester, sampleStats());

    expect(find.text('CamVote Roadmap'), findsOneWidget);
    expect(find.text('Total'), findsOneWidget);
    expect(find.text('Open'), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);

    expect(find.text('List 1'), findsOneWidget);
    expect(find.text('List 5'), findsOneWidget);
    expect(find.text('List 6'), findsNothing);
    expect(find.text('List 7'), findsNothing);

    await tester.tap(find.text('Show all'));
    await tester.pumpAndSettle();

    expect(find.text('List 6'), findsOneWidget);
    expect(find.text('List 7'), findsOneWidget);
    expect(find.text('Show top'), findsOneWidget);
  });
}
