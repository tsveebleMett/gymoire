import 'package:flutter_test/flutter_test.dart';
import 'package:gymoire/app.dart';
import 'package:gymoire/data/training_repository.dart';
import 'package:gymoire/data/training_store.dart';
import 'package:gymoire/ui/theme.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  final now = DateTime(2026, 11, 22, 18, 30);

  Future<void> pumpWith(WidgetTester tester, Brightness brightness) async {
    tester.platformDispatcher.platformBrightnessTestValue = brightness;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    final repo = await TrainingRepository.open(MemoryTrainingStore(), clock: () => now);
    repo.addSet(exerciseId: 'squat', weightKg: 80, reps: 5);
    await tester.pumpWidget(GymoireApp(repository: repo));
    await tester.pumpAndSettle();
  }

  Color scaffoldColor(WidgetTester tester) =>
      Theme.of(tester.element(find.byType(Scaffold).first)).scaffoldBackgroundColor;

  testWidgets('follows the system dark mode', (tester) async {
    await pumpWith(tester, Brightness.dark);
    expect(scaffoldColor(tester), BookPalette.night.background);
    expect(Theme.of(tester.element(find.byType(Scaffold).first)).brightness, Brightness.dark);
  });

  testWidgets('uses the light palette in light mode', (tester) async {
    await pumpWith(tester, Brightness.light);
    expect(scaffoldColor(tester), BookPalette.light.background);
  });

  testWidgets('switches when the system setting changes', (tester) async {
    await pumpWith(tester, Brightness.light);
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    await tester.pumpAndSettle();
    expect(scaffoldColor(tester), BookPalette.night.background);
  });
}
