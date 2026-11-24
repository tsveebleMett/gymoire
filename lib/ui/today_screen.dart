import 'package:material_ui/material_ui.dart';

import '../data/training_repository.dart';
import '../domain/mascot.dart';
import '../domain/statistics.dart';
import 'day_log.dart';
import 'format.dart';
import 'bench_mark.dart';
import 'log_tally.dart';
import 'theme.dart';

class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key, required this.repository});

  final TrainingRepository repository;

  @override
  Widget build(BuildContext context) {
    final now = repository.now();
    final todaySets = repository.setsOn(now);
    final records = [
      for (final id in recordsOn(repository.allSets, now)) ?repository.exerciseById(id)?.name,
    ];
    final mascot = mascotFor(trainedDays: repository.trainedDays, todaySets: todaySets, now: now, newRecords: records);
    final text = Theme.of(context).textTheme;
    final p = context.palette;
    final done = (mascot.weekProgress * weeklyGoal).round();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        Text(formatDayLong(now), style: text.bodyLarge?.copyWith(fontStyle: FontStyle.italic, color: p.muted)),
        Text('Heute', style: text.headlineMedium),
        const HandUnderline(width: 96),
        const SizedBox(height: 14),
        Container(
          key: const Key('mascot-card'),
          padding: const EdgeInsets.fromLTRB(14, 18, 16, 14),
          decoration: cardSurface(context),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MarkPlate(color: p.plate, child: BenchMark(mood: mascot.mood, size: 100)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mascot.message,
                      key: const Key('mascot-message'),
                      style: text.bodyLarge?.copyWith(fontStyle: FontStyle.italic, height: 1.25),
                    ),
                    const SizedBox(height: 10),
                    LogTally(done: done, goal: weeklyGoal),
                    const SizedBox(height: 4),
                    Text('Wochenziel: $done von $weeklyGoal Trainings', style: text.bodySmall),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        DayLog(repository: repository, day: now, emptyText: 'Heute noch nichts eingetragen.'),
      ],
    );
  }
}
