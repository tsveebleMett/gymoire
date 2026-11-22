import 'dart:math';

import 'package:material_ui/material_ui.dart';

import '../data/training_repository.dart';
import '../domain/models.dart';
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
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: softSurface(),
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
                SizedBox(height: 160, child: CustomPaint(size: Size.infinite, painter: WeightChartPainter(weights))),
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
              decoration: softSurface(color: Colors.transparent, radius: 18),
              child: ListTile(
                tileColor: cardColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
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

/// Line chart of body weight over time; the x axis is real time, so gaps
/// between entries keep their length.
class WeightChartPainter extends CustomPainter {
  WeightChartPainter(this.weights);

  final List<BodyWeight> weights;

  @override
  void paint(Canvas canvas, Size size) {
    if (weights.length < 2) return;
    const labelWidth = 40.0;
    final chart = Rect.fromLTRB(labelWidth, 8, size.width - 8, size.height - 8);
    final minKg = weights.map((w) => w.kg).reduce(min);
    final maxKg = weights.map((w) => w.kg).reduce(max);
    // At least 2 kg of range, so tiny changes do not look dramatic.
    final pad = max(1.0, (maxKg - minKg) * 0.15);
    final lo = minKg - pad;
    final hi = maxKg + pad;
    final t0 = weights.first.day.millisecondsSinceEpoch.toDouble();
    final t1 = weights.last.day.millisecondsSinceEpoch.toDouble();

    Offset point(BodyWeight w) => Offset(
          chart.left + chart.width * (w.day.millisecondsSinceEpoch - t0) / (t1 - t0),
          chart.bottom - chart.height * (w.kg - lo) / (hi - lo),
        );

    final grid = Paint()
      ..color = furLight
      ..strokeWidth = 1;
    for (final kg in [lo + pad, hi - pad]) {
      final y = chart.bottom - chart.height * (kg - lo) / (hi - lo);
      canvas.drawLine(Offset(chart.left, y), Offset(chart.right, y), grid);
      final label = TextPainter(
        text: TextSpan(text: formatKg((kg * 10).round() / 10), style: const TextStyle(fontSize: 12, color: cocoa)),
        textDirection: TextDirection.ltr,
      )..layout();
      label.paint(canvas, Offset(0, y - label.height / 2));
    }

    final points = [for (final w in weights) point(w)];
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final p in points.skip(1)) {
      path.lineTo(p.dx, p.dy);
    }
    final area = Path.from(path)
      ..lineTo(points.last.dx, chart.bottom)
      ..lineTo(points.first.dx, chart.bottom)
      ..close();
    canvas.drawPath(area, Paint()..color = fur.withValues(alpha: 0.12));
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeJoin = StrokeJoin.round
        ..color = fur,
    );
    for (final p in points) {
      canvas.drawCircle(p, 4, Paint()..color = Colors.white);
      canvas.drawCircle(
        p,
        4,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..color = fur,
      );
    }
  }

  @override
  bool shouldRepaint(WeightChartPainter old) => old.weights != weights;
}
