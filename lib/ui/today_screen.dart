import 'package:material_ui/material_ui.dart';

import '../data/training_repository.dart';
import '../domain/mascot.dart';
import 'day_log.dart';
import 'format.dart';
import 'hammy.dart';
import 'theme.dart';

class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key, required this.repository});

  final TrainingRepository repository;

  @override
  Widget build(BuildContext context) {
    final now = repository.now();
    final todaySets = repository.setsOn(now);
    final hammy = hammyFor(trainedDays: repository.trainedDays, todaySets: todaySets, now: now);
    final text = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        Text(formatDayLong(now), style: text.bodyLarge),
        Text('Heute', style: text.headlineMedium),
        const SizedBox(height: 12),
        Container(
          key: const Key('hammy-card'),
          padding: const EdgeInsets.all(16),
          decoration: softSurface(color: const Color(0xFFFFEBD3)),
          child: Row(
            children: [
              Hammy(mood: hammy.mood, cheeks: hammy.weekProgress, size: 104),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Hammy', style: text.titleMedium),
                    const SizedBox(height: 4),
                    Text(hammy.message, key: const Key('hammy-message'), style: text.bodyLarge),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: hammy.weekProgress,
                        minHeight: 10,
                        backgroundColor: Colors.white,
                        color: fur,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text('Wochenziel: $weeklyGoal Trainings', style: text.bodySmall),
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
