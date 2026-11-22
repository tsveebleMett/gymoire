import 'package:material_ui/material_ui.dart';

import '../data/training_repository.dart';
import '../domain/models.dart';
import 'format.dart';
import 'number_stepper.dart';

/// Bottom sheet to log a new set of [exercise] on [day], or to edit
/// [existing]. A new set starts with the weight and reps of the exercise's
/// last set, so a repeated set is one tap.
Future<void> showSetSheet(
  BuildContext context, {
  required TrainingRepository repository,
  required Exercise exercise,
  required DateTime day,
  LoggedSet? existing,
}) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _SetSheet(repository: repository, exercise: exercise, day: day, existing: existing),
    );

class _SetSheet extends StatefulWidget {
  const _SetSheet({required this.repository, required this.exercise, required this.day, this.existing});

  final TrainingRepository repository;
  final Exercise exercise;
  final DateTime day;
  final LoggedSet? existing;

  @override
  State<_SetSheet> createState() => _SetSheetState();
}

class _SetSheetState extends State<_SetSheet> {
  late final LoggedSet? _last = widget.existing ?? widget.repository.lastSetFor(widget.exercise.id);
  late double _weight = _last?.weightKg ?? 20;
  late double _reps = (_last?.reps ?? 10).toDouble();

  bool get _editing => widget.existing != null;

  void _save() {
    final reps = _reps.round();
    if (reps <= 0) return;
    final repo = widget.repository;
    if (_editing) {
      repo.updateSet(widget.existing!.copyWith(weightKg: _weight, reps: reps));
    } else {
      repo.addSet(exerciseId: widget.exercise.id, weightKg: _weight, reps: reps, day: widget.day);
    }
    Navigator.of(context).pop();
  }

  void _delete() {
    widget.repository.deleteSet(widget.existing!.id);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final last = widget.existing == null ? _last : null;
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 0, 24, 24 + MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(widget.exercise.name, style: text.headlineSmall),
          const SizedBox(height: 4),
          Text(
            _editing
                ? 'Satz bearbeiten'
                : last == null
                    ? 'Erster Satz dieser Übung'
                    : 'Zuletzt: ${formatSet(last)} (${formatDayShort(last.at)})',
            style: text.bodyLarge,
          ),
          const SizedBox(height: 20),
          NumberStepper(
            label: 'Gewicht',
            unit: 'kg',
            value: _weight,
            step: 2.5,
            onChanged: (v) => setState(() => _weight = v),
          ),
          const SizedBox(height: 16),
          NumberStepper(
            label: 'Wiederholungen',
            value: _reps,
            step: 1,
            decimals: false,
            onChanged: (v) => setState(() => _reps = v),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            key: const Key('save-set'),
            onPressed: _reps.round() > 0 ? _save : null,
            icon: const Icon(Icons.check_rounded),
            label: Text(_editing ? 'Speichern' : 'Satz eintragen'),
          ),
          if (_editing) ...[
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: _delete,
              icon: const Icon(Icons.delete_outline_rounded),
              label: const Text('Satz löschen'),
            ),
          ],
        ],
      ),
    );
  }
}
