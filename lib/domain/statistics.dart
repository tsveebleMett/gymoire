import 'models.dart';
import 'training_day.dart';

/// Estimated one-rep max after Epley: weight × (1 + reps / 30). A single
/// rep is the weight itself. Above 12 reps the estimate gets unreliable, so
/// reps are capped there. Bodyweight sets (0 kg) have no estimate.
double estimatedOneRepMax(double weightKg, int reps) {
  if (weightKg <= 0 || reps <= 0) return 0;
  if (reps == 1) return weightKg;
  return weightKg * (1 + (reps > 12 ? 12 : reps) / 30);
}

/// One exercise on one day.
class ExerciseSession {
  const ExerciseSession({required this.day, required this.sets});

  final DateTime day;
  final List<LoggedSet> sets;

  double get bestOneRepMax => sets.map((s) => estimatedOneRepMax(s.weightKg, s.reps)).fold(0, _max);
  double get topWeight => sets.map((s) => s.weightKg).fold(0, _max);
  int get maxReps => sets.map((s) => s.reps).fold(0, (a, b) => a > b ? a : b);
  double get volume => sets.fold(0, (sum, s) => sum + s.volume);

  /// Bodyweight exercises are measured by reps instead of weight.
  bool get bodyweight => topWeight == 0;

  /// The value the progress chart shows: estimated 1RM, or max reps for
  /// bodyweight exercises.
  double get progressValue => bodyweight ? maxReps.toDouble() : bestOneRepMax;

  LoggedSet get bestSet => sets.reduce((a, b) {
        final ea = bodyweight ? a.reps.toDouble() : estimatedOneRepMax(a.weightKg, a.reps);
        final eb = bodyweight ? b.reps.toDouble() : estimatedOneRepMax(b.weightKg, b.reps);
        return eb > ea ? b : a;
      });
}

double _max(double a, double b) => a > b ? a : b;

/// The sessions of [exerciseId], oldest first.
List<ExerciseSession> exerciseSessions(Iterable<LoggedSet> sets, String exerciseId) {
  final byDay = <DateTime, List<LoggedSet>>{};
  for (final s in sets) {
    if (s.exerciseId == exerciseId) (byDay[dayOf(s.at)] ??= []).add(s);
  }
  final days = byDay.keys.toList()..sort();
  return [
    for (final d in days) ExerciseSession(day: d, sets: byDay[d]!..sort((a, b) => a.at.compareTo(b.at))),
  ];
}

/// Best result of one exercise over all time, with the change against its
/// first session.
class ExerciseRecord {
  const ExerciseRecord({required this.exerciseId, required this.best, required this.first, required this.sessionCount});

  final String exerciseId;
  final ExerciseSession best;
  final ExerciseSession first;
  final int sessionCount;

  double get improvement => best.progressValue - first.progressValue;
}

/// Records for every exercise trained at least once, most recently set
/// record first.
List<ExerciseRecord> exerciseRecords(Iterable<LoggedSet> sets) {
  final ids = {for (final s in sets) s.exerciseId};
  final records = <ExerciseRecord>[];
  for (final id in ids) {
    final sessions = exerciseSessions(sets, id);
    // Ties keep the earlier session: a record is set the first time.
    final best = sessions.reduce((a, b) => b.progressValue > a.progressValue ? b : a);
    records.add(ExerciseRecord(exerciseId: id, best: best, first: sessions.first, sessionCount: sessions.length));
  }
  return records..sort((a, b) => b.best.day.compareTo(a.best.day));
}

/// Exercises whose record was set on [day] and beats an earlier session.
/// A first session is no record yet.
List<String> recordsOn(Iterable<LoggedSet> sets, DateTime day) {
  final d = dayOf(day);
  final ids = {
    for (final s in sets)
      if (sameDay(s.at, d)) s.exerciseId,
  };
  return [
    for (final id in ids)
      if (_beatsAllBefore(exerciseSessions(sets, id), d)) id,
  ];
}

bool _beatsAllBefore(List<ExerciseSession> sessions, DateTime day) {
  final today = sessions.where((s) => s.day == day).firstOrNull;
  final before = sessions.where((s) => s.day.isBefore(day)).toList();
  if (today == null || before.isEmpty) return false;
  return today.progressValue > before.map((s) => s.progressValue).fold<double>(0, _max);
}

class WeekSummary {
  const WeekSummary({required this.start, required this.trainingDays, required this.sets, required this.volume});

  /// Monday at midnight.
  final DateTime start;
  final int trainingDays;
  final int sets;
  final double volume;
}

/// The last [weeks] weeks up to and including the week of [now], oldest first.
List<WeekSummary> weeklySummaries(Iterable<LoggedSet> sets, DateTime now, {required int weeks}) {
  final current = weekStart(now);
  final starts = [for (var i = weeks - 1; i >= 0; i--) DateTime(current.year, current.month, current.day - 7 * i)];
  return [
    for (final start in starts)
      () {
        final end = DateTime(start.year, start.month, start.day + 7);
        final inWeek = sets.where((s) => !s.at.isBefore(start) && s.at.isBefore(end)).toList();
        return WeekSummary(
          start: start,
          trainingDays: {for (final s in inWeek) dayOf(s.at)}.length,
          sets: inWeek.length,
          volume: inWeek.fold(0, (sum, s) => sum + s.volume),
        );
      }(),
  ];
}

/// Number of sets per muscle group; every group is present, untrained ones with 0.
Map<MuscleGroup, int> setsPerMuscleGroup(Iterable<LoggedSet> sets, Exercise? Function(String id) exerciseById) {
  final counts = {for (final g in MuscleGroup.values) g: 0};
  for (final s in sets) {
    final group = exerciseById(s.exerciseId)?.muscleGroup;
    if (group != null) counts[group] = counts[group]! + 1;
  }
  return counts;
}

/// Totals of a period and the same-length period before it.
class PeriodComparison {
  const PeriodComparison({required this.current, required this.previous});

  final PeriodTotals current;
  final PeriodTotals previous;
}

class PeriodTotals {
  const PeriodTotals({required this.trainingDays, required this.sets, required this.volume});

  final int trainingDays;
  final int sets;
  final double volume;
}

/// Compares the last [weeks] full and current weeks with the [weeks] before.
PeriodComparison comparePeriods(Iterable<LoggedSet> sets, DateTime now, {required int weeks}) {
  final current = weekStart(now);
  final start = DateTime(current.year, current.month, current.day - 7 * (weeks - 1));
  final previousStart = DateTime(start.year, start.month, start.day - 7 * weeks);
  final end = DateTime(current.year, current.month, current.day + 7);
  PeriodTotals totals(DateTime from, DateTime to) {
    final inRange = sets.where((s) => !s.at.isBefore(from) && s.at.isBefore(to)).toList();
    return PeriodTotals(
      trainingDays: {for (final s in inRange) dayOf(s.at)}.length,
      sets: inRange.length,
      volume: inRange.fold(0, (sum, s) => sum + s.volume),
    );
  }

  return PeriodComparison(current: totals(start, end), previous: totals(previousStart, start));
}

/// Sets from the start of the week [weeks] - 1 weeks before [now]'s week.
Iterable<LoggedSet> setsInLastWeeks(Iterable<LoggedSet> sets, DateTime now, {required int weeks}) {
  final current = weekStart(now);
  final start = DateTime(current.year, current.month, current.day - 7 * (weeks - 1));
  return sets.where((s) => !s.at.isBefore(start));
}
