import 'package:material_ui/material_ui.dart';

import '../data/training_repository.dart';
import '../domain/models.dart';
import '../domain/training_day.dart';
import 'exercise_picker.dart';
import 'format.dart';
import 'set_sheet.dart';
import 'theme.dart';

/// The workout of one day: a card per exercise with its sets, a button for
/// the next set and one to add another exercise. Used by today and the
/// calendar, so past days can be completed too.
class DayLog extends StatelessWidget {
  const DayLog({super.key, required this.repository, required this.day, this.emptyText = 'Noch keine Sätze.'});

  final TrainingRepository repository;
  final DateTime day;
  final String emptyText;

  Future<void> _addExercise(BuildContext context) async {
    final exercise = await pickExercise(context, repository);
    if (exercise == null || !context.mounted) return;
    await showSetSheet(context, repository: repository, exercise: exercise, day: day);
  }

  @override
  Widget build(BuildContext context) {
    final blocks = groupByExercise(repository.setsOn(day));
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (blocks.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(emptyText, textAlign: TextAlign.center, style: text.bodyLarge),
          ),
        for (final b in blocks) _ExerciseCard(repository: repository, block: b, day: day),
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
  const _ExerciseCard({required this.repository, required this.block, required this.day});

  final TrainingRepository repository;
  final ExerciseBlock block;
  final DateTime day;

  @override
  Widget build(BuildContext context) {
    final exercise = repository.exerciseById(block.exerciseId) ??
        Exercise(id: block.exerciseId, name: 'Unbekannte Übung', muscleGroup: MuscleGroup.core);
    final text = Theme.of(context).textTheme;
    final volume = block.volume;
    return Container(
      key: Key('block-${exercise.id}'),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      decoration: softSurface(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              MuscleBadge(group: exercise.muscleGroup, size: 34),
              const SizedBox(width: 12),
              Expanded(child: Text(exercise.name, style: text.titleMedium)),
              if (volume > 0) Text('${formatKg(volume)} kg', style: text.bodyMedium),
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
                    child: Text('${i + 1}', style: const TextStyle(fontSize: 12, color: cocoa)),
                  ),
                  label: Text(formatSet(s)),
                  onPressed: () => showSetSheet(context, repository: repository, exercise: exercise, day: day, existing: s),
                ),
              ActionChip(
                key: Key('add-set-${exercise.id}'),
                avatar: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Satz'),
                backgroundColor: furLight,
                onPressed: () => showSetSheet(context, repository: repository, exercise: exercise, day: day),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
