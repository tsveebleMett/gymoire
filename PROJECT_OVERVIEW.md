# Project Overview

Hamstrong is a Flutter app (Android, iOS) for logging gym workouts and body weight, with a hamster mascot. It uses the same stack and conventions as Tempino: Flutter with `material_ui`, a pure Dart domain layer, painted illustrations instead of image assets, German UI strings.

## Architecture

| Layer | Path | Responsibility |
|---|---|---|
| Entry point | `lib/main.dart` | Opens `TrainingRepository` on a `FileTrainingStore` and starts `HamstrongApp`. Portrait only. |
| App shell | `lib/app.dart` | Theme, German locale, `HomeShell` with three tabs (Heute, Kalender, Gewicht) that rebuild on every repository change. |
| Domain | `lib/domain/` | `models.dart` (Exercise, LoggedSet, BodyWeight), `exercise_catalog.dart` (built-in exercises and search), `training_day.dart` (grouping a day's sets, week start, streak), `mascot.dart` (Hammy's mood and message). Pure Dart, no Flutter imports. |
| Data | `lib/data/` | `TrainingRepository` (a `ChangeNotifier` holding custom exercises, sets and body weights) and `TrainingStore` (`FileTrainingStore` for the app, `MemoryTrainingStore` for tests). |
| UI | `lib/ui/` | Today (`today_screen.dart`), calendar (`calendar_screen.dart`), body weight with chart (`weight_screen.dart`), a day's workout shared by today and the calendar (`day_log.dart`), exercise search (`exercise_picker.dart`), set entry (`set_sheet.dart`), number field with plus/minus (`number_stepper.dart`), the mascot (`hammy.dart`), colors and component styles (`theme.dart`), German date and number formatting (`format.dart`). |
| Assets | `assets/fonts/` | Nunito (body) and Fredoka (headings, buttons) variable fonts, both SIL Open Font License (`OFL-*.txt`). |

A clock function (`DateTime Function()`) is passed to `TrainingRepository.open`; the UI reads the time through `repository.now()`, so tests control time.

## Data model

There is no workout object: all sets of a calendar day form that day's workout. This keeps logging a single action and lets the calendar complete past days.

| Type | Fields |
|---|---|
| `Exercise` | `id`, `name`, `muscleGroup`, `custom`. Catalog ids are stable because sets refer to them; custom exercises get generated ids and are persisted. |
| `LoggedSet` | `id`, `exerciseId`, `weightKg` (0 for bodyweight exercises), `reps`, `at`. A set logged for a past day is placed at 18:00, or 3 minutes after that day's last set. |
| `BodyWeight` | `day` (local midnight), `kg`. One value per day; a new value replaces it. |

Storage: one JSON file `hamstrong.json` in the app documents directory, rewritten on every change. Writes are chained so an older snapshot never overwrites a newer one, and go to a `.tmp` file first that is then renamed.

## Hammy

`hammyFor` (`lib/domain/mascot.dart`) decides mood and message, in this order:

1. Sets today: proud, with the number of sets and the moved volume.
2. Four or more training days in a row (ending today or yesterday): resting, suggests a rest day.
3. Weekly goal (3 training days, Monday to Sunday) reached: proud.
4. Otherwise: ready, with the trainings left this week.

The cheek pouches grow with the week's progress. The painter (`lib/ui/hammy.dart`) draws Hammy from shapes: dumbbell held at the belly, lifted overhead when proud, closed eyes when resting.

## Build and test

| Check | Command |
|---|---|
| Static analysis | `flutter analyze` |
| Unit and widget tests | `flutter test` |
| Debug install on Android | `flutter build apk --debug`, then `adb install -r build/app/outputs/flutter-apk/app-debug.apk` |

Tests: `test/domain_test.dart` (search, grouping, week start across DST, streak, Hammy's messages, number formatting), `test/repository_test.dart` (persistence across reopen, past-day sets, last set and recent exercises, one weight per day, delete and restore), `test/app_test.dart` (logging a searched exercise and repeating a set, editing and deleting a set, creating a custom exercise, calendar marks and past-day logging, body weight entry, change and undo).

## Known limits and next steps

- Package name and iOS bundle ID are `app.mafou.hamstrong`; the package name is permanent once the app is on Play.
- Data is local only: no backup, sync or export. Uninstalling deletes it.
- Every change rewrites the whole JSON file; fine for years of sets, but a database (e.g. SQLite) is the better base before sync.
- No release signing, launcher icon or store assets yet.
- Planned: progress charts per exercise, rest timer, progression suggestions, machine settings per exercise, Hammy growing with long-term progress, premium features (AI coach in Hammy's voice).
- UI strings are hard-coded in German; localization is not set up.
