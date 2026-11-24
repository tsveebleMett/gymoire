// Renders the logo layers to assets/logo/*.png. Run after changing
// lib/ui/logo.dart, then regenerate the launcher icons:
//
//   flutter test tool/render_logo_test.dart
//   dart run flutter_launcher_icons
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:gymoire/ui/logo.dart';
import 'package:material_ui/material_ui.dart';

const _size = 1024.0;

Future<void> _render(String path, LogoLayer layer, {Rect? crop}) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  final source = crop ?? const Rect.fromLTWH(0, 0, _size, _size);
  // Scale so that `source` fills the output.
  canvas.scale(_size / source.width);
  canvas.translate(-source.left, -source.top);
  GymoireLogoPainter(layer: layer).paint(canvas, const Size(_size, _size));
  final image = await recorder.endRecording().toImage(_size.toInt(), _size.toInt());
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  final file = File(path);
  await file.parent.create(recursive: true);
  await file.writeAsBytes(bytes!.buffer.asUint8List());
}

void main() {
  testWidgets('render logo', (tester) async {
    await tester.runAsync(() async {
      // Full icon cropped to the 72/108 part a launcher shows (iOS, legacy Android, store).
      const inset = _size * 18 / 108;
      await _render('assets/logo/icon.png', LogoLayer.full, crop: const Rect.fromLTRB(inset, inset, _size - inset, _size - inset));
      await _render('assets/logo/foreground.png', LogoLayer.foreground);
      await _render('assets/logo/background.png', LogoLayer.background);
      await _render('assets/logo/monochrome.png', LogoLayer.monochrome);
    });
  });
}
