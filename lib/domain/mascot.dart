import 'models.dart';
import 'training_day.dart';

/// Training days per week that count as reaching the weekly goal.
const weeklyGoal = 3;

enum HammyMood { ready, proud, resting }

class HammyState {
  const HammyState({required this.mood, required this.message, required this.weekProgress});

  final HammyMood mood;
  final String message;

  /// Training days this week divided by [weeklyGoal], capped at 1. Hammy's
  /// cheeks fill up with it.
  final double weekProgress;
}

/// What Hammy says on the home screen. Rest days count as part of training,
/// so a long streak earns a rest suggestion instead of pressure.
HammyState hammyFor({required Set<DateTime> trainedDays, required List<LoggedSet> todaySets, required DateTime now}) {
  final today = dayOf(now);
  final monday = weekStart(today);
  final thisWeek = trainedDays.where((d) => !d.isBefore(monday) && !d.isAfter(today)).length;
  final progress = (thisWeek / weeklyGoal).clamp(0.0, 1.0);
  final streak = trainingStreak(trainedDays, today);

  if (todaySets.isNotEmpty) {
    final volume = todaySets.fold<double>(0, (sum, s) => sum + s.volume);
    final sets = todaySets.length == 1 ? '1 Satz' : '${todaySets.length} Sätze';
    final moved = volume > 0 ? ', ${volume.round()} kg bewegt' : '';
    return HammyState(mood: HammyMood.proud, message: 'Stark! $sets$moved. Meine Backen sind voll!', weekProgress: progress);
  }
  if (streak >= 4) {
    return HammyState(
      mood: HammyMood.resting,
      message: '$streak Tage am Stück! Heute ist Ruhetag, Muskeln wachsen in der Pause.',
      weekProgress: progress,
    );
  }
  if (thisWeek >= weeklyGoal) {
    return HammyState(mood: HammyMood.proud, message: 'Wochenziel geschafft! Alles weitere ist Bonus.', weekProgress: progress);
  }
  final left = weeklyGoal - thisWeek;
  return HammyState(
    mood: HammyMood.ready,
    message: left == 1 ? 'Noch 1 Training bis zum Wochenziel. Los geht\'s!' : 'Noch $left Trainings bis zum Wochenziel. Los geht\'s!',
    weekProgress: progress,
  );
}
