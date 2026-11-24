import 'package:material_ui/material_ui.dart';

import '../data/training_repository.dart';
import '../domain/mascot.dart';
import '../domain/models.dart';
import '../domain/statistics.dart';
import 'charts.dart';
import 'exercise_detail_screen.dart';
import 'exercise_picker.dart';
import 'format.dart';
import 'bench_mark.dart';
import 'theme.dart';

/// Evaluation of the last 4 or 12 weeks: totals against the period before,
/// training days per week against the goal, sets per muscle group and the
/// best result of every exercise.
class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key, required this.repository});

  final TrainingRepository repository;

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  var _weeks = 4;

  @override
  Widget build(BuildContext context) {
    final repo = widget.repository;
    final text = Theme.of(context).textTheme;
    final now = repo.now();
    final all = repo.allSets;

    if (all.isEmpty) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Text('Statistik', style: text.headlineMedium),
          const HandUnderline(width: 130),
          const SizedBox(height: 40),
          Center(child: MarkPlate(color: context.palette.plate, child: BenchMark(mood: MascotMood.resting, size: 140))),
          const SizedBox(height: 16),
          Text(
            'Noch keine Daten. Trag dein erstes Training ein, dann wird es hier ausgewertet.',
            key: const Key('statistics-empty'),
            textAlign: TextAlign.center,
            style: text.bodyLarge,
          ),
        ],
      );
    }

    final comparison = comparePeriods(all, now, weeks: _weeks);
    final weeks = weeklySummaries(all, now, weeks: _weeks);
    final groups = setsPerMuscleGroup(setsInLastWeeks(all, now, weeks: _weeks), repo.exerciseById);
    final untrained = [
      for (final e in groups.entries)
        if (e.value == 0) muscleGroupLabels[e.key]!,
    ];
    final records = exerciseRecords(all);
    final labelEvery = _weeks <= 4 ? 1 : 3;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        Text('Statistik', style: text.headlineMedium),
        const HandUnderline(width: 130),
        const SizedBox(height: 12),
        SegmentedButton<int>(
          segments: const [
            ButtonSegment(value: 4, label: Text('4 Wochen')),
            ButtonSegment(value: 12, label: Text('12 Wochen')),
          ],
          selected: {_weeks},
          showSelectedIcon: false,
          onSelectionChanged: (s) => setState(() => _weeks = s.single),
        ),
        const SizedBox(height: 16),
        _Card(
          title: 'Überblick',
          subtitle: 'Im Vergleich zu den $_weeks Wochen davor',
          child: Row(
            children: [
              _Total(
                key: const Key('total-days'),
                label: 'Trainings',
                value: '${comparison.current.trainingDays}',
                delta: _delta(comparison.current.trainingDays.toDouble(), comparison.previous.trainingDays.toDouble()),
              ),
              _Total(
                key: const Key('total-sets'),
                label: 'Sätze',
                value: '${comparison.current.sets}',
                delta: _delta(comparison.current.sets.toDouble(), comparison.previous.sets.toDouble()),
              ),
              _Total(
                key: const Key('total-volume'),
                label: 'Volumen',
                value: _tonnes(comparison.current.volume),
                delta: _delta(comparison.current.volume, comparison.previous.volume, tonnes: true),
              ),
            ],
          ),
        ),
        _Card(
          title: 'Trainings pro Woche',
          subtitle: 'Gestrichelt: Wochenziel von $weeklyGoal',
          child: BarChart(
            key: const Key('weekly-chart'),
            values: [for (final w in weeks) w.trainingDays.toDouble()],
            labels: [
              for (final (i, w) in weeks.indexed)
                (weeks.length - 1 - i) % labelEvery == 0 ? formatDayShort(w.start) : '',
            ],
            goal: weeklyGoal.toDouble(),
          ),
        ),
        _Card(
          title: 'Sätze pro Muskelgruppe',
          subtitle: untrained.isEmpty ? 'Alle Muskelgruppen trainiert' : 'Nicht trainiert: ${untrained.join(', ')}',
          child: _MuscleBars(counts: groups),
        ),
        const SizedBox(height: 8),
        Text('Bestleistungen', style: text.titleLarge),
        Text('Geschätztes Maximalgewicht für eine Wiederholung (1RM)', style: text.bodyMedium),
        const SizedBox(height: 8),
        for (final r in records) _RecordTile(repository: repo, record: r),
      ],
    );
  }

  static String _tonnes(double kg) => kg >= 1000 ? '${formatKg((kg / 100).round() / 10)} t' : '${formatKg(kg.roundToDouble())} kg';

  static String _delta(double current, double previous, {bool tonnes = false}) {
    final d = current - previous;
    if (d == 0) return '±0';
    final abs = tonnes ? _tonnes(d.abs()) : formatKg(d.abs());
    return d > 0 ? '+$abs' : '−$abs';
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.title, required this.child, this.subtitle});

  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: cardSurface(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: text.titleMedium),
          if (subtitle != null) Text(subtitle!, style: text.bodySmall),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _Total extends StatelessWidget {
  const _Total({super.key, required this.label, required this.value, required this.delta});

  final String label;
  final String value;
  final String delta;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final positive = delta.startsWith('+');
    final negative = delta.startsWith('−');
    return Expanded(
      child: Column(
        children: [
          Text(value, style: text.headlineSmall),
          Text(label, style: text.bodyMedium),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: positive
                  ? context.palette.positiveSoft
                  : negative
                      ? context.palette.negativeSoft
                      : context.palette.track,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              delta,
              style: text.bodySmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: positive
                    ? context.palette.positive
                    : negative
                        ? context.palette.negative
                        : context.palette.muted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MuscleBars extends StatelessWidget {
  const _MuscleBars({required this.counts});

  final Map<MuscleGroup, int> counts;

  @override
  Widget build(BuildContext context) {
    final most = counts.values.fold(0, (a, b) => a > b ? a : b);
    final sorted = counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return Column(
      children: [
        for (final e in sorted)
          Padding(
            key: Key('muscle-${e.key.name}'),
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                SizedBox(width: 82, child: Text(muscleGroupLabels[e.key]!, style: const TextStyle(fontWeight: FontWeight.w600))),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: most == 0 ? 0 : e.value / most,
                      minHeight: 14,
                      backgroundColor: context.palette.track,
                      color: muscleColors[e.key],
                    ),
                  ),
                ),
                SizedBox(width: 36, child: Text('${e.value}', textAlign: TextAlign.right)),
              ],
            ),
          ),
      ],
    );
  }
}

class _RecordTile extends StatelessWidget {
  const _RecordTile({required this.repository, required this.record});

  final TrainingRepository repository;
  final ExerciseRecord record;

  @override
  Widget build(BuildContext context) {
    final exercise = repository.exerciseById(record.exerciseId);
    if (exercise == null) return const SizedBox.shrink();
    final best = record.best;
    final headline = best.bodyweight ? '${best.maxReps} Wdh.' : '≈ ${formatKg(best.bestOneRepMax.roundToDouble())} kg';
    final gain = record.improvement;
    final since = record.sessionCount < 2
        ? 'Erstes Training'
        : gain > 0
            ? '+${best.bodyweight ? gain.round() : formatKg((gain * 10).round() / 10)}'
                '${best.bodyweight ? ' Wdh.' : ' kg'} seit ${formatDayShort(record.first.day)}'
            : 'Noch keine Steigerung seit ${formatDayShort(record.first.day)}';
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: context.palette.card,
        borderRadius: BorderRadius.circular(14),
        child: ListTile(
          key: Key('record-${exercise.id}'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          leading: MuscleBadge(group: exercise.muscleGroup),
          title: Text(exercise.name, style: const TextStyle(fontWeight: FontWeight.w700)),
          subtitle: Text('${formatSet(best.bestSet)} am ${formatDayShort(best.day)} · $since'),
          trailing: Text(headline, style: Theme.of(context).textTheme.titleMedium),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => ExerciseDetailScreen(repository: repository, exercise: exercise)),
          ),
        ),
      ),
    );
  }
}
