# Hamstrong

Hamstrong is a gym tracker: log today's sets and reps, see your training days in a calendar and track your body weight. Hammy, the hamster mascot, comments on the week and fills its cheek pouches as you approach the weekly goal.

Status: prototype. The UI is German; the code and documentation are English. Data stays on the device.

## Features

- Log sets (weight and reps) for today. Exercises come from a searchable catalog of 36 common gym exercises, filterable by muscle group; your own exercises can be added with a muscle group.
- A new set starts with the weight and reps of the exercise's last set, so a repeated set is one tap. Tap a set to edit or delete it.
- Calendar: training days are highlighted with one dot per trained muscle group. Tap a past day to see, edit or complete its workout; future days are locked.
- Body weight: one value per day, the change since the first entry, a line chart and a history list (swipe to delete, with undo).
- Hammy: weekly goal of 3 training days. Hammy is proud after a workout and suggests a rest day after 4 days in a row instead of pushing for streaks.

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
