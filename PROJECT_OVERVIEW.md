# Project Overview

Gymoire is a Flutter app (Android, iOS) for logging gym workouts and body weight, with a strongman bear as mascot. It uses the same stack and conventions as Tempino (Flutter with `material_ui`, a pure Dart domain layer, painted illustrations instead of image assets, German UI strings) but has its own design: a handwritten training journal.

The name joins gym and the French mémoire (memoir) and sounds like grimoire, a book of spells: the app keeps the memoirs of your training, with a touch of magic. Spoken "jim-WAHR". The project started as Hamstrong with a hamster mascot; the repository folder is still called `hamstrong`.

## Architecture

| Layer | Path | Responsibility |
|---|---|---|
| Entry point | `lib/main.dart` | Opens `TrainingRepository` on a `FileTrainingStore` and starts `GymoireApp`. Portrait only. |
| App shell | `lib/app.dart` | Light and dark theme following the system setting, German locale, `HomeShell` with four tabs (Heute, Kalender, Statistik, Gewicht) that rebuild on every repository change. |
| Domain | `lib/domain/` | `models.dart` (Exercise, LoggedSet, BodyWeight), `exercise_catalog.dart` (built-in exercises and search), `training_day.dart` (grouping a day's sets, week start, streak), `mascot.dart` (the mascot's mood and message), `statistics.dart` (estimated 1RM, sessions and records per exercise, weekly summaries, period comparison, sets per muscle group). Pure Dart, no Flutter imports. |
| Data | `lib/data/` | `TrainingRepository` (a `ChangeNotifier` holding custom exercises, sets and body weights) and `TrainingStore` (`FileTrainingStore` for the app, `MemoryTrainingStore` for tests). |
| UI | `lib/ui/` | Today (`today_screen.dart`), calendar (`calendar_screen.dart`), statistics (`statistics_screen.dart`) and progress of one exercise (`exercise_detail_screen.dart`), body weight (`weight_screen.dart`), line and bar charts (`charts.dart`), a day's workout shared by today and the calendar (`day_log.dart`), exercise search (`exercise_picker.dart`), set entry (`set_sheet.dart`), number field with plus/minus (`number_stepper.dart`), the mascot widget and its parchment plate (`bench_mark.dart`) with its parts system and painter (`mascot/bench_mark_look.dart`, `mascot/bench_mark_painter.dart`), the weekly woodpile (`log_tally.dart`), the brand mark (`brand_mark.dart`), the app logo (`logo.dart`), palette, fonts, page texture, ink frames, hand-drawn underline and component styles (`theme.dart`), German date and number formatting (`format.dart`). |
| Assets | `assets/logo/`, `assets/fonts/` | Logo layers rendered from `logo.dart`. Caveat (handwriting) and Crimson Pro (book serif) as variable fonts from github.com/google/fonts, SIL OFL 1.1 (`assets/fonts/OFL-*.txt`). |
| Tools | `tool/` | `render_logo_test.dart` renders the logo layers (then run `dart run flutter_launcher_icons`); `render_mascot_sheet_test.dart` renders `docs/mascot/bench_mark_sheet.png`, a sheet of Bench Mark variants; `render_brand_test.dart` renders the mark and the lockups to `docs/brand/`; `render_screens_test.dart` renders the today and weight screens with sample data in light and dark mode to `docs/screens/`. Run with `flutter test tool/<file>`; not part of `flutter test`. |

A clock function (`DateTime Function()`) is passed to `TrainingRepository.open`; the UI reads the time through `repository.now()`, so tests control time.

## Visual design

A training journal in the spirit of a memoir and a grimoire: entries look handwritten and drawn into an old codex, in light and in dark mode alike.

| | Light: vellum codex | Dark: black hours |
|---|---|---|
| Idea | Iron-gall ink on aged vellum | The medieval "black hours", books written in bone-white and gold on black-dyed vellum |
| Page and entries | `#E4D5B5`, entries `#F1E7CF` | `#0E1113`, entries `#161B1E` |
| Ink, muted | `#2B1E16`, `#6C5B45` | `#E8E0CC`, `#9D9988` |
| Actions (verdigris) | `#2E5E52` with vellum text | lines and icons `#7DB3A0`; filled buttons deep `#2B5A4F` with a gilded edge |
| Rubrics | Cinnabar `#8E2B20` | Gilding `#C9A24E` |
| Records (gold leaf) | `#C79D3D` | `#D8B45A` |

Verdigris, the alchemists' copper green, marks buttons, selections and chart lines; rubrics are the hand-drawn underlines of screen titles (`HandUnderline`, ending in a small diamond); gold leaf marks records and reached goals. The palette deliberately avoids pastel and pink tones and the black-and-orange of gym chains. Headlines, buttons, tabs, chips and the logged numbers use the handwriting font Caveat, running text the book serif Crimson Pro.

Every screen lies on a painted page (`BookPage`): fibers, foxing stains (gold dust on the black pages) and edges darkened by age. Entries (`cardSurface`, an `InkFrameDecoration`) sit inside a hand-ruled double frame whose outer line wobbles slightly and runs past the corners; on vellum they cast a faint shadow. Buttons, chips, tabs and tiles are nearly square like pasted-in labels (3 px corners), filled buttons have a darker inked edge. Each muscle group has a historical pigment with a round two-letter badge (BR, RÜ, BE, SC, AR, RU), because several groups share their initial: cinnabar (chest), indigo (back), sap green (legs), ochre (shoulders), sepia (arms), slate (core).

Light and dark mode follow the system setting (`ThemeMode.system`). All mode-dependent colors live in the `BookPalette` theme extension (`BookPalette.light`, `BookPalette.night`), read with `context.palette`; chart painters get the palette passed in. Text on gold and on pasted-in parchment uses `inkOnGold` in both modes. The mascot is always drawn in dark ink on a parchment plate (`MarkPlate`, slightly askew with two strips of tape, like a drawing pasted into the book), so he reads the same in both modes.

## Data model

There is no workout object: all sets of a calendar day form that day's workout. This keeps logging a single action and lets the calendar complete past days.

| Type | Fields |
|---|---|
| `Exercise` | `id`, `name`, `muscleGroup`, `custom`. Catalog ids are stable because sets refer to them; custom exercises get generated ids and are persisted. |
| `LoggedSet` | `id`, `exerciseId`, `weightKg` (0 for bodyweight exercises), `reps`, `at`. A set logged for a past day is placed at 18:00, or 3 minutes after that day's last set. |
| `BodyWeight` | `day` (local midnight), `kg`. One value per day; a new value replaces it. |

Storage: one JSON file `gymoire.json` in the app documents directory, rewritten on every change. Writes are chained so an older snapshot never overwrites a newer one, and go to a `.tmp` file first that is then renamed.

## Bench Mark

`mascotFor` (`lib/domain/mascot.dart`) decides mood and message, in this order:

1. Sets today: proud, with the number of sets and the moved volume; with a new record today, the record mood names it.
2. Four or more training days in a row (ending today or yesterday): resting, suggests a rest day.
3. Weekly goal (3 training days, Monday to Sunday) reached: proud.
4. Otherwise: ready, with the trainings left this week.

The mascot is a brown bear built like a gym strongman who loves training and keeps the user's training memoirs; internally he is called Bench Mark, but the app never names him, he is simply there. Strong and confident rather than cute, for everyone: a small head with heavy brows, ruffled cheek fur and a long snout on a V-shaped torso (traps, broad shoulders and lats, narrow waist), defined pecs and abs, big deltoids, biceps and forearms. He wears a leather lifting belt with a gold buckle, gym shorts with side stripes and wrist wraps. He is drawn from the front as an ink sketch: dark outlines with a faint second pen line, watercolor washes with a darker shadow side, and hatching. Logs (log as in tree trunk and as in logbook) are his training weights, and their sawn ends show growth rings. He is built from parts so that variants need no new drawing: a `MarkLook` (`lib/ui/mascot/bench_mark_look.dart`) combines

| Part | Options |
|---|---|
| Pose | stand (fists on the hips, lats spread), carry (log on the shoulder), lift (log pressed overhead), flex (double biceps), rest (arms relaxed, woodpile at his feet) |
| Face | determined (confident grin), joy (open-mouthed roar), focused (gritted teeth for effort), sleepy |
| Effect | none, gold sparkles, sweat drop, Z letters |
| Extras | lifting belt, quill behind the ear, shorts color, gear color (wrist wraps and stripes) |

`BenchMark.lookFor` maps each mood to a look: ready stands with fists on the hips, proud carries a log, record presses it overhead with a roar and sparkles, resting sleeps next to a woodpile. The home screen shows the week's progress as a woodpile (`LogTally`): one sawn log end per training day, missing ones pencilled in. `BenchMarkPainter` (`lib/ui/mascot/bench_mark_painter.dart`) draws any look on a 200 × 200 grid; `frame` crops a part of the grid. New variants (seasons, achievements, premium looks) are new parts or colors in `MarkLook`.

## Statistics

`lib/domain/statistics.dart`, shown on the Statistik tab for the last 4 or 12 weeks (a week runs Monday to Sunday, the current week included):

- Overview: training days, sets and volume (kg × reps), each compared with the same number of weeks before.
- Training days per week as bars, with the weekly goal as a dashed line.
- Sets per muscle group; untrained groups are named.
- Records: per exercise the best session over all time and the change since its first session. Tapping one opens its progress chart and every session.

Progress is measured as the estimated one-rep max (1RM) after Epley, weight × (1 + reps / 30), with reps capped at 12 because the formula drifts above that. Bodyweight exercises (0 kg) use the most reps in one set instead. A session is a record when it beats every earlier session of the exercise; a first session is none. Records show as a gold PR seal in the day's log and as the mascot's record look and message.

## Brand mark and logo

The brand mark (`lib/ui/brand_mark.dart`, `GymoireMarkPainter`) is a seal like the sigil on the cover of an old grimoire: the mascot's head with heavy brows, ruffled cheek fur and a long snout over a barbell, inside a double ring tied together by four small diamonds. Eyes, brows, inner ears and snout are negative space. Being one color, it works at any size, on any background and as a themed icon. With the handwritten wordmark "Gymoire" (Caveat Bold with a hand-drawn underline) it forms the lockup (`docs/brand/lockup_light.png` in rubric red and ink on parchment, `docs/brand/lockup_dark.png` in gold and light ink on dark; mark alone in `docs/brand/mark.png`). The mark carries the brand; the mascot carries the personality inside the app.

The app icon is the cover of a leather-bound book: the mark embossed in gold (with a dark offset as if pressed into the leather) on an oxblood leather gradient; its monochrome layer is the mark in white. `GymoireLogoPainter` draws it on the 108 × 108 Android adaptive-icon grid with everything essential inside the safe radius of 33, as separate background, foreground and monochrome (themed icon) layers.

## Build and test

| Check | Command |
|---|---|
| Static analysis | `flutter analyze` |
| Unit and widget tests | `flutter test` |
| Debug install on Android | `flutter build apk --debug`, then `adb install -r build/app/outputs/flutter-apk/app-debug.apk` |

Tests: `test/domain_test.dart` (search, grouping, week start across DST, streak, the mascot's messages and record mood, number formatting), `test/repository_test.dart` (persistence across reopen, past-day sets, last set and recent exercises, one weight per day, delete and restore), `test/statistics_test.dart` (1RM, sessions, records, weekly summaries, period comparison, muscle groups), `test/statistics_screen_test.dart` (totals with deltas, untrained groups, records, exercise detail, 12-week range, empty state, record seal and the mascot's message), `test/bench_mark_test.dart` (a look per mood, every combination of parts paints), `test/theme_test.dart` (light and dark palette by system setting, switching at runtime), `test/app_test.dart` (logging a searched exercise and repeating a set, editing and deleting a set, creating a custom exercise, calendar marks and past-day logging, body weight entry, change and undo).

## Known limits and next steps

- Package name and iOS bundle ID are `app.mafou.gymoire`; the package name is permanent once the app is on Play.
- Data is local only: no backup, sync or export. Uninstalling deletes it.
- Every change rewrites the whole JSON file; fine for years of sets, but a database (e.g. SQLite) is the better base before sync.
- No release signing or store assets yet.
- Planned: rest timer, progression suggestions, machine settings per exercise, the mascot's cabin growing with long-term progress, premium features (AI coach in the mascot's voice).
- UI strings are hard-coded in German; localization is not set up.
