# Gymoire

Gymoire is a gym tracker: log today's sets and reps, see your training days in a calendar and track your body weight. Statistics show how the training develops. A bear built like a gym strongman keeps your training memoirs, comments on the week and stacks a log for every training day.

Status: prototype. The name joins gym and the French mémoire, with a nod to grimoire, and the design looks like handwritten entries in a leather-bound book. The UI is German; the code and documentation are English. Data stays on the device. Light and dark mode follow the system setting.

## Features

- Log sets (weight and reps) for today. Exercises come from a searchable catalog of 36 common gym exercises, filterable by muscle group; your own exercises can be added with a muscle group.
- A new set starts with the weight and reps of the exercise's last set, so a repeated set is one tap. Tap a set to edit or delete it.
- Calendar: training days are highlighted with one dot per trained muscle group. Tap a past day to see, edit or complete its workout; future days are locked.
- Statistics for the last 4 or 12 weeks: trainings, sets and volume against the period before, training days per week against the goal, sets per muscle group, and the best result per exercise (estimated one-rep max) with a progress chart per exercise. New records get a trophy.
- Body weight: one value per day, the change since the first entry, a line chart and a history list (swipe to delete, with undo).
- Mascot (internally Bench Mark, never named in the app): a brown bear built like a gym strongman, drawn as an ink sketch, with lifting belt, gym shorts and wrist wraps, built from interchangeable parts (poses, faces, effects, gear colors); see `docs/mascot/bench_mark_sheet.png`. Weekly goal of 3 training days, shown as a small woodpile; the bear carries a log after a workout, presses it overhead for a new record and suggests a rest day after 4 days in a row instead of pushing for streaks.
- Design: ink on parchment in light mode, light ink on a dark leather book in dark mode, handwritten headlines and entries; screenshots in `docs/screens/`, brand mark and lockups in `docs/brand/`.

## Requirements

- Flutter stable (developed with Flutter 3.50.0 / Dart 3.14.0).
- Android SDK with `adb` for a device install.

## Run

```bash
flutter run
```

Install a debug build on a connected Android device:

```bash
flutter build apk --debug
adb install -r build/app/outputs/flutter-apk/app-debug.apk
```

## Checks

```bash
flutter analyze
flutter test
```
