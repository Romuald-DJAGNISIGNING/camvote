enum LetterGrade { a, bPlus, b, cPlus, c, dPlus, d, f, x }

extension LetterGradeX on LetterGrade {
  String get label => switch (this) {
        LetterGrade.a => 'A',
        LetterGrade.bPlus => 'B+',
        LetterGrade.b => 'B',
        LetterGrade.cPlus => 'C+',
        LetterGrade.c => 'C',
        LetterGrade.dPlus => 'D+',
        LetterGrade.d => 'D',
        LetterGrade.f => 'F',
        LetterGrade.x => 'X',
      };
}

class GradeBand {
  const GradeBand({required this.letter, required this.minimumScore});

  final LetterGrade letter;
  final double minimumScore;
}

class GradingConfig {
  const GradingConfig({
    required this.caWeight,
    required this.examWeight,
    required this.passCutoff,
    required this.gradeBands,
    this.caMaxRaw = 30,
    this.examMaxRaw = 70,
    this.maxPercent = 100,
  });

  final double caWeight;
  final double examWeight;
  final double passCutoff;
  final List<GradeBand> gradeBands;
  final double caMaxRaw;
  final double examMaxRaw;
  final double maxPercent;

  static const strictDefault = GradingConfig(
    caWeight: 0.30,
    examWeight: 0.70,
    passCutoff: 65,
    gradeBands: [
      GradeBand(letter: LetterGrade.a, minimumScore: 85),
      GradeBand(letter: LetterGrade.bPlus, minimumScore: 80),
      GradeBand(letter: LetterGrade.b, minimumScore: 75),
      GradeBand(letter: LetterGrade.cPlus, minimumScore: 70),
      GradeBand(letter: LetterGrade.c, minimumScore: 65),
      GradeBand(letter: LetterGrade.dPlus, minimumScore: 60),
      GradeBand(letter: LetterGrade.d, minimumScore: 55),
      GradeBand(letter: LetterGrade.f, minimumScore: 0),
    ],
  );

  LetterGrade letterForScore(double? score, {required bool unknown}) {
    if (unknown || score == null) {
      return LetterGrade.x;
    }
    for (final band in gradeBands) {
      if (score >= band.minimumScore) {
        return band.letter;
      }
    }
    return LetterGrade.f;
  }
}
