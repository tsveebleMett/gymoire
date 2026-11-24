import 'package:flutter_test/flutter_test.dart';
import 'package:gymoire/app.dart';
import 'package:gymoire/data/training_repository.dart';
import 'package:gymoire/data/training_store.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  final now = DateTime(2026, 11, 22, 18, 30); // Sunday

  Future<void> pumpApp(WidgetTester tester, TrainingRepository repo) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.6;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(GymoireApp(repository: repo));
    await tester.pumpAndSettle();
  }

  Future<TrainingRepository> repoWithHistory() async {
    final repo = await TrainingRepository.open(MemoryTrainingStore(), clock: () => now);
    // Previous 4-week period: one bench session.
    repo.addSet(exerciseId: 'bench_press', weightKg: 50, reps: 10, day: DateTime(2026, 10, 20));
    // Current period (from Oct 26): three sessions, bench improves.
    repo.addSet(exerciseId: 'bench_press', weightKg: 55, reps: 10, day: DateTime(2026, 11, 2));
    repo.addSet(exerciseId: 'squat', weightKg: 80, reps: 5, day: DateTime(2026, 11, 2));
    repo.addSet(exerciseId: 'bench_press', weightKg: 60, reps: 8, day: DateTime(2026, 11, 16));
    repo.addSet(exerciseId: 'pull_up', weightKg: 0, reps: 7, day: DateTime(2026, 11, 18));
    return repo;
  }

  testWidgets('shows totals, muscle groups and records, and opens an exercise', (tester) async {
    await pumpApp(tester, await repoWithHistory());
    await tester.tap(find.text('Statistik'));
    await tester.pumpAndSettle();

    String totalOf(String key) => tester
        .widgetList<Text>(find.descendant(of: find.byKey(Key(key)), matching: find.byType(Text)))
        .map((t) => t.data)
        .join(' | ');
    expect(totalOf('total-days'), '3 | Trainings | +2');
    expect(totalOf('total-sets'), '4 | Sätze | +3');
    expect(find.text('Nicht trainiert: Schultern, Arme, Rumpf'), findsOneWidget);

    await tester.scrollUntilVisible(find.byKey(const Key('record-bench_press')), 300);
    expect(find.text('60 kg × 8 am 16.11. · +9,3 kg seit 20.10.'), findsOneWidget);
    expect(find.text('≈ 76 kg'), findsOneWidget);
    expect(find.text('7 Wdh.'), findsOneWidget);

    // Bring the tile to the top, clear of the navigation bar.
    await tester.ensureVisible(find.byKey(const Key('record-bench_press')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('record-bench_press')));
    await tester.pumpAndSettle();
    expect(find.text('Geschätztes 1RM'), findsOneWidget);
    expect(find.byKey(const Key('exercise-chart')), findsOneWidget);
    // Nov 2 and Nov 16 beat everything before; Oct 20 is the first session.
    expect(find.text('Bestleistung'), findsNWidgets(3)); // fact label + two chips
    expect(find.text('3'), findsOneWidget);
  });

  testWidgets('12 weeks include the older session', (tester) async {
    await pumpApp(tester, await repoWithHistory());
    await tester.tap(find.text('Statistik'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('12 Wochen'));
    await tester.pumpAndSettle();
    expect(
      tester.widgetList<Text>(find.descendant(of: find.byKey(const Key('total-days')), matching: find.byType(Text))).first.data,
      '4',
    );
  });

  testWidgets('empty statistics explain what to do', (tester) async {
    await pumpApp(tester, await TrainingRepository.open(MemoryTrainingStore(), clock: () => now));
    await tester.tap(find.text('Statistik'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('statistics-empty')), findsOneWidget);
  });

  testWidgets('a new record shows a seal and the mascot names it', (tester) async {
    final repo = await TrainingRepository.open(MemoryTrainingStore(), clock: () => now);
    repo.addSet(exerciseId: 'squat', weightKg: 80, reps: 5, day: DateTime(2026, 11, 18));
    repo.addSet(exerciseId: 'squat', weightKg: 85, reps: 5);
    await pumpApp(tester, repo);

    expect(find.byKey(const Key('record-badge-squat')), findsOneWidget);
    expect(find.textContaining('Neue Bestleistung bei Kniebeuge (Langhantel)!'), findsOneWidget);
  });
}
