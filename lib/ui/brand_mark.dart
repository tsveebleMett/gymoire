import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

/// The Gymoire mark: the mascot's head over a barbell inside a double ring,
/// like a seal or the sigil on the cover of an old grimoire. Four small
/// diamonds tie the rings together. Eyes, brows, inner ears and snout are
/// negative space. One color, so it works in any size, on any background,
/// embossed in gold on the app icon and as a themed icon.
///
/// Drawn on a 100 × 100 grid.
class GymoireMarkPainter extends CustomPainter {
  const GymoireMarkPainter({this.color = const Color(0xFFC9962E)});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 100, size.height / 100);
    canvas.saveLayer(const Rect.fromLTWH(-5, -5, 110, 110), Paint());

    final fill = Paint()
      ..isAntiAlias = true
      ..color = color;
    Paint line(double width, {bool cut = false}) => Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round
      ..color = color
      ..blendMode = cut ? BlendMode.clear : BlendMode.srcOver;
    final clear = Paint()..blendMode = BlendMode.clear;
    const c = Offset(50, 50);

    // Seal rings and the four diamonds between them.
    canvas.drawCircle(c, 46, line(4));
    canvas.drawCircle(c, 40.2, line(1.4));
    for (var i = 0; i < 4; i++) {
      final a = i * math.pi / 2 - math.pi / 2;
      final m = c + Offset(math.cos(a), math.sin(a)) * 43.1;
      final along = Offset(math.cos(a), math.sin(a));
      final across = Offset(-along.dy, along.dx);
      canvas.drawPath(
        Path()
          ..addPolygon([m + along * 4.2, m + across * 2.6, m - along * 4.2, m - across * 2.6], true),
        fill,
      );
    }

    // The mascot's head, drawn on his 200 grid: small ears, a broad skull
    // with ruffled cheek fur, a long snout and heavy brows.
    canvas.save();
    canvas.translate(-25, 13);
    canvas.scale(0.75);
    for (final x in [78.0, 122.0]) {
      canvas.drawCircle(Offset(x, 22), 9.5, fill);
      canvas.drawCircle(Offset(x + (x < 100 ? 1 : -1), 23), 4, clear);
    }
    canvas.drawPath(
      Path()
        ..moveTo(100, 16)
        ..cubicTo(118, 16, 128, 26, 129, 38)
        ..lineTo(136, 42)
        ..lineTo(130, 46)
        ..lineTo(135, 52)
        ..lineTo(127, 55)
        ..lineTo(130, 61)
        ..lineTo(120, 63)
        ..cubicTo(114, 70, 107, 72, 100, 72)
        ..cubicTo(93, 72, 86, 70, 80, 63)
        ..lineTo(70, 61)
        ..lineTo(73, 55)
        ..lineTo(65, 52)
        ..lineTo(70, 46)
        ..lineTo(64, 42)
        ..lineTo(71, 38)
        ..cubicTo(72, 26, 82, 16, 100, 16)
        ..close(),
      fill,
    );
    // Snout as negative space, nose and grin inside it.
    canvas.drawPath(
      Path()
        ..moveTo(93, 41)
        ..lineTo(107, 41)
        ..quadraticBezierTo(117, 52, 115, 62)
        ..quadraticBezierTo(100, 71, 85, 62)
        ..quadraticBezierTo(83, 52, 93, 41)
        ..close(),
      clear,
    );
    canvas.drawPath(
      Path()
        ..moveTo(90, 49)
        ..quadraticBezierTo(100, 44, 110, 49)
        ..quadraticBezierTo(109, 57, 100, 58)
        ..quadraticBezierTo(91, 57, 90, 49)
        ..close(),
      fill,
    );
    canvas.drawPath(
      Path()
        ..moveTo(100, 57)
        ..lineTo(100, 61)
        ..moveTo(88, 61)
        ..quadraticBezierTo(100, 68, 113, 59),
      line(2.6),
    );
    // Eyes under heavy, determined brows.
    for (final x in [86.0, 114.0]) {
      canvas.drawCircle(Offset(x, 41), 3.6, clear);
    }
    for (final points in const [
      [Offset(79, 31), Offset(96, 35), Offset(96, 39.5), Offset(80, 36)],
      [Offset(121, 31), Offset(104, 35), Offset(104, 39.5), Offset(120, 36)],
    ]) {
      canvas.drawPath(Path()..addPolygon(points, true), clear);
    }
    canvas.restore();

    // Barbell under the head.
    canvas.drawLine(const Offset(31, 80), const Offset(69, 80), line(2.4));
    for (final x in [37.0, 63.0]) {
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(x, 80), width: 4.6, height: 10), const Radius.circular(1.2)), fill);
    }
    for (final x in [41.5, 58.5]) {
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(x, 80), width: 2.6, height: 6.5), const Radius.circular(1)), fill);
    }

    canvas.restore();
    canvas.restore();
  }

  @override
  bool shouldRepaint(GymoireMarkPainter old) => old.color != color;
}
