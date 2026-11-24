import 'package:material_ui/material_ui.dart';

import 'theme.dart';

/// The week's woodpile: one sawn log end per training day up to the weekly
/// goal; missing ones are pencilled in.
class LogTally extends StatelessWidget {
  const LogTally({super.key, required this.done, required this.goal, this.size = 26});

  final int done;
  final int goal;
  final double size;

  @override
  Widget build(BuildContext context) => Semantics(
        label: '$done von $goal Trainings diese Woche',
        child: CustomPaint(
          size: Size(goal * size * 1.15, size),
          painter: _TallyPainter(done.clamp(0, goal), goal, context.palette),
        ),
      );
}

class _TallyPainter extends CustomPainter {
  _TallyPainter(this.done, this.goal, this.p);

  final int done;
  final int goal;
  final BookPalette p;

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.height / 2 - 1.5;
    for (var i = 0; i < goal; i++) {
      final c = Offset(r + 1.5 + i * size.height * 1.15, size.height / 2);
      if (i < done) {
        canvas.drawCircle(c, r, Paint()..color = const Color(0xFFE2BE85));
        final ring = Paint()
          ..color = const Color(0xFFA0723F)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2;
        canvas.drawCircle(c, r * 0.62, ring);
        canvas.drawCircle(c, r * 0.28, ring);
        canvas.drawCircle(
          c,
          r,
          Paint()
            ..color = const Color(0xFF2A2018)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
        // Bark rim.
        canvas.drawArc(
          Rect.fromCircle(center: c, radius: r - 1.5),
          0.4,
          2.2,
          false,
          Paint()
            ..color = const Color(0xFF6E4A2E)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.4,
        );
      } else {
        // Pencilled outline, drawn in short dashes.
        final pencil = Paint()
          ..color = p.muted.withValues(alpha: 0.7)
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 1.4;
        const dashes = 12;
        for (var d = 0; d < dashes; d++) {
          canvas.drawArc(Rect.fromCircle(center: c, radius: r), d * 2 * 3.14159 / dashes, 0.32, false, pencil);
        }
      }
    }
  }

  @override
  bool shouldRepaint(_TallyPainter old) => old.done != done || old.goal != goal || old.p != p;
}
