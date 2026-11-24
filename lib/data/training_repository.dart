import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../domain/exercise_catalog.dart';
import '../domain/models.dart';
import 'training_store.dart';

/// All training data of the single local user. Changes are saved to the
/// [TrainingStore] right away; listeners rebuild on every change.
class TrainingRepository extends ChangeNotifier {
  TrainingRepository._(this._store, {DateTime Function()? clock}) : _clock = clock ?? DateTime.now;

  static Future<TrainingRepository> open(TrainingStore store, {DateTime Function()? clock}) async {
    final repo = TrainingRepository._(store, clock: clock);
    final raw = await store.load();
    if (raw != null && raw.isNotEmpty) repo._restore(jsonDecode(raw) as Map<String, Object?>);
    return repo;
  }

  final TrainingStore _store;
  final DateTime Function() _clock;
  final _custom = <Exercise>[];
  final _sets = <LoggedSet>[];
  final _weights = <DateTime, BodyWeight>{};
  var _nextId = 0;
  Future<void> _saving = Future.value();

  DateTime now() => _clock();

  List<Exercise> get exercises => [...exerciseCatalog, ..._custom];

  Exercise? exerciseById(String id) {
    for (final e in exercises) {
      if (e.id == id) return e;
    }
    return null;
  }

  /// All sets in no particular order.
  List<LoggedSet> get allSets => List.unmodifiable(_sets);

  List<LoggedSet> setsOn(DateTime day) => [
        for (final s in _sets)
          if (sameDay(s.at, day)) s,
      ]..sort((a, b) => a.at.compareTo(b.at));

  /// Local midnights of all days with at least one set.
  Set<DateTime> get trainedDays => {for (final s in _sets) dayOf(s.at)};

  /// Most recent set of [exerciseId], used to prefill the next one.
  LoggedSet? lastSetFor(String exerciseId) {
    LoggedSet? last;
    for (final s in _sets) {
      if (s.exerciseId == exerciseId && (last == null || s.at.isAfter(last.at))) last = s;
    }
    return last;
  }

  /// Exercises in order of their latest use, most recent first.
  List<Exercise> get recentExercises {
    final latest = <String, DateTime>{};
    for (final s in _sets) {
      final t = latest[s.exerciseId];
      if (t == null || s.at.isAfter(t)) latest[s.exerciseId] = s.at;
    }
    final ids = latest.keys.toList()..sort((a, b) => latest[b]!.compareTo(latest[a]!));
    return [for (final id in ids) ?exerciseById(id)];
  }

  /// Logs a set on [day]. For today it uses the current time; for another day
  /// it is placed after that day's existing sets.
  LoggedSet addSet({required String exerciseId, required double weightKg, required int reps, DateTime? day}) {
    final current = _clock();
    var at = current;
    if (day != null && !sameDay(day, current)) {
      final existing = setsOn(day);
      at = existing.isEmpty ? DateTime(day.year, day.month, day.day, 18) : existing.last.at.add(const Duration(minutes: 3));
    }
    final set = LoggedSet(id: _newId('set'), exerciseId: exerciseId, weightKg: weightKg, reps: reps, at: at);
    _sets.add(set);
    _changed();
    return set;
  }

  void updateSet(LoggedSet set) {
    final i = _sets.indexWhere((s) => s.id == set.id);
    if (i < 0) return;
    _sets[i] = set;
    _changed();
  }

  void deleteSet(String id) {
    _sets.removeWhere((s) => s.id == id);
    _changed();
  }

  /// Puts back a set removed by [deleteSet] (undo).
  void restoreSet(LoggedSet set) {
    if (_sets.any((s) => s.id == set.id)) return;
    _sets.add(set);
    _changed();
  }

  Exercise addCustomExercise({required String name, required MuscleGroup muscleGroup}) {
    final exercise = Exercise(id: _newId('custom'), name: name.trim(), muscleGroup: muscleGroup, custom: true);
    _custom.add(exercise);
    _changed();
    return exercise;
  }

  /// Body weights, oldest first.
  List<BodyWeight> get bodyWeights => _weights.values.toList()..sort((a, b) => a.day.compareTo(b.day));

  BodyWeight? bodyWeightOn(DateTime day) => _weights[dayOf(day)];

  void setBodyWeight(DateTime day, double kg) {
    final d = dayOf(day);
    _weights[d] = BodyWeight(day: d, kg: kg);
    _changed();
  }

  void deleteBodyWeight(DateTime day) {
    _weights.remove(dayOf(day));
    _changed();
  }

  /// Completes once all changes so far are written.
  Future<void> flush() => _saving;

  String _newId(String prefix) => '$prefix-${_clock().microsecondsSinceEpoch}-${_nextId++}';

  void _changed() {
    final json = jsonEncode(_toJson());
    // Writes run one after another, so an older snapshot never overwrites a newer one.
    _saving = _saving.then((_) => _store.save(json)).catchError((Object e) => debugPrint('Saving failed: $e'));
    notifyListeners();
  }

  Map<String, Object?> _toJson() => {
        'version': 1,
        'customExercises': [for (final e in _custom) e.toJson()],
        'sets': [for (final s in _sets) s.toJson()],
        'bodyWeights': [for (final w in _weights.values) w.toJson()],
      };

  void _restore(Map<String, Object?> json) {
    for (final e in (json['customExercises'] as List? ?? const [])) {
      _custom.add(Exercise.fromJson((e as Map).cast()));
    }
    for (final s in (json['sets'] as List? ?? const [])) {
      _sets.add(LoggedSet.fromJson((s as Map).cast()));
    }
    for (final w in (json['bodyWeights'] as List? ?? const [])) {
      final weight = BodyWeight.fromJson((w as Map).cast());
      _weights[weight.day] = weight;
    }
  }
}
