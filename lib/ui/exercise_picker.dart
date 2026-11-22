import 'package:material_ui/material_ui.dart';

import '../data/training_repository.dart';
import '../domain/exercise_catalog.dart';
import '../domain/models.dart';
import 'theme.dart';

/// Full-screen exercise search. Returns the picked exercise, or null.
Future<Exercise?> pickExercise(BuildContext context, TrainingRepository repository) =>
    Navigator.of(context).push<Exercise>(MaterialPageRoute(builder: (_) => ExercisePicker(repository: repository)));

class ExercisePicker extends StatefulWidget {
  const ExercisePicker({super.key, required this.repository});

  final TrainingRepository repository;

  @override
  State<ExercisePicker> createState() => _ExercisePickerState();
}

class _ExercisePickerState extends State<ExercisePicker> {
  var _query = '';
  MuscleGroup? _group;

  Future<void> _createCustom() async {
    final created = await showDialog<Exercise>(
      context: context,
      builder: (_) => _CustomExerciseDialog(repository: widget.repository, initialName: _query, initialGroup: _group),
    );
    if (created != null && mounted) Navigator.of(context).pop(created);
  }

  @override
  Widget build(BuildContext context) {
    final repo = widget.repository;
    final text = Theme.of(context).textTheme;
    final filtering = _query.trim().isNotEmpty || _group != null;
    final results = searchExercises(repo.exercises, _query, group: _group);
    final recent = filtering ? const <Exercise>[] : repo.recentExercises.take(5).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Übung wählen')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: TextField(
              key: const Key('exercise-search'),
              autofocus: false,
              decoration: const InputDecoration(prefixIcon: Icon(Icons.search_rounded), hintText: 'Übung suchen'),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                for (final g in MuscleGroup.values)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(muscleGroupLabels[g]!),
                      selected: _group == g,
                      onSelected: (on) => setState(() => _group = on ? g : null),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                if (recent.isNotEmpty) ...[
                  Text('Zuletzt verwendet', style: text.titleMedium),
                  const SizedBox(height: 8),
                  for (final e in recent) _ExerciseTile(exercise: e, keyPrefix: 'recent'),
                  const SizedBox(height: 16),
                  Text('Alle Übungen', style: text.titleMedium),
                  const SizedBox(height: 8),
                ],
                for (final e in results) _ExerciseTile(exercise: e, keyPrefix: 'all'),
                if (results.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text('Keine passende Übung gefunden.', textAlign: TextAlign.center, style: text.bodyLarge),
                  ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  key: const Key('create-custom'),
                  onPressed: _createCustom,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Eigene Übung anlegen'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ExerciseTile extends StatelessWidget {
  const _ExerciseTile({required this.exercise, required this.keyPrefix});

  final Exercise exercise;
  final String keyPrefix;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Material(
          color: cardColor,
          borderRadius: BorderRadius.circular(18),
          child: ListTile(
            key: Key('$keyPrefix-${exercise.id}'),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            leading: MuscleBadge(group: exercise.muscleGroup),
            title: Text(exercise.name, style: const TextStyle(fontWeight: FontWeight.w700)),
            subtitle: Text(exercise.custom ? '${muscleGroupLabels[exercise.muscleGroup]} · eigene Übung' : muscleGroupLabels[exercise.muscleGroup]!),
            onTap: () => Navigator.of(context).pop(exercise),
          ),
        ),
      );
}

/// Colored disc with the muscle group's initial.
class MuscleBadge extends StatelessWidget {
  const MuscleBadge({super.key, required this.group, this.size = 40});

  final MuscleGroup group;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: muscleColors[group], shape: BoxShape.circle),
        child: Text(
          muscleGroupLabels[group]!.substring(0, 1),
          style: TextStyle(fontFamily: displayFont, fontWeight: FontWeight.w600, fontSize: size * 0.45, color: cocoa),
        ),
      );
}

class _CustomExerciseDialog extends StatefulWidget {
  const _CustomExerciseDialog({required this.repository, required this.initialName, this.initialGroup});

  final TrainingRepository repository;
  final String initialName;
  final MuscleGroup? initialGroup;

  @override
  State<_CustomExerciseDialog> createState() => _CustomExerciseDialogState();
}

class _CustomExerciseDialogState extends State<_CustomExerciseDialog> {
  late final _name = TextEditingController(text: widget.initialName.trim());
  late MuscleGroup _group = widget.initialGroup ?? MuscleGroup.chest;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('Eigene Übung'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              key: const Key('custom-name'),
              controller: _name,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              maxLength: 60,
              decoration: const InputDecoration(labelText: 'Name'),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final g in MuscleGroup.values)
                  ChoiceChip(
                    label: Text(muscleGroupLabels[g]!),
                    selected: _group == g,
                    onSelected: (_) => setState(() => _group = g),
                  ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Abbrechen')),
          FilledButton(
            key: const Key('custom-save'),
            onPressed: _name.text.trim().isEmpty
                ? null
                : () => Navigator.of(context).pop(widget.repository.addCustomExercise(name: _name.text, muscleGroup: _group)),
            child: const Text('Anlegen'),
          ),
        ],
      );
}
