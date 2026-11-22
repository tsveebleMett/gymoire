import 'models.dart';

/// Built-in exercises. Ids are stable because logged sets refer to them.
const exerciseCatalog = [
  // Chest
  Exercise(id: 'bench_press', name: 'Bankdrücken (Langhantel)', muscleGroup: MuscleGroup.chest),
  Exercise(id: 'incline_db_press', name: 'Schrägbankdrücken (Kurzhantel)', muscleGroup: MuscleGroup.chest),
  Exercise(id: 'chest_press_machine', name: 'Brustpresse (Maschine)', muscleGroup: MuscleGroup.chest),
  Exercise(id: 'butterfly', name: 'Butterfly (Maschine)', muscleGroup: MuscleGroup.chest),
  Exercise(id: 'cable_fly', name: 'Kabelzug-Flys', muscleGroup: MuscleGroup.chest),
  Exercise(id: 'dips', name: 'Dips', muscleGroup: MuscleGroup.chest),
  Exercise(id: 'push_up', name: 'Liegestütze', muscleGroup: MuscleGroup.chest),
  // Back
  Exercise(id: 'deadlift', name: 'Kreuzheben', muscleGroup: MuscleGroup.back),
  Exercise(id: 'barbell_row', name: 'Langhantelrudern', muscleGroup: MuscleGroup.back),
  Exercise(id: 'db_row', name: 'Einarmiges Kurzhantelrudern', muscleGroup: MuscleGroup.back),
  Exercise(id: 'lat_pulldown', name: 'Latzug', muscleGroup: MuscleGroup.back),
  Exercise(id: 'seated_cable_row', name: 'Rudern am Kabel (sitzend)', muscleGroup: MuscleGroup.back),
  Exercise(id: 'pull_up', name: 'Klimmzüge', muscleGroup: MuscleGroup.back),
  Exercise(id: 'back_extension', name: 'Rückenstrecker', muscleGroup: MuscleGroup.back),
  // Legs
  Exercise(id: 'squat', name: 'Kniebeuge (Langhantel)', muscleGroup: MuscleGroup.legs),
  Exercise(id: 'leg_press', name: 'Beinpresse', muscleGroup: MuscleGroup.legs),
  Exercise(id: 'romanian_deadlift', name: 'Rumänisches Kreuzheben', muscleGroup: MuscleGroup.legs),
  Exercise(id: 'leg_extension', name: 'Beinstrecker', muscleGroup: MuscleGroup.legs),
  Exercise(id: 'leg_curl', name: 'Beinbeuger', muscleGroup: MuscleGroup.legs),
  Exercise(id: 'lunges', name: 'Ausfallschritte', muscleGroup: MuscleGroup.legs),
  Exercise(id: 'hip_thrust', name: 'Hip Thrust', muscleGroup: MuscleGroup.legs),
  Exercise(id: 'calf_raise', name: 'Wadenheben', muscleGroup: MuscleGroup.legs),
  // Shoulders
  Exercise(id: 'overhead_press', name: 'Schulterdrücken (Langhantel)', muscleGroup: MuscleGroup.shoulders),
  Exercise(id: 'db_shoulder_press', name: 'Schulterdrücken (Kurzhantel)', muscleGroup: MuscleGroup.shoulders),
  Exercise(id: 'lateral_raise', name: 'Seitheben', muscleGroup: MuscleGroup.shoulders),
  Exercise(id: 'face_pull', name: 'Face Pulls', muscleGroup: MuscleGroup.shoulders),
  Exercise(id: 'reverse_fly', name: 'Reverse Butterfly', muscleGroup: MuscleGroup.shoulders),
  // Arms
  Exercise(id: 'barbell_curl', name: 'Bizepscurls (Langhantel)', muscleGroup: MuscleGroup.arms),
  Exercise(id: 'db_curl', name: 'Bizepscurls (Kurzhantel)', muscleGroup: MuscleGroup.arms),
  Exercise(id: 'hammer_curl', name: 'Hammercurls', muscleGroup: MuscleGroup.arms),
  Exercise(id: 'triceps_pushdown', name: 'Trizepsdrücken am Kabel', muscleGroup: MuscleGroup.arms),
  Exercise(id: 'skull_crusher', name: 'French Press', muscleGroup: MuscleGroup.arms),
  // Core
  Exercise(id: 'plank', name: 'Unterarmstütz (Plank)', muscleGroup: MuscleGroup.core),
  Exercise(id: 'crunch_machine', name: 'Crunch-Maschine', muscleGroup: MuscleGroup.core),
  Exercise(id: 'hanging_leg_raise', name: 'Hängendes Beinheben', muscleGroup: MuscleGroup.core),
  Exercise(id: 'cable_crunch', name: 'Kabel-Crunch', muscleGroup: MuscleGroup.core),
];

/// Case- and umlaut-insensitive search by name words, e.g. "bank kurz".
List<Exercise> searchExercises(Iterable<Exercise> exercises, String query, {MuscleGroup? group}) {
  final words = _normalize(query).split(' ').where((w) => w.isNotEmpty).toList();
  return [
    for (final e in exercises)
      if ((group == null || e.muscleGroup == group) && words.every(_normalize(e.name).contains)) e,
  ]..sort((a, b) => a.name.compareTo(b.name));
}

String _normalize(String s) => s
    .toLowerCase()
    .replaceAll('ä', 'ae')
    .replaceAll('ö', 'oe')
    .replaceAll('ü', 'ue')
    .replaceAll('ß', 'ss')
    .replaceAll(RegExp(r'[^a-z0-9 ]'), ' ');
