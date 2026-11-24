/// Core data of Gymoire. Pure Dart, no Flutter imports.
library;

enum MuscleGroup { chest, back, legs, shoulders, arms, core }

const muscleGroupLabels = {
  MuscleGroup.chest: 'Brust',
  MuscleGroup.back: 'Rücken',
  MuscleGroup.legs: 'Beine',
  MuscleGroup.shoulders: 'Schultern',
  MuscleGroup.arms: 'Arme',
  MuscleGroup.core: 'Rumpf',
};

class Exercise {
  const Exercise({required this.id, required this.name, required this.muscleGroup, this.custom = false});

  final String id;
  final String name;
  final MuscleGroup muscleGroup;

  /// Created by the user instead of coming from the built-in catalog.
  final bool custom;

  Map<String, Object?> toJson() => {'id': id, 'name': name, 'muscleGroup': muscleGroup.name};

  factory Exercise.fromJson(Map<String, Object?> json) => Exercise(
        id: json['id'] as String,
        name: json['name'] as String,
        muscleGroup: MuscleGroup.values.byName(json['muscleGroup'] as String),
        custom: true,
      );
}

/// One performed set. Sets of the same calendar day form that day's workout.
class LoggedSet {
  const LoggedSet({required this.id, required this.exerciseId, required this.weightKg, required this.reps, required this.at});

  final String id;
  final String exerciseId;

  /// 0 for bodyweight exercises.
  final double weightKg;
  final int reps;
  final DateTime at;

  double get volume => weightKg * reps;

  LoggedSet copyWith({double? weightKg, int? reps}) =>
      LoggedSet(id: id, exerciseId: exerciseId, weightKg: weightKg ?? this.weightKg, reps: reps ?? this.reps, at: at);

  Map<String, Object?> toJson() =>
      {'id': id, 'exerciseId': exerciseId, 'weightKg': weightKg, 'reps': reps, 'at': at.toIso8601String()};

  factory LoggedSet.fromJson(Map<String, Object?> json) => LoggedSet(
        id: json['id'] as String,
        exerciseId: json['exerciseId'] as String,
        weightKg: (json['weightKg'] as num).toDouble(),
        reps: json['reps'] as int,
        at: DateTime.parse(json['at'] as String),
      );
}

/// Body weight on one calendar day; a later entry on the same day replaces it.
class BodyWeight {
  const BodyWeight({required this.day, required this.kg});

  /// Local midnight of the day.
  final DateTime day;
  final double kg;

  Map<String, Object?> toJson() => {'day': day.toIso8601String(), 'kg': kg};

  factory BodyWeight.fromJson(Map<String, Object?> json) =>
      BodyWeight(day: DateTime.parse(json['day'] as String), kg: (json['kg'] as num).toDouble());
}

DateTime dayOf(DateTime t) => DateTime(t.year, t.month, t.day);

bool sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;
