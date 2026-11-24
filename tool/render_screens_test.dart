// Renders the today and weight screens in light and dark mode with sample
// data to docs/screens/, to review the design without a device:
//
//   flutter test tool/render_screens_test.dart
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymoire/app.dart';
import 'package:gymoire/data/training_repository.dart';
import 'package:gymoire/data/training_store.dart';
import 'package:material_ui/material_ui.dart';

/// Widget tests use a placeholder font; load the app's fonts and the
/// Material icons.
Future<void> _loadFonts() async {
  Future<void> load(String family, String path) async {
    final file = File(path);
    if (!file.existsSync()) return;
    final loader = FontLoader(family)..addFont(file.readAsBytes().then((b) => ByteData.sublistView(b)));
    await loader.load();
  }

  await load('Caveat', 'assets/fonts/Caveat-Variable.ttf');
  await load('CrimsonPro', 'assets/fonts/CrimsonPro-Variable.ttf');
  final root = Platform.environment['FLUTTER_ROOT'];
  if (root != null) await load('MaterialIcons', '$root/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf');
}

void main() {
  final now = DateTime(2026, 11, 24, 18, 30);

  for (final brightness in Brightness.values) {
    testWidgets('render screens ${brightness.name}', (tester) async {
      await tester.runAsync(_loadFonts);
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.6;
      addTearDown(tester.view.reset);
      tester.platformDispatcher.platformBrightnessTestValue = brightness;
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

      final repo = await TrainingRepository.open(MemoryTrainingStore(), clock: () => now);
      repo.addSet(exerciseId: 'bench_press', weightKg: 60, reps: 8, day: DateTime(2026, 11, 17));
      repo.addSet(exerciseId: 'bench_press', weightKg: 65, reps: 8);
      repo.addSet(exerciseId: 'bench_press', weightKg: 65, reps: 7);
      repo.addSet(exerciseId: 'squat', weightKg: 80, reps: 5);
      repo.setBodyWeight(DateTime(2026, 11, 5), 80.0);
      repo.setBodyWeight(DateTime(2026, 11, 22), 81.2);
      await tester.pumpWidget(RepaintBoundary(key: const Key('shot'), child: GymoireApp(repository: repo)));
      await tester.pumpAndSettle();

      Future<void> shot(String name) async {
        final boundary = tester.renderObject<RenderRepaintBoundary>(find.byKey(const Key('shot')));
        await tester.runAsync(() async {
          final image = await boundary.toImage(pixelRatio: 1);
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          final file = File('docs/screens/${name}_${brightness.name}.png');
          await file.parent.create(recursive: true);
          await file.writeAsBytes(bytes!.buffer.asUint8List());
        });
      }

      await shot('today');
      await tester.tap(find.text('Gewicht'));
      await tester.pumpAndSettle();
      await shot('weight');
    });
  }
}
