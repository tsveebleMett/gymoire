import 'package:material_ui/material_ui.dart';

import '../domain/mascot.dart';
import 'mascot/bench_mark_look.dart';
import 'mascot/bench_mark_painter.dart';

export 'mascot/bench_mark_look.dart';

/// Bench Mark, the bear who keeps your training memoirs, drawn like an ink
/// sketch in a book and built from parts (see [MarkLook]).
class BenchMark extends StatelessWidget {
  BenchMark({super.key, required MascotMood mood, this.size = 120}) : look = lookFor(mood);

  const BenchMark.look(this.look, {super.key, this.size = 120});

  final MarkLook look;
  final double size;

  /// The look for each mood of the home screen.
  static MarkLook lookFor(MascotMood mood) => switch (mood) {
        MascotMood.ready => const MarkLook(pose: MarkPose.stand),
        MascotMood.proud => const MarkLook(pose: MarkPose.carry, effect: MarkEffect.sweat),
        MascotMood.record => const MarkLook(pose: MarkPose.lift, face: MarkFace.joy, effect: MarkEffect.sparkles),
        MascotMood.resting => const MarkLook(pose: MarkPose.rest, face: MarkFace.sleepy, effect: MarkEffect.zzz),
      };

  @override
  Widget build(BuildContext context) => SizedBox.square(
        dimension: size,
        child: CustomPaint(painter: BenchMarkPainter(look)),
      );
}

/// Bench Mark on a parchment plate, slightly askew and held by two strips
/// of tape, like a drawing pasted into the book. The plate stays light in
/// dark mode, so the ink drawing always reads.
class MarkPlate extends StatelessWidget {
  const MarkPlate({super.key, required this.child, this.color = const Color(0xFFF3E7CC), this.angle = -0.035});

  final Widget child;
  final Color color;
  final double angle;

  @override
  Widget build(BuildContext context) => Transform.rotate(
        angle: angle,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
                boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 6, offset: Offset(1, 2))],
              ),
              child: child,
            ),
            for (final (left, turn) in [(-8.0, -0.6), (null, 0.6)])
              Positioned(
                top: -6,
                left: left,
                right: left == null ? -8 : null,
                child: Transform.rotate(
                  angle: turn,
                  child: Container(width: 34, height: 12, color: const Color(0x66E8DDB5)),
                ),
              ),
          ],
        ),
      );
}
