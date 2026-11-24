// Renders the brand mark and the lockup with the wordmark to docs/brand/:
//
//   flutter test tool/render_brand_test.dart
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymoire/ui/brand_mark.dart';
import 'package:material_ui/material_ui.dart';

/// Tests render text with a placeholder font; load the app's handwriting
/// font for the wordmark.
Future<void> _loadCaveat() async {
  final loader = FontLoader('Caveat')
    ..addFont(File('assets/fonts/Caveat-Variable.ttf').readAsBytes().then((b) => ByteData.sublistView(b)));
  await loader.load();
}

Future<void> _save(String path, Size size, void Function(Canvas) draw) async {
  final recorder = ui.PictureRecorder();
  draw(Canvas(recorder));
  final image = await recorder.endRecording().toImage(size.width.toInt(), size.height.toInt());
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  final file = File(path);
  await file.parent.create(recursive: true);
  await file.writeAsBytes(bytes!.buffer.asUint8List());
}

void _lockup(Canvas canvas, Color background, Color mark, Color text) {
  canvas.drawRect(const Rect.fromLTWH(0, 0, 1400, 400), Paint()..color = background);
  canvas.save();
  canvas.translate(90, 60);
  GymoireMarkPainter(color: mark).paint(canvas, const Size(280, 280));
  canvas.restore();
  final word = TextPainter(
    text: TextSpan(
      text: 'Gymoire',
      style: TextStyle(fontFamily: 'Caveat', fontSize: 230, fontWeight: FontWeight.w700, color: text),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  word.paint(canvas, Offset(420, 200 - word.height / 2));
  // Hand-drawn underline under the word.
  final w = word.width;
  canvas.drawPath(
    Path()
      ..moveTo(430, 346)
      ..quadraticBezierTo(430 + w * 0.45, 326, 420 + w, 340),
    Paint()
      ..color = mark
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 7,
  );
}

void main() {
  testWidgets('render brand', (tester) async {
    await tester.runAsync(() async {
      await _loadCaveat();
      await _save('docs/brand/mark.png', const Size(800, 800), (c) {
        const GymoireMarkPainter(color: Color(0xFF2A2018)).paint(c, const Size(800, 800));
      });
      await _save('docs/brand/lockup_dark.png', const Size(1400, 400), (c) {
        _lockup(c, const Color(0xFF14100C), const Color(0xFFE2B455), const Color(0xFFEDE2CB));
      });
      await _save('docs/brand/lockup_light.png', const Size(1400, 400), (c) {
        _lockup(c, const Color(0xFFF3E7CC), const Color(0xFFA8322A), const Color(0xFF2A2018));
      });
    });
  });
}
