# student-gradecalc-dart

Offline Flutter (Windows desktop) Student Grade Calculator with polished dashboard UI, CSV/XLSX import, robust grading logic, and styled Excel export.

## Features

- Import `.csv` and `.xlsx` datasets.
- Handles nullable/missing/incoherent marks with grade `X`.
- Auto score mode:
  - `CA<=30` and `Exam<=70` -> `CA + Exam`
  - Else if both `<=100` -> weighted `0.30*CA + 0.70*Exam`
  - Else fallback to valid `Total`.
- Grade scale:
  - `A>=85`, `B+>=80`, `B>=75`, `C+>=70`, `C>=65`, `D+>=60`, `D>=55`, else `F`
  - `X` for unknown/invalid data.
- Duplicate rule: keep latest row and log warning.
- Export workbook with sheets:
  - `Grades`
  - `Summary`
  - `Issues`
  - `ChartData`
- In-app grade distribution chart.

## Kotlin Lesson Principles Reflected

- Immutability-first (`final` by default)
- Null safety and safe defaults
- Expression-style grade mapping
- Data-focused model types
- Explicit edge-case handling with issue logs

## Run UI

```bash
flutter pub get
flutter run -d windows
```

## Run CLI

```bash
dart run bin/gradecalc_cli.dart --input samples/parity/input_students.csv --output build/exports/grades.xlsx
```

## Test

```bash
flutter test
```

## Sample Data

Use files in [`samples/parity`](samples/parity) and [`samples/edge_cases.csv`](samples/edge_cases.csv).

## Public Core Contract

- `StudentInputRow`
- `NormalizedStudent`
- `GradeResult`
- `ValidationIssue`
- `ProcessingReport`
- Services: `FileImportService`, `GradingEngine`, `WorkbookExportService`, `ChartDataBuilder`
