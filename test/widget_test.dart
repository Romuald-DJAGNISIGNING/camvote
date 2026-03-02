import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:student_gradecalc_dart/main.dart';

void main() {
  testWidgets('app boots', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: GradeCalcApp()));
    expect(find.text('Student Grade Calculator'), findsOneWidget);
  });
}
