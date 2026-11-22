import 'models.dart';

/// Sets of one exercise within a day, in the order they were performed.
class ExerciseBlock {
  const ExerciseBlock({required this.exerciseId, required this.sets});

  final String exerciseId;
  final List<LoggedSet> sets;

  double get volume => sets.fold(0, (sum, s) => sum + s.volume);
}

/// Groups a day's sets by exercise, ordered by each exercise's first set.
List<ExerciseBlock> groupByExercise(Iterable<LoggedSet> sets) {
  final sorted = sets.toList()..sort((a, b) => a.at.compareTo(b.at));
  final blocks = <String, List<LoggedSet>>{};
  for (final s in sorted) {
    (blocks[s.exerciseId] ??= []).add(s);
  }
  return [for (final e in blocks.entries) ExerciseBlock(exerciseId: e.key, sets: e.value)];
}

/// Monday of the week that contains [day]. Built from date parts, because
/// subtracting a Duration across a DST switch would not land on midnight.
DateTime weekStart(DateTime day) => DateTime(day.year, day.month, day.day - (day.weekday - DateTime.monday));

/// Number of consecutive training days ending today or yesterday.
/// [trainedDays] holds local midnights.
int trainingStreak(Set<DateTime> trainedDays, DateTime today) {
  var day = dayOf(today);
  if (!trainedDays.contains(day)) day = DateTime(day.year, day.month, day.day - 1);
  var count = 0;
  while (trainedDays.contains(day)) {
    count++;
    day = DateTime(day.year, day.month, day.day - 1);
  }
  return count;
}
