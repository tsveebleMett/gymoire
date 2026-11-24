import 'package:flutter_test/flutter_test.dart';
import 'package:gymoire/domain/exercise_catalog.dart';
import 'package:gymoire/domain/mascot.dart';
import 'package:gymoire/domain/models.dart';
import 'package:gymoire/domain/training_day.dart';
import 'package:gymoire/ui/format.dart';

void main() {
  group('exercise search', () {
    test('matches words in any order and ignores umlauts and case', () {
      final names = searchExercises(exerciseCatalog, 'KURZ bankdruecken').map((e) => e.name);
      expect(names, ['Schrägbankdrücken (Kurzhantel)']);
    });

    test('filters by muscle group', () {
      final result = searchExercises(exerciseCatalog, '', group: MuscleGroup.arms);
      expect(result, isNotEmpty);
      expect(result.every((e) => e.muscleGroup == MuscleGroup.arms), isTrue);
    });

    test('catalog ids are unique', () {
      final ids = exerciseCatalog.map((e) => e.id).toList();
      expect(ids.toSet().length, ids.length);
    });
  });

  test('groupByExercise orders blocks by their first set', () {
    LoggedSet s(String id, String ex, int minute) =>
        LoggedSet(id: id, exerciseId: ex, weightKg: 10, reps: 10, at: DateTime(2026, 11, 22, 18, minute));
    final blocks = groupByExercise([s('3', 'bench', 20), s('1', 'squat', 0), s('2', 'bench', 10), s('4', 'squat', 30)]);
    expect(blocks.map((b) => b.exerciseId), ['squat', 'bench']);
    expect(blocks.first.sets.map((x) => x.id), ['1', '4']);
  });

  test('weekStart is the Monday at midnight, also across the DST switch', () {
    // Sunday 2026-11-22; Sunday 2026-03-29 is the European DST switch.
    expect(weekStart(DateTime(2026, 11, 22, 19)), DateTime(2026, 11, 16));
    expect(weekStart(DateTime(2026, 3, 29, 12)), DateTime(2026, 3, 23));
  });

  test('trainingStreak counts back from today or yesterday', () {
    final days = {DateTime(2026, 11, 19), DateTime(2026, 11, 20), DateTime(2026, 11, 21)};
    expect(trainingStreak(days, DateTime(2026, 11, 22, 9)), 3);
    expect(trainingStreak(days, DateTime(2026, 11, 23, 9)), 0);
  });

  group('mascot', () {
    final now = DateTime(2026, 11, 22, 18); // Sunday

    test('is proud of today\'s sets and reports the moved weight', () {
      final sets = [LoggedSet(id: 'a', exerciseId: 'bench_press', weightKg: 60, reps: 10, at: now)];
      final state = mascotFor(trainedDays: {DateTime(2026, 11, 22)}, todaySets: sets, now: now);
      expect(state.mood, MascotMood.proud);
      expect(state.message, contains('1 Satz, 600 kg bewegt'));
    });

    test('wears its record look when a new record is named', () {
      final sets = [LoggedSet(id: 'a', exerciseId: 'squat', weightKg: 100, reps: 5, at: now)];
      final state = mascotFor(trainedDays: {DateTime(2026, 11, 22)}, todaySets: sets, now: now, newRecords: ['Kniebeuge']);
      expect(state.mood, MascotMood.record);
      expect(state.message, startsWith('Neue Bestleistung bei Kniebeuge!'));
    });

    test('suggests a rest day after four days in a row', () {
      final days = {for (var d = 18; d <= 21; d++) DateTime(2026, 11, d)};
      final state = mascotFor(trainedDays: days, todaySets: const [], now: now);
      expect(state.mood, MascotMood.resting);
      expect(state.weekProgress, 1);
    });

    test('counts the trainings left for the weekly goal', () {
      final state = mascotFor(trainedDays: {DateTime(2026, 11, 17), DateTime(2026, 11, 10)}, todaySets: const [], now: now);
      expect(state.mood, MascotMood.ready);
      expect(state.message, startsWith('Noch 2 Trainings'));
      expect(state.weekProgress, closeTo(1 / 3, 1e-9));
    });
  });

  test('formatKg and parseKg use the German decimal comma', () {
    expect(formatKg(80), '80');
    expect(formatKg(82.5), '82,5');
    expect(formatKg(1.25), '1,25');
    expect(parseKg('82,5'), 82.5);
    expect(parseKg('82.5'), 82.5);
    expect(parseKg('abc'), isNull);
  });
}
