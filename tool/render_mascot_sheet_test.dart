// Renders a sheet of Bench Mark variants to docs/mascot/bench_mark_sheet.png,
// to review the character and to show what the parts system can do:
//
//   flutter test tool/render_mascot_sheet_test.dart
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymoire/domain/mascot.dart';
import 'package:gymoire/ui/bench_mark.dart';
import 'package:gymoire/ui/mascot/bench_mark_painter.dart';
import 'package:material_ui/material_ui.dart';

const _cell = 360.0;
const _columns = 4;

final _variants = <(String, MarkLook)>[
  ('Bereit', BenchMark.lookFor(MascotMood.ready)),
  ('Stolz', BenchMark.lookFor(MascotMood.proud)),
  ('Bestleistung', BenchMark.lookFor(MascotMood.record)),
  ('Ruhetag', BenchMark.lookFor(MascotMood.resting)),
  ('Bizeps', const MarkLook(pose: MarkPose.flex, face: MarkFace.focused, effect: MarkEffect.sweat)),
  ('Freude', const MarkLook(pose: MarkPose.flex, face: MarkFace.joy, effect: MarkEffect.sparkles)),
  ('Team Blau', const MarkLook(pose: MarkPose.stand, face: MarkFace.joy, shorts: Color(0xFF2F4A6E), gear: Color(0xFFC9962E))),
  ('Chronist', const MarkLook(pose: MarkPose.stand, quill: true, belt: false, gear: Color(0xFF4E7A3A))),
];

/// Tests render text with a placeholder font; load the app's handwriting
/// font for the labels.
Future<void> _loadCaveat() async {
  final loader = FontLoader('Caveat')
    ..addFont(File('assets/fonts/Caveat-Variable.ttf').readAsBytes().then((b) => ByteData.sublistView(b)));
  await loader.load();
}

void main() {
  testWidgets('render mascot sheet', (tester) async {
    await tester.runAsync(() async {
      await _loadCaveat();
      final rows = (_variants.length / _columns).ceil();
      final width = _cell * _columns;
      final height = (_cell + 50) * rows;
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      canvas.drawRect(Rect.fromLTWH(0, 0, width, height), Paint()..color = const Color(0xFFF3E7CC));
      for (final (i, (label, look)) in _variants.indexed) {
        final x = (i % _columns) * _cell;
        final y = (i ~/ _columns) * (_cell + 50);
        canvas.save();
        canvas.translate(x, y);
        BenchMarkPainter(look, frame: const Rect.fromLTWH(-10, -10, 220, 220)).paint(canvas, const Size(_cell, _cell));
        canvas.restore();
        final text = TextPainter(
          text: TextSpan(
            text: label,
            style: const TextStyle(fontFamily: 'Caveat', fontSize: 38, fontWeight: FontWeight.w700, color: Color(0xFF2A2018)),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        text.paint(canvas, Offset(x + (_cell - text.width) / 2, y + _cell - 4));
      }
      final image = await recorder.endRecording().toImage(width.toInt(), height.toInt());
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      final file = File('docs/mascot/bench_mark_sheet.png');
      await file.parent.create(recursive: true);
      await file.writeAsBytes(bytes!.buffer.asUint8List());
    });
  });
}
