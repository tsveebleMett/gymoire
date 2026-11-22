import 'package:flutter_test/flutter_test.dart';
import 'package:hamstrong/app.dart';
import 'package:hamstrong/data/training_repository.dart';
import 'package:hamstrong/data/training_store.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  final now = DateTime(2026, 11, 22, 18, 30); // Sunday

  Future<TrainingRepository> pumpApp(WidgetTester tester, {TrainingRepository? repository}) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.6;
    addTearDown(tester.view.reset);
    final repo = repository ?? await TrainingRepository.open(MemoryTrainingStore(), clock: () => now);
    await tester.pumpWidget(HamstrongApp(repository: repo));
    await tester.pumpAndSettle();
    return repo;
  }

  testWidgets('logs a searched exercise for today and repeats the set with one tap', (tester) async {
    final repo = await pumpApp(tester);
    expect(find.text('Heute noch nichts eingetragen.'), findsOneWidget);

    await tester.tap(find.byKey(const Key('add-exercise')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('exercise-search')), 'bank lang');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('all-bench_press')));
    await tester.pumpAndSettle();

    // Weight 20 by default, raise to 25 and set 8 reps.
    await tester.tap(find.byKey(const Key('Gewicht-plus')));
    await tester.tap(find.byKey(const Key('Gewicht-plus')));
    await tester.enterText(find.byKey(const Key('Wiederholungen-field')), '8');
    await tester.tap(find.byKey(const Key('save-set')));
    await tester.pumpAndSettle();

    expect(find.text('25 kg × 8'), findsOneWidget);
    expect(find.byKey(const Key('hammy-message')), findsOneWidget);
    expect(find.textContaining('1 Satz, 200 kg bewegt'), findsOneWidget);

    // The next set starts with the last values.
    await tester.tap(find.byKey(const Key('add-set-bench_press')));
    await tester.pumpAndSettle();
    expect(find.text('Zuletzt: 25 kg × 8 (22.11.)'), findsOneWidget);
    await tester.tap(find.byKey(const Key('save-set')));
    await tester.pumpAndSettle();

    expect(find.text('25 kg × 8'), findsNWidgets(2));
    expect(repo.setsOn(now), hasLength(2));
  });

  testWidgets('editing a set changes its reps, deleting removes it', (tester) async {
    final repo = await TrainingRepository.open(MemoryTrainingStore(), clock: () => now);
    final set = repo.addSet(exerciseId: 'squat', weightKg: 100, reps: 5);
    await pumpApp(tester, repository: repo);

    await tester.tap(find.byKey(Key('set-${set.id}')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('Wiederholungen-plus')));
    await tester.tap(find.byKey(const Key('save-set')));
    await tester.pumpAndSettle();
    expect(find.text('100 kg × 6'), findsOneWidget);

    await tester.tap(find.byKey(Key('set-${set.id}')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Satz löschen'));
    await tester.pumpAndSettle();
    expect(repo.setsOn(now), isEmpty);
  });

  testWidgets('a custom exercise is created from the search text', (tester) async {
    final repo = await pumpApp(tester);
    await tester.tap(find.byKey(const Key('add-exercise')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('exercise-search')), 'Landmine Press');
    await tester.pumpAndSettle();
    expect(find.text('Keine passende Übung gefunden.'), findsOneWidget);

    await tester.tap(find.byKey(const Key('create-custom')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Schultern').last);
    await tester.tap(find.byKey(const Key('custom-save')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('save-set')));
    await tester.pumpAndSettle();

    expect(find.text('Landmine Press'), findsOneWidget);
    expect(repo.exercises.last.name, 'Landmine Press');
  });

  testWidgets('calendar marks training days and logs a set for a past day', (tester) async {
    final repo = await TrainingRepository.open(MemoryTrainingStore(), clock: () => now);
    repo.addSet(exerciseId: 'deadlift', weightKg: 140, reps: 3, day: DateTime(2026, 11, 18));
    repo.setBodyWeight(DateTime(2026, 11, 18), 82.3);
    await pumpApp(tester, repository: repo);

    await tester.tap(find.text('Kalender'));
    await tester.pumpAndSettle();
    expect(find.text('November 2026'), findsOneWidget);
    expect(find.text('1 Trainingstage im November'), findsOneWidget);
    expect(find.text('An diesem Tag wurde nicht trainiert.'), findsOneWidget);

    await tester.tap(find.byKey(const Key('day-2026-11-18')));
    await tester.pumpAndSettle();
    expect(find.text('Mittwoch, 18. November'), findsOneWidget);
    expect(find.text('140 kg × 3'), findsOneWidget);
    expect(find.text('Körpergewicht: 82,3 kg'), findsOneWidget);

    // Future days cannot be selected; the next month is not reachable.
    await tester.tap(find.byKey(const Key('day-2026-11-25')));
    await tester.pumpAndSettle();
    expect(find.text('Mittwoch, 18. November'), findsOneWidget);

    await tester.tap(find.byKey(const Key('day-2026-11-17')));
    await tester.pumpAndSettle();
    // The month grid is a non-scrolling Scrollable too; scroll the page.
    await tester.scrollUntilVisible(find.byKey(const Key('add-exercise')), 200, scrollable: find.byType(Scrollable).first);
    await tester.tap(find.byKey(const Key('add-exercise')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('exercise-search')), 'klimm');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('all-pull_up')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('save-set')));
    await tester.pumpAndSettle();

    expect(repo.trainedDays, {DateTime(2026, 11, 17), DateTime(2026, 11, 18)});
    expect(find.text('2 Trainingstage im November'), findsOneWidget);

    await tester.tap(find.byKey(const Key('previous-month')));
    await tester.pumpAndSettle();
    expect(find.text('Oktober 2026'), findsOneWidget);
    expect(find.text('0 Trainingstage im Oktober'), findsOneWidget);
  });

  testWidgets('body weight is entered, shown with its change and deleted with undo', (tester) async {
    final repo = await TrainingRepository.open(MemoryTrainingStore(), clock: () => now);
    repo.setBodyWeight(DateTime(2026, 11, 1), 84);
    await pumpApp(tester, repository: repo);

    await tester.tap(find.text('Gewicht'));
    await tester.pumpAndSettle();
    expect(find.text('84 kg'), findsWidgets);

    await tester.tap(find.byKey(const Key('add-weight')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('Körpergewicht-field')), '82,6');
    await tester.tap(find.byKey(const Key('save-weight')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('latest-weight')), findsOneWidget);
    expect(tester.widget<Text>(find.byKey(const Key('latest-weight'))).data, '82,6 kg');
    expect(find.text('Heute · −1,4 kg seit 1.11.'), findsOneWidget);
    expect(find.text('Heutiges Gewicht ändern'), findsOneWidget);

    await tester.drag(find.byKey(Key('weight-${DateTime(2026, 11, 22).toIso8601String()}')), const Offset(-600, 0));
    await tester.pumpAndSettle();
    expect(repo.bodyWeights, hasLength(1));
    await tester.tap(find.text('Rückgängig'));
    await tester.pumpAndSettle();
    expect(repo.bodyWeights, hasLength(2));
  });
}
