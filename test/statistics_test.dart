import 'package:flutter_test/flutter_test.dart';
import 'package:gymoire/domain/exercise_catalog.dart';
import 'package:gymoire/domain/models.dart';
import 'package:gymoire/domain/statistics.dart';

void main() {
  var id = 0;
  LoggedSet set(String exercise, DateTime at, double kg, int reps) =>
      LoggedSet(id: '${id++}', exerciseId: exercise, weightKg: kg, reps: reps, at: at);

  test('estimatedOneRepMax follows Epley and caps reps at 12', () {
    expect(estimatedOneRepMax(100, 1), 100);
    expect(estimatedOneRepMax(100, 5), closeTo(116.667, 0.001));
    expect(estimatedOneRepMax(60, 20), estimatedOneRepMax(60, 12));
    expect(estimatedOneRepMax(0, 10), 0);
  });

  test('sessions group an exercise by day, oldest first', () {
    final sets = [
      set('bench_press', DateTime(2026, 11, 20, 18, 10), 60, 8),
      set('bench_press', DateTime(2026, 11, 13, 18), 55, 10),
      set('squat', DateTime(2026, 11, 20, 18), 90, 5),
      set('bench_press', DateTime(2026, 11, 20, 18), 62.5, 6),
    ];
    final sessions = exerciseSessions(sets, 'bench_press');
    expect(sessions.map((s) => s.day), [DateTime(2026, 11, 13), DateTime(2026, 11, 20)]);
    expect(sessions.last.sets.map((s) => s.weightKg), [62.5, 60]);
    expect(sessions.last.topWeight, 62.5);
    // 60 × 8 (76.0) beats 62.5 × 6 (75.0).
    expect(sessions.last.bestSet.weightKg, 60);
    expect(sessions.last.volume, 60 * 8 + 62.5 * 6);
  });

  test('records and improvement; bodyweight exercises count reps', () {
    final sets = [
      set('bench_press', DateTime(2026, 11, 2, 18), 50, 10),
      set('bench_press', DateTime(2026, 11, 9, 18), 60, 8),
      set('bench_press', DateTime(2026, 11, 16, 18), 57.5, 8),
      set('pull_up', DateTime(2026, 11, 3, 18), 0, 6),
      set('pull_up', DateTime(2026, 11, 17, 18), 0, 9),
    ];
    final records = exerciseRecords(sets);
    expect(records.map((r) => r.exerciseId), ['pull_up', 'bench_press']);

    final bench = records.last;
    expect(bench.best.day, DateTime(2026, 11, 9));
    expect(bench.sessionCount, 3);
    expect(bench.improvement, closeTo(60 * (1 + 8 / 30) - 50 * (1 + 10 / 30), 1e-9));

    final pullUp = records.first;
    expect(pullUp.best.bodyweight, isTrue);
    expect(pullUp.improvement, 3);
  });

  test('recordsOn needs an earlier session to beat', () {
    final sets = [
      set('squat', DateTime(2026, 11, 10, 18), 80, 5),
      set('squat', DateTime(2026, 11, 17, 18), 85, 5),
      set('deadlift', DateTime(2026, 11, 17, 18), 120, 5),
      set('bench_press', DateTime(2026, 11, 10, 18), 60, 8),
      set('bench_press', DateTime(2026, 11, 17, 18), 60, 8),
    ];
    // Deadlift is a first session, bench only ties.
    expect(recordsOn(sets, DateTime(2026, 11, 17, 20)), ['squat']);
  });

  test('weekly summaries count training days, sets and volume per week', () {
    final now = DateTime(2026, 11, 22, 12); // Sunday
    final sets = [
      set('squat', DateTime(2026, 11, 9, 18), 100, 5), // week of Nov 9
      set('squat', DateTime(2026, 11, 16, 18), 100, 5),
      set('squat', DateTime(2026, 11, 16, 18, 5), 100, 5),
      set('bench_press', DateTime(2026, 11, 22, 10), 60, 10),
      set('bench_press', DateTime(2026, 10, 1, 18), 60, 10), // outside
    ];
    final weeks = weeklySummaries(sets, now, weeks: 3);
    expect(weeks.map((w) => w.start), [DateTime(2026, 11, 2), DateTime(2026, 11, 9), DateTime(2026, 11, 16)]);
    expect(weeks.map((w) => w.trainingDays), [0, 1, 2]);
    expect(weeks.map((w) => w.sets), [0, 1, 3]);
    expect(weeks.last.volume, 1600);
  });

  test('comparePeriods splits the current and the previous range', () {
    final now = DateTime(2026, 11, 22, 12);
    final sets = [
      set('squat', DateTime(2026, 11, 20, 18), 100, 5), // current (2 weeks from Nov 9)
      set('squat', DateTime(2026, 11, 9, 18), 100, 5), // current
      set('squat', DateTime(2026, 11, 2, 18), 100, 5), // previous (Oct 26 to Nov 8)
    ];
    final c = comparePeriods(sets, now, weeks: 2);
    expect(c.current.trainingDays, 2);
    expect(c.previous.trainingDays, 1);
    expect(c.current.volume, 1000);
  });

  test('sets per muscle group lists every group', () {
    Exercise? byId(String id) => exerciseCatalog.where((e) => e.id == id).firstOrNull;
    final counts = setsPerMuscleGroup([
      set('squat', DateTime(2026, 11, 20), 100, 5),
      set('leg_press', DateTime(2026, 11, 20), 150, 10),
      set('bench_press', DateTime(2026, 11, 20), 60, 8),
      set('unknown', DateTime(2026, 11, 20), 10, 10),
    ], byId);
    expect(counts[MuscleGroup.legs], 2);
    expect(counts[MuscleGroup.chest], 1);
    expect(counts[MuscleGroup.core], 0);
    expect(counts.length, MuscleGroup.values.length);
  });
}
