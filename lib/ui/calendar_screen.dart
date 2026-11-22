import 'package:material_ui/material_ui.dart';

import '../data/training_repository.dart';
import '../domain/models.dart';
import 'day_log.dart';
import 'format.dart';
import 'theme.dart';

/// Month view of the training days. A day shows one dot per trained muscle
/// group; tapping it lists that day's workout below, where it can be edited
/// or completed. Future days cannot be selected.
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key, required this.repository});

  final TrainingRepository repository;

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _selected = dayOf(widget.repository.now());
  late DateTime _month = DateTime(_selected.year, _selected.month);

  void _shiftMonth(int delta) => setState(() => _month = DateTime(_month.year, _month.month + delta));

  @override
  Widget build(BuildContext context) {
    final repo = widget.repository;
    final today = dayOf(repo.now());
    final text = Theme.of(context).textTheme;
    final groupsByDay = <DateTime, Set<MuscleGroup>>{};
    for (final d in repo.trainedDays) {
      if (d.year == _month.year && d.month == _month.month) {
        groupsByDay[d] = {
          for (final s in repo.setsOn(d)) ?repo.exerciseById(s.exerciseId)?.muscleGroup,
        };
      }
    }
    final canGoForward = DateTime(_month.year, _month.month + 1).isBefore(today.add(const Duration(days: 1)));
    final weight = repo.bodyWeightOn(_selected);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        Row(
          children: [
            IconButton(
              key: const Key('previous-month'),
              onPressed: () => _shiftMonth(-1),
              icon: const Icon(Icons.chevron_left_rounded),
            ),
            Expanded(
              child: Text(
                '${monthNames[_month.month - 1]} ${_month.year}',
                key: const Key('month-title'),
                textAlign: TextAlign.center,
                style: text.titleLarge,
              ),
            ),
            IconButton(
              key: const Key('next-month'),
              onPressed: canGoForward ? () => _shiftMonth(1) : null,
              icon: const Icon(Icons.chevron_right_rounded),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: softSurface(),
          child: _MonthGrid(
            month: _month,
            today: today,
            selected: _selected,
            groupsByDay: groupsByDay,
            onSelect: (d) => setState(() => _selected = d),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${groupsByDay.length} Trainingstage im ${monthNames[_month.month - 1]}',
          key: const Key('month-count'),
          textAlign: TextAlign.center,
          style: text.bodyMedium,
        ),
        const SizedBox(height: 20),
        Text(formatDayRelative(_selected, today), key: const Key('selected-day'), style: text.titleLarge),
        if (weight != null) Text('Körpergewicht: ${formatKg(weight.kg)} kg', style: text.bodyLarge),
        const SizedBox(height: 12),
        DayLog(repository: repo, day: _selected, emptyText: 'An diesem Tag wurde nicht trainiert.'),
      ],
    );
  }
}

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({
    required this.month,
    required this.today,
    required this.selected,
    required this.groupsByDay,
    required this.onSelect,
  });

  final DateTime month;
  final DateTime today;
  final DateTime selected;
  final Map<DateTime, Set<MuscleGroup>> groupsByDay;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context) {
    final leading = DateTime(month.year, month.month).weekday - 1;
    final days = DateTime(month.year, month.month + 1, 0).day;
    final cells = <Widget>[
      for (final w in weekdayShort)
        Center(child: Text(w, style: const TextStyle(fontFamily: displayFont, fontWeight: FontWeight.w500))),
      for (var i = 0; i < leading; i++) const SizedBox.shrink(),
      for (var d = 1; d <= days; d++) _dayCell(DateTime(month.year, month.month, d)),
    ];
    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 0.9,
      children: cells,
    );
  }

  Widget _dayCell(DateTime day) {
    final groups = groupsByDay[day];
    final trained = groups != null;
    final future = day.isAfter(today);
    final isSelected = sameDay(day, selected);
    final isToday = sameDay(day, today);
    return GestureDetector(
      key: Key('day-${day.year}-${day.month}-${day.day}'),
      behavior: HitTestBehavior.opaque,
      onTap: future ? null : () => onSelect(day),
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Container(
          decoration: BoxDecoration(
            color: trained ? furLight : null,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? fur : (isToday ? furLight : Colors.transparent),
              width: isSelected ? 2.5 : 1.5,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${day.day}',
                style: TextStyle(
                  fontFamily: displayFont,
                  fontWeight: trained || isToday ? FontWeight.w600 : FontWeight.w400,
                  fontSize: 16,
                  color: future ? cocoa.withValues(alpha: 0.3) : cocoa,
                ),
              ),
              const SizedBox(height: 3),
              SizedBox(
                height: 7,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (final g in (groups ?? const <MuscleGroup>{}).take(4))
                      Container(
                        width: 6,
                        height: 6,
                        margin: const EdgeInsets.symmetric(horizontal: 1),
                        decoration: BoxDecoration(color: _dot(g), shape: BoxShape.circle),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Slightly darker than the pastel tint, so the dot shows on the fur-light cell.
  static Color _dot(MuscleGroup g) => Color.lerp(muscleColors[g], cocoa, 0.25)!;
}
