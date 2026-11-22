import 'package:flutter_test/flutter_test.dart';
import 'package:hamstrong/data/training_repository.dart';
import 'package:hamstrong/data/training_store.dart';
import 'package:hamstrong/domain/models.dart';

void main() {
  final now = DateTime(2026, 11, 22, 18, 30);

  test('sets, custom exercises and body weights survive a reopen', () async {
    final store = MemoryTrainingStore();
    final repo = await TrainingRepository.open(store, clock: () => now);
    final custom = repo.addCustomExercise(name: '  Landmine Press ', muscleGroup: MuscleGroup.shoulders);
    repo.addSet(exerciseId: custom.id, weightKg: 22.5, reps: 8);
    repo.setBodyWeight(now, 81.4);
    await repo.flush();

    final reopened = await TrainingRepository.open(store, clock: () => now);
    expect(reopened.exerciseById(custom.id)?.name, 'Landmine Press');
    expect(reopened.setsOn(now).single.weightKg, 22.5);
    expect(reopened.bodyWeightOn(now)?.kg, 81.4);
  });

  test('a set for a past day is placed on that day after its existing sets', () async {
    final repo = await TrainingRepository.open(MemoryTrainingStore(), clock: () => now);
    final day = DateTime(2026, 11, 20);
    final first = repo.addSet(exerciseId: 'squat', weightKg: 100, reps: 5, day: day);
    final second = repo.addSet(exerciseId: 'squat', weightKg: 100, reps: 5, day: day);
    expect(sameDay(first.at, day), isTrue);
    expect(second.at.isAfter(first.at), isTrue);
    expect(repo.trainedDays, {day});
    expect(repo.setsOn(now), isEmpty);
  });

  test('lastSetFor and recentExercises follow the latest use', () async {
    var clock = DateTime(2026, 11, 20, 18);
    final repo = await TrainingRepository.open(MemoryTrainingStore(), clock: () => clock);
    repo.addSet(exerciseId: 'bench_press', weightKg: 60, reps: 10);
    clock = DateTime(2026, 11, 21, 18);
    repo.addSet(exerciseId: 'squat', weightKg: 90, reps: 8);
    clock = DateTime(2026, 11, 22, 18);
    repo.addSet(exerciseId: 'bench_press', weightKg: 62.5, reps: 8);

    expect(repo.lastSetFor('bench_press')?.weightKg, 62.5);
    expect(repo.recentExercises.map((e) => e.id), ['bench_press', 'squat']);
  });

  test('one body weight per day; a new value replaces it', () async {
    final repo = await TrainingRepository.open(MemoryTrainingStore(), clock: () => now);
    repo.setBodyWeight(DateTime(2026, 11, 22, 7), 82);
    repo.setBodyWeight(DateTime(2026, 11, 22, 21), 81.6);
    repo.setBodyWeight(DateTime(2026, 11, 15), 83);
    expect(repo.bodyWeights.map((w) => w.kg), [83, 81.6]);
    repo.deleteBodyWeight(DateTime(2026, 11, 15));
    expect(repo.bodyWeights.single.kg, 81.6);
  });

  test('deleting and restoring a set', () async {
    final repo = await TrainingRepository.open(MemoryTrainingStore(), clock: () => now);
    final set = repo.addSet(exerciseId: 'deadlift', weightKg: 120, reps: 5);
    repo.deleteSet(set.id);
    expect(repo.setsOn(now), isEmpty);
    repo.restoreSet(set);
    expect(repo.setsOn(now).single.id, set.id);
  });
}
