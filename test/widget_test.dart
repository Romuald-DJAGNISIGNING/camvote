import 'package:camvote/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('CamVote app boots', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: CamVoteApp()));
    await tester.pump();
    // Let bootstrap timeout guards complete to avoid pending-timer failures.
    await tester.pump(const Duration(seconds: 6));
    await tester.pumpAndSettle();

    expect(find.byType(MaterialApp), findsWidgets);
  });
}
