import '../domain/models.dart';

const weekdayShort = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];
const weekdayLong = ['Montag', 'Dienstag', 'Mittwoch', 'Donnerstag', 'Freitag', 'Samstag', 'Sonntag'];
const monthNames = [
  'Januar', 'Februar', 'März', 'April', 'Mai', 'Juni', //
  'Juli', 'August', 'September', 'Oktober', 'November', 'Dezember',
];

/// "12,5" or "80": German decimal comma, no trailing ",0".
String formatKg(double kg) {
  final rounded = (kg * 100).round() / 100;
  if (rounded == rounded.roundToDouble()) return rounded.toInt().toString();
  return rounded.toStringAsFixed(rounded * 10 == (rounded * 10).roundToDouble() ? 1 : 2).replaceAll('.', ',');
}

/// Accepts "82,5" and "82.5"; null for anything else or values <= 0.
double? parseKg(String text) {
  final value = double.tryParse(text.trim().replaceAll(',', '.'));
  return value == null || value < 0 ? null : value;
}

/// "80 kg × 8" or "× 12" for bodyweight sets.
String formatSet(LoggedSet s) => s.weightKg > 0 ? '${formatKg(s.weightKg)} kg × ${s.reps}' : '× ${s.reps}';

/// "Sonntag, 22. November".
String formatDayLong(DateTime d) => '${weekdayLong[d.weekday - 1]}, ${d.day}. ${monthNames[d.month - 1]}';

/// "22.11.".
String formatDayShort(DateTime d) => '${d.day}.${d.month}.';

/// "Heute", "Gestern" or the long date.
String formatDayRelative(DateTime d, DateTime now) {
  if (sameDay(d, now)) return 'Heute';
  if (sameDay(d, DateTime(now.year, now.month, now.day - 1))) return 'Gestern';
  return formatDayLong(d);
}
