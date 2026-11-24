import 'package:material_ui/material_ui.dart';

import '../data/training_repository.dart';
import '../domain/models.dart';
import 'charts.dart';
import 'format.dart';
import 'number_stepper.dart';
import 'theme.dart';

/// Body weight: latest value with the change since the first entry, a line
/// chart and the list of entries (swipe to delete).
class WeightScreen extends StatelessWidget {
  const WeightScreen({super.key, required this.repository});

  final TrainingRepository repository;

  @override
  Widget build(BuildContext context) {
    final weights = repository.bodyWeights;
    final text = Theme.of(context).textTheme;
    final latest = weights.isEmpty ? null : weights.last;
    final change = weights.length < 2 ? null : weights.last.kg - weights.first.kg;
    final today = repository.now();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        Text('Körpergewicht', style: text.headlineMedium),
        const HandUnderline(width: 190),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: cardSurface(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (latest == null)
                Text('Noch kein Gewicht eingetragen.', style: text.bodyLarge)
              else ...[
                Text('${formatKg(latest.kg)} kg', key: const Key('latest-weight'), style: text.headlineMedium),
                Text(
                  change == null
                      ? formatDayRelative(latest.day, today)
                      : '${formatDayRelative(latest.day, today)} · ${change > 0 ? '+' : change < 0 ? '−' : '±'}'
                          '${formatKg(change.abs())} kg seit ${formatDayShort(weights.first.day)}',
                  key: const Key('weight-change'),
                  style: text.bodyLarge,
                ),
              ],
              if (weights.length >= 2) ...[
                const SizedBox(height: 16),
                TimeLineChart(points: [for (final w in weights) (w.day, w.kg)]),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  key: const Key('add-weight'),
                  onPressed: () => showWeightSheet(context, repository),
                  icon: const Icon(Icons.monitor_weight_outlined),
                  label: Text(repository.bodyWeightOn(today) == null ? 'Gewicht eintragen' : 'Heutiges Gewicht ändern'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        if (weights.isNotEmpty) Text('Verlauf', style: text.titleLarge),
        const SizedBox(height: 8),
        for (final w in weights.reversed)
          Dismissible(
            key: Key('weight-${w.day.toIso8601String()}'),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 24),
              child: const Icon(Icons.delete_outline_rounded),
            ),
            onDismissed: (_) {
              repository.deleteBodyWeight(w.day);
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(
                  content: Text('Eintrag vom ${formatDayShort(w.day)} gelöscht'),
                  action: SnackBarAction(label: 'Rückgängig', onPressed: () => repository.setBodyWeight(w.day, w.kg)),
                ));
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: cardSurface(context, color: Colors.transparent),
              child: ListTile(
                tileColor: context.palette.card,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                title: Text('${formatKg(w.kg)} kg', style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text(formatDayRelative(w.day, today)),
                onTap: () => showWeightSheet(context, repository, day: w.day),
              ),
            ),
          ),
      ],
    );
  }
}

/// Enter or change the weight of [day] (today by default). Starts at the
/// latest known weight, so a small change is a few taps.
Future<void> showWeightSheet(BuildContext context, TrainingRepository repository, {DateTime? day}) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _WeightSheet(repository: repository, initialDay: dayOf(day ?? repository.now())),
    );

class _WeightSheet extends StatefulWidget {
  const _WeightSheet({required this.repository, required this.initialDay});

  final TrainingRepository repository;
  final DateTime initialDay;

  @override
  State<_WeightSheet> createState() => _WeightSheetState();
}

class _WeightSheetState extends State<_WeightSheet> {
  late DateTime _day = widget.initialDay;
  late double _kg = _startValue();

  double _startValue() {
    final repo = widget.repository;
    final weights = repo.bodyWeights;
    return repo.bodyWeightOn(_day)?.kg ?? (weights.isEmpty ? 75 : weights.last.kg);
  }

  Future<void> _pickDay() async {
    final today = dayOf(widget.repository.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: _day,
      firstDate: DateTime(today.year - 5),
      lastDate: today,
    );
    if (picked != null) {
      setState(() {
        _day = dayOf(picked);
        _kg = _startValue();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 0, 24, 24 + MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Gewicht eintragen', style: text.headlineSmall),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              key: const Key('weight-day'),
              onPressed: _pickDay,
              icon: const Icon(Icons.calendar_today_rounded, size: 18),
              label: Text(formatDayRelative(_day, widget.repository.now())),
            ),
          ),
          const SizedBox(height: 8),
          NumberStepper(
            key: ValueKey(_day),
            label: 'Körpergewicht',
            unit: 'kg',
            value: _kg,
            step: 0.1,
            onChanged: (v) => setState(() => _kg = (v * 10).round() / 10),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            key: const Key('save-weight'),
            onPressed: _kg > 0
                ? () {
                    widget.repository.setBodyWeight(_day, _kg);
                    Navigator.of(context).pop();
                  }
                : null,
            icon: const Icon(Icons.check_rounded),
            label: const Text('Speichern'),
          ),
        ],
      ),
    );
  }
}
