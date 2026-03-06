# kotlin-chapter2-essentials

Dedicated Chapter 2 repository (Functions/Collections + Classes/OOP) with all requested exercises and milestone demos.

## Contents

- `functions/FunctionExercises.kt`
  - Exercise 1: `processList(numbers, predicate)`
  - Exercise 2: word-length map + filter
  - Exercise 3: average age for names starting with `A`/`B`
- `classes/ClassExercises.kt`
  - Exercise 1: `Animal` hierarchy (`Dog`, `Cat`)
  - Exercise 2: sealed `NetworkState` + `handleState`
  - Exercise 3: `Drawable` interface (`Circle`, `Square`)
- `milestones/Milestone2_RomualdSIGNING.kt`
  - Data class functions, custom higher-order function, lambda, collection ops in `main`
- `milestones/Milestone3_RomualdSIGNING.kt`
  - OOP mini model with data class, interface, abstract class, inheritance, polymorphism

## Run

```bash
./gradlew run
```

## Run Individual Parts

```bash
./gradlew runFunctionsExercises
./gradlew runClassesExercises
./gradlew runMilestone2
./gradlew runMilestone3
```

## Notes

- Code is intentionally concise and null-safe.
- Functional operations (`map`, `filter`, `fold`, `associateWith`) are used throughout.
- Demos are console-ready for LMS submission screenshots.

