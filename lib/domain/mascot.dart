import 'models.dart';
import 'training_day.dart';

/// Training days per week that count as reaching the weekly goal.
const weeklyGoal = 3;

/// [record]: a new personal best today.
enum MascotMood { ready, proud, record, resting }

class MascotState {
  const MascotState({required this.mood, required this.message, required this.weekProgress});

  final MascotMood mood;
  final String message;

  /// Training days this week divided by [weeklyGoal], capped at 1. Shown
  /// as the week's stack of logs.
  final double weekProgress;
}

/// What Bench Mark says on the home screen. Rest days count as part of training,
/// so a long streak earns a rest suggestion instead of pressure.
/// [newRecords] names the exercises with a new best result today.
MascotState mascotFor({
  required Set<DateTime> trainedDays,
  required List<LoggedSet> todaySets,
  required DateTime now,
  List<String> newRecords = const [],
}) {
  final today = dayOf(now);
  final monday = weekStart(today);
  final thisWeek = trainedDays.where((d) => !d.isBefore(monday) && !d.isAfter(today)).length;
  final progress = (thisWeek / weeklyGoal).clamp(0.0, 1.0);
  final streak = trainingStreak(trainedDays, today);

  if (todaySets.isNotEmpty) {
    final volume = todaySets.fold<double>(0, (sum, s) => sum + s.volume);
    final sets = todaySets.length == 1 ? '1 Satz' : '${todaySets.length} Sätze';
    final moved = volume > 0 ? ', ${volume.round()} kg bewegt' : '';
    if (newRecords.isNotEmpty) {
      return MascotState(
        mood: MascotMood.record,
        message: 'Neue Bestleistung bei ${newRecords.join(' und ')}! $sets$moved. Das schreib ich in Gold.',
        weekProgress: progress,
      );
    }
    return MascotState(mood: MascotMood.proud, message: 'Stark! $sets$moved. Das kommt ins Buch!', weekProgress: progress);
  }
  if (streak >= 4) {
    return MascotState(
      mood: MascotMood.resting,
      message: '$streak Tage am Stück! Heute ist Ruhetag, Muskeln wachsen in der Pause.',
      weekProgress: progress,
    );
  }
  if (thisWeek >= weeklyGoal) {
    return MascotState(mood: MascotMood.proud, message: 'Wochenziel geschafft! Alles weitere ist Bonus.', weekProgress: progress);
  }
  final left = weeklyGoal - thisWeek;
  return MascotState(
    mood: MascotMood.ready,
    message: left == 1 ? 'Noch 1 Training bis zum Wochenziel. Los geht\'s!' : 'Noch $left Trainings bis zum Wochenziel. Los geht\'s!',
    weekProgress: progress,
  );
}
