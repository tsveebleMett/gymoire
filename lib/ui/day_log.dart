import 'package:material_ui/material_ui.dart';

import '../data/training_repository.dart';
import '../domain/models.dart';
import '../domain/statistics.dart';
import '../domain/training_day.dart';
import 'exercise_picker.dart';
import 'format.dart';
import 'set_sheet.dart';
import 'theme.dart';

/// The workout of one day: a card per exercise with its sets, a button for
/// the next set and one to add another exercise. Used by today and the
/// calendar, so past days can be completed too.
class DayLog extends StatelessWidget {
  const DayLog({
    super.key,
    required this.repository,
    required this.day,
    this.emptyText = 'Noch keine Sätze.',
  });

  final TrainingRepository repository;
  final DateTime day;
  final String emptyText;

  Future<void> _addExercise(BuildContext context) async {
    final exercise = await pickExercise(context, repository);
    if (exercise == null || !context.mounted) return;
    await showSetSheet(
      context,
      repository: repository,
      exercise: exercise,
      day: day,
    );
  }

  @override
  Widget build(BuildContext context) {
    final blocks = groupByExercise(repository.setsOn(day));
    final records = recordsOn(repository.allSets, day).toSet();
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (blocks.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              emptyText,
              textAlign: TextAlign.center,
              style: text.bodyLarge,
            ),
          ),
        for (final b in blocks)
          _ExerciseCard(
            repository: repository,
            block: b,
            day: day,
            record: records.contains(b.exerciseId),
          ),
        const SizedBox(height: 4),
        FilledButton.icon(
          key: const Key('add-exercise'),
          onPressed: () => _addExercise(context),
          icon: const Icon(Icons.fitness_center_rounded),
          label: Text(blocks.isEmpty ? 'Übung eintragen' : 'Weitere Übung'),
        ),
      ],
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  const _ExerciseCard({
    required this.repository,
    required this.block,
    required this.day,
    required this.record,
  });

  final TrainingRepository repository;
  final ExerciseBlock block;
  final DateTime day;

  /// The day's best set beats every earlier session of this exercise.
  final bool record;

  @override
  Widget build(BuildContext context) {
    final exercise =
        repository.exerciseById(block.exerciseId) ??
        Exercise(
          id: block.exerciseId,
          name: 'Unbekannte Übung',
          muscleGroup: MuscleGroup.core,
        );
    final text = Theme.of(context).textTheme;
    final volume = block.volume;
    return Container(
      key: Key('block-${exercise.id}'),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      decoration: cardSurface(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              MuscleBadge(group: exercise.muscleGroup, size: 34),
              const SizedBox(width: 12),
              Expanded(child: Text(exercise.name, style: text.titleMedium)),
              if (record)
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: _RecordBadge(key: Key('record-badge-${exercise.id}')),
                ),
              if (volume > 0)
                Text('${formatKg(volume)} kg', style: text.bodyMedium),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              for (final (i, s) in block.sets.indexed)
                ActionChip(
                  key: Key('set-${s.id}'),
                  avatar: CircleAvatar(
                    backgroundColor: muscleColors[exercise.muscleGroup],
                    child: Text(
                      '${i + 1}',
                      style: const TextStyle(
                        fontFamily: handFont,
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        height: 1,
                      ),
                    ),
                  ),
                  label: Text(formatSet(s)),
                  onPressed: () => showSetSheet(
                    context,
                    repository: repository,
                    exercise: exercise,
                    day: day,
                    existing: s,
                  ),
                ),
              ActionChip(
                key: Key('add-set-${exercise.id}'),
                avatar: Icon(
                  Icons.add_rounded,
                  size: 18,
                  color: context.palette.accent,
                ),
                label: Text(
                  'Satz',
                  style: TextStyle(
                    fontFamily: handFont,
                    color: context.palette.accent,
                  ),
                ),
                backgroundColor: context.palette.accentSoft,
                side: BorderSide.none,
                onPressed: () => showSetSheet(
                  context,
                  repository: repository,
                  exercise: exercise,
                  day: day,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Gold seal for a new personal record.
class _RecordBadge extends StatelessWidget {
  const _RecordBadge({super.key});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: context.palette.highlight,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0xFF8A6418), width: 1.2),
    ),
    child: const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.auto_awesome, size: 15, color: Color(0xFF2A2018)),
        SizedBox(width: 3),
        Text(
          'PR',
          style: TextStyle(
            fontFamily: handFont,
            fontWeight: FontWeight.w700,
            fontSize: 19,
            height: 1,
            color: Color(0xFF2A2018),
          ),
        ),
      ],
    ),
  );
}
