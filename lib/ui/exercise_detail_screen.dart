import 'package:material_ui/material_ui.dart';

import '../data/training_repository.dart';
import '../domain/models.dart';
import '../domain/statistics.dart';
import 'charts.dart';
import 'format.dart';
import 'theme.dart';

/// Progress of one exercise: the estimated 1RM per session (max reps for
/// bodyweight exercises), key numbers and every session, newest first.
class ExerciseDetailScreen extends StatelessWidget {
  const ExerciseDetailScreen({super.key, required this.repository, required this.exercise});

  final TrainingRepository repository;
  final Exercise exercise;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text(exercise.name)),
      body: ListenableBuilder(
        listenable: repository,
        builder: (context, _) {
          final sessions = exerciseSessions(repository.allSets, exercise.id);
          if (sessions.isEmpty) {
            return Center(child: Text('Noch keine Sätze für diese Übung.', style: text.bodyLarge));
          }
          final bodyweight = sessions.every((s) => s.bodyweight);
          final best = sessions.reduce((a, b) => b.progressValue > a.progressValue ? b : a);
          final volume = sessions.fold<double>(0, (sum, s) => sum + s.volume);
          final recordDays = <DateTime>{};
          var top = 0.0;
          for (final s in sessions) {
            if (s.progressValue > top) {
              if (top > 0) recordDays.add(s.day);
              top = s.progressValue;
            }
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                decoration: cardSurface(context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(bodyweight ? 'Maximale Wiederholungen' : 'Geschätztes 1RM', style: text.titleMedium),
                    Text(
                      bodyweight ? 'Bester Satz pro Training' : 'Bester Satz pro Training, umgerechnet auf eine Wiederholung',
                      style: text.bodySmall,
                    ),
                    const SizedBox(height: 12),
                    TimeLineChart(
                      key: const Key('exercise-chart'),
                      points: [for (final s in sessions) (s.day, (s.progressValue * 10).round() / 10)],
                      minRange: bodyweight ? 2 : 5,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _Fact(
                    label: 'Bestleistung',
                    value: bodyweight ? '${best.maxReps} Wdh.' : '${formatKg(best.bestOneRepMax.roundToDouble())} kg',
                  ),
                  const SizedBox(width: 8),
                  _Fact(label: 'Trainings', value: '${sessions.length}'),
                  const SizedBox(width: 8),
                  _Fact(
                    label: 'Volumen',
                    value: volume >= 1000 ? '${formatKg((volume / 100).round() / 10)} t' : '${formatKg(volume)} kg',
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text('Verlauf', style: text.titleLarge),
              const SizedBox(height: 8),
              for (final s in sessions.reversed)
                Container(
                  key: Key('session-${s.day.toIso8601String()}'),
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  decoration: cardSurface(context),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(child: Text(formatDayRelative(s.day, repository.now()), style: text.titleMedium)),
                          if (recordDays.contains(s.day))
                            Chip(
                              avatar: const Icon(Icons.emoji_events_rounded, size: 18, color: Color(0xFF111318)),
                              label: const Text('Bestleistung', style: TextStyle(color: Color(0xFF111318))),
                              backgroundColor: context.palette.highlight,
                              side: BorderSide.none,
                              visualDensity: VisualDensity.compact,
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(s.sets.map(formatSet).join('   ·   '), style: text.bodyLarge),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: cardSurface(context),
        child: Column(
          children: [
            Text(value, style: text.titleLarge, maxLines: 1, overflow: TextOverflow.ellipsis),
            Text(label, style: text.bodySmall),
          ],
        ),
      ),
    );
  }
}
