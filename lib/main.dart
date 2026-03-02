import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/providers/grade_calculator_controller.dart';
import 'features/export/export_actions.dart';
import 'features/import/ui/import_panel.dart';
import 'features/results/ui/results_dashboard.dart';

void main() {
  runApp(const ProviderScope(child: GradeCalcApp()));
}

class GradeCalcApp extends StatelessWidget {
  const GradeCalcApp({super.key});

  @override
  Widget build(BuildContext context) {
    final base = ThemeData.light(useMaterial3: true);

    return MaterialApp(
      title: 'Student Grade Calculator (Dart)',
      debugShowCheckedModeBanner: false,
      theme: base.copyWith(
        textTheme: GoogleFonts.spaceGroteskTextTheme(base.textTheme),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0E5A8A),
          brightness: Brightness.light,
        ),
      ),
      home: const GradeCalcHomePage(),
    );
  }
}

class GradeCalcHomePage extends ConsumerWidget {
  const GradeCalcHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gradeCalculatorProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF09203F), Color(0xFF537895)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: -80,
                right: -40,
                child: Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.09),
                  ),
                ),
              ),
              SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _HeroHeader(),
                      const SizedBox(height: 20),
                      const ImportPanel(),
                      const SizedBox(height: 12),
                      const ExportActions(),
                      const SizedBox(height: 12),
                      const ResultsDashboard(),
                    ],
                  ),
                ),
              ),
              if (state.loading)
                Container(
                  color: Colors.black.withValues(alpha: 0.22),
                  child: const Center(child: CircularProgressIndicator()),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroHeader extends StatelessWidget {
  const _HeroHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Student Grade Calculator',
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Dart / Flutter Edition - fast offline processing, strong validation, polished workbook export.',
            style: TextStyle(color: Colors.white70, fontSize: 15),
          ),
        ],
      ),
    );
  }
}

