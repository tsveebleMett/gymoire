import 'dart:math';

import 'package:material_ui/material_ui.dart';

import '../domain/mascot.dart';
import 'theme.dart';

/// Hammy, the hamster mascot, drawn from simple shapes so there are no image
/// assets. The cheek pouches grow with the week's progress; when proud, Hammy
/// lifts the dumbbell overhead, when resting the eyes are closed.
class Hammy extends StatelessWidget {
  const Hammy({super.key, required this.mood, required this.cheeks, this.size = 120});

  final HammyMood mood;

  /// 0 to 1.
  final double cheeks;
  final double size;

  @override
  Widget build(BuildContext context) => SizedBox.square(
        dimension: size,
        child: CustomPaint(painter: _HammyPainter(mood: mood, cheeks: cheeks.clamp(0.0, 1.0))),
      );
}

class _HammyPainter extends CustomPainter {
  _HammyPainter({required this.mood, required this.cheeks});

  final HammyMood mood;
  final double cheeks;

  static const _ink = Color(0xFF3A2212);
  static const _pink = Color(0xFFF7A6A6);
  static const _belly = Color(0xFFFFF1DE);
  static const _iron = Color(0xFF5B6470);

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 100;
    Offset p(double x, double y) => Offset(x * s, y * s);
    final fill = Paint()..isAntiAlias = true;
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2.2 * s
      ..color = _ink;

    final lifted = mood == HammyMood.proud;
    final barY = lifted ? 14.0 : 70.0;

    // Ears.
    for (final x in [30.0, 70.0]) {
      canvas.drawCircle(p(x, 30), 10 * s, fill..color = fur);
      canvas.drawCircle(p(x, 30), 5.5 * s, fill..color = _pink);
    }

    // Body.
    canvas.drawOval(Rect.fromCenter(center: p(50, 62), width: 72 * s, height: 70 * s), fill..color = fur);
    canvas.drawOval(Rect.fromCenter(center: p(50, 72), width: 44 * s, height: 44 * s), fill..color = _belly);

    // Cheek pouches: full hamster cheeks mean a full week.
    final cheekR = (7 + 7 * cheeks) * s;
    for (final x in [24.0, 76.0]) {
      canvas.drawCircle(p(x, 56), cheekR, fill..color = furLight);
      canvas.drawCircle(p(x, 58), cheekR * 0.45, fill..color = _pink.withValues(alpha: 0.7));
    }

    // Eyes.
    for (final x in [39.0, 61.0]) {
      if (mood == HammyMood.resting) {
        canvas.drawArc(Rect.fromCircle(center: p(x, 46), radius: 4 * s), 0.2, pi - 0.4, false, line);
      } else {
        canvas.drawCircle(p(x, 46), 4.2 * s, fill..color = _ink);
        canvas.drawCircle(p(x + 1.4, 44.6), 1.4 * s, fill..color = Colors.white);
      }
    }

    // Nose and mouth.
    canvas.drawOval(Rect.fromCenter(center: p(50, 53), width: 6 * s, height: 4.2 * s), fill..color = _pink);
    final mouth = Path()
      ..moveTo(45 * s, 57 * s)
      ..quadraticBezierTo(47.5 * s, 60 * s, 50 * s, 57 * s)
      ..quadraticBezierTo(52.5 * s, 60 * s, 55 * s, 57 * s);
    canvas.drawPath(mouth, line..strokeWidth = 1.6 * s);
    line.strokeWidth = 2.2 * s;

    // Headband.
    canvas.drawArc(
      Rect.fromCenter(center: p(50, 52), width: 64 * s, height: 46 * s),
      pi + 0.55,
      pi - 1.1,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.5 * s
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFFE5484D),
    );

    // Dumbbell with paws holding it.
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: p(50, barY), width: 58 * s, height: 3.6 * s), Radius.circular(2 * s)),
      fill..color = _iron,
    );
    for (final x in [19.0, 81.0]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromCenter(center: p(x, barY), width: 8 * s, height: 18 * s), Radius.circular(3 * s)),
        fill..color = _iron,
      );
    }
    if (lifted) {
      // Arms raised from the shoulders to the bar.
      final arm = Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 7 * s
        ..color = fur;
      canvas.drawLine(p(26, 44), p(32, barY + 2), arm);
      canvas.drawLine(p(74, 44), p(68, barY + 2), arm);
    }
    for (final x in [32.0, 68.0]) {
      canvas.drawCircle(p(x, barY), 5 * s, fill..color = furLight);
    }

    if (mood == HammyMood.resting) {
      final z = TextPainter(
        text: TextSpan(
          text: 'z z',
          style: TextStyle(fontFamily: displayFont, fontSize: 13 * s, fontWeight: FontWeight.w600, color: _ink),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      z.paint(canvas, p(74, 6));
    }
  }

  @override
  bool shouldRepaint(_HammyPainter old) => old.mood != mood || old.cheeks != cheeks;
}
