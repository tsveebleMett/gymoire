import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import 'bench_mark_look.dart';

// Iron-gall ink and watercolor washes, as if drawn into the book. The
// drawing keeps its dark ink in both themes; dark mode shows it on a
// parchment plate.
const ink = Color(0xFF2A2018);
const _fur = Color(0xFF8A5532);
const _furShade = Color(0xFF63391F);
const _furLight = Color(0xFFA9714A);
const _muzzle = Color(0xFFC9A274);
const _muzzleShade = Color(0xFFA27E52);
const _mouthInside = Color(0xFF4A1612);
const _tongue = Color(0xFFC8553F);
const _leather = Color(0xFF5B3322);
const _gold = Color(0xFFC9962E);
const _bark = Color(0xFF6E4A2E);
const _woodEnd = Color(0xFFE2BE85);
const _rings = Color(0xFFA0723F);
const _feather = Color(0xFFF4ECDD);
const _sweat = Color(0xFF7FA3C2);

const _line = 3.0;

/// One arm: shoulder, elbow and fist on the 200 grid. [flexed] makes the
/// biceps peak.
class _Arm {
  const _Arm(this.shoulder, this.elbow, this.fist, {this.flexed = false});

  final Offset shoulder;
  final Offset elbow;
  final Offset fist;
  final bool flexed;
}

const _leftHip = _Arm(Offset(50, 90), Offset(26, 118), Offset(66, 144));
const _rightHip = _Arm(Offset(150, 90), Offset(174, 118), Offset(134, 144));

/// (left arm, right arm) as seen by the viewer.
(_Arm, _Arm) _arms(MarkPose pose) => switch (pose) {
      MarkPose.stand => (_leftHip, _rightHip),
      MarkPose.carry => (_leftHip, const _Arm(Offset(150, 90), Offset(180, 96), Offset(166, 62))),
      MarkPose.lift => (
          const _Arm(Offset(50, 88), Offset(24, 58), Offset(44, 20)),
          const _Arm(Offset(150, 88), Offset(176, 58), Offset(156, 20)),
        ),
      MarkPose.flex => (
          const _Arm(Offset(50, 88), Offset(16, 86), Offset(28, 48), flexed: true),
          const _Arm(Offset(150, 88), Offset(184, 86), Offset(172, 48), flexed: true),
        ),
      MarkPose.rest => (
          const _Arm(Offset(50, 90), Offset(38, 122), Offset(46, 152)),
          const _Arm(Offset(150, 90), Offset(162, 122), Offset(154, 152)),
        ),
    };

/// Draws the mascot, a bear built like a gym strongman, as an ink sketch on
/// a 200 × 200 grid scaled to the canvas: broad shoulders and a narrow
/// waist, big arms, a lifting belt and gym shorts; dark outlines with a
/// faint second pen line, watercolor washes and hatching on the shadow
/// side.
class BenchMarkPainter extends CustomPainter {
  const BenchMarkPainter(this.look, {this.frame});

  final MarkLook look;

  /// Part of the 200 grid to fit into the canvas; the whole grid by default.
  final Rect? frame;

  @override
  void paint(Canvas canvas, Size size) {
    final source = frame ?? const Rect.fromLTWH(0, 0, 200, 200);
    canvas.save();
    canvas.scale(size.width / source.width, size.height / source.height);
    canvas.translate(-source.left, -source.top);
    final pen = _Pen(canvas);
    final (left, right) = _arms(look.pose);

    // Ground: a quick pen stroke.
    pen.stroke(
      Path()
        ..moveTo(48, 197)
        ..quadraticBezierTo(100, 193, 152, 197),
      ink.withValues(alpha: 0.45),
      2,
    );
    if (look.pose == MarkPose.rest) _logPile(pen);
    _legs(pen);
    _shorts(pen);
    _torso(pen);
    if (look.belt) _belt(pen);
    if (look.pose == MarkPose.carry) _log(pen, const Offset(56, 84), const Offset(190, 50), 12);
    if (look.quill) _quill(pen);
    _head(pen);
    _arm(pen, left, fist: look.pose != MarkPose.lift);
    _arm(pen, right, fist: look.pose != MarkPose.lift && look.pose != MarkPose.carry);
    if (look.pose == MarkPose.lift) {
      _log(pen, const Offset(14, 18), const Offset(188, 14), 12);
      _fist(pen, left.fist);
      _fist(pen, right.fist);
    }
    if (look.pose == MarkPose.carry) _fist(pen, right.fist);
    _effect(pen);
    canvas.restore();
  }

  // ---------------------------------------------------------------- body

  void _legs(_Pen pen) {
    for (final x in [83.0, 117.0]) {
      final leg = Path()..addRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(x, 178), width: 30, height: 28), const Radius.circular(11)));
      pen.shape(leg, _fur, shade: _furShade);
      // Calf.
      pen.stroke(Path()..addArc(Rect.fromCenter(center: Offset(x, 180), width: 20, height: 14), math.pi * 0.15, math.pi * 0.7), ink.withValues(alpha: 0.6), 1.6);
      final fx = x + (x < 100 ? -3 : 3);
      final foot = Path()..addOval(Rect.fromCenter(center: Offset(fx, 191), width: 38, height: 13));
      pen.shape(foot, _fur, shade: _furShade, hatch: true);
      for (final dx in [-8.0, 0.0, 8.0]) {
        pen.stroke(
          Path()
            ..moveTo(fx + dx, 186)
            ..lineTo(fx + dx, 191),
          ink,
          1.8,
        );
      }
    }
  }

  void _shorts(_Pen pen) {
    final shorts = Path()
      ..moveTo(70, 148)
      ..lineTo(130, 148)
      ..lineTo(136, 172)
      ..lineTo(104, 175)
      ..lineTo(100, 166)
      ..lineTo(96, 175)
      ..lineTo(64, 172)
      ..close();
    pen.shape(shorts, look.shorts, shade: _darker(look.shorts), hatch: true);
    // Side stripes.
    for (final (a, b) in [(const Offset(74, 150), const Offset(70, 171)), (const Offset(126, 150), const Offset(130, 171))]) {
      pen.stroke(
        Path()
          ..moveTo(a.dx, a.dy)
          ..lineTo(b.dx, b.dy),
        look.gear,
        3,
      );
    }
  }

  void _torso(_Pen pen) {
    // A strong V: traps, wide shoulders and lats, narrow waist.
    final body = Path()
      ..moveTo(86, 60)
      ..quadraticBezierTo(66, 70, 50, 77)
      ..quadraticBezierTo(36, 84, 38, 98)
      ..quadraticBezierTo(44, 120, 62, 132)
      ..quadraticBezierTo(70, 140, 71, 152)
      ..lineTo(129, 152)
      ..quadraticBezierTo(130, 140, 138, 132)
      ..quadraticBezierTo(156, 120, 162, 98)
      ..quadraticBezierTo(164, 84, 150, 77)
      ..quadraticBezierTo(134, 70, 114, 60)
      ..close();
    pen.shape(body, _fur, shade: _furShade, hatch: true);
    // Lighter fur on the chest.
    pen.clip(body, () {
      pen.fill(Path()..addOval(Rect.fromCenter(center: const Offset(96, 98), width: 64, height: 30)), _furLight.withValues(alpha: 0.55));
    });
    final muscle = ink.withValues(alpha: 0.75);
    // Pecs, sternum and abs.
    pen.stroke(
      Path()
        ..moveTo(58, 90)
        ..quadraticBezierTo(64, 114, 98, 108)
        ..moveTo(142, 90)
        ..quadraticBezierTo(136, 114, 102, 108)
        ..moveTo(100, 80)
        ..lineTo(100, 106),
      muscle,
      2.2,
    );
    pen.stroke(
      Path()
        ..moveTo(100, 112)
        ..lineTo(100, 140)
        ..moveTo(87, 120)
        ..quadraticBezierTo(94, 122, 99, 119)
        ..moveTo(101, 119)
        ..quadraticBezierTo(106, 122, 113, 120)
        ..moveTo(88, 131)
        ..quadraticBezierTo(94, 133, 99, 130)
        ..moveTo(101, 130)
        ..quadraticBezierTo(106, 133, 112, 131)
        ..moveTo(78, 118)
        ..quadraticBezierTo(80, 130, 84, 139)
        ..moveTo(122, 118)
        ..quadraticBezierTo(120, 130, 116, 139),
      muscle,
      1.7,
    );
    // Collarbones.
    pen.stroke(
      Path()
        ..moveTo(70, 80)
        ..quadraticBezierTo(84, 84, 96, 80)
        ..moveTo(130, 80)
        ..quadraticBezierTo(116, 84, 104, 80),
      ink.withValues(alpha: 0.45),
      1.4,
    );
  }

  void _belt(_Pen pen) {
    final belt = Path()..addRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(68, 140, 64, 14), const Radius.circular(3)));
    pen.shape(belt, _leather, shade: _darker(_leather), width: 2.4);
    final buckle = Path()..addRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(92, 139, 16, 16), const Radius.circular(2)));
    pen.shape(buckle, _gold, width: 2);
    pen.fill(Path()..addRect(const Rect.fromLTWH(96, 143, 8, 8)), _leather);
    pen.stroke(
      Path()
        ..moveTo(100, 143)
        ..lineTo(100, 151),
      _gold,
      1.6,
    );
    // Stitching.
    for (final y in [142.5, 151.5]) {
      for (var x = 72.0; x < 128; x += 5) {
        if (x > 88 && x < 112) continue;
        pen.stroke(
          Path()
            ..moveTo(x, y)
            ..lineTo(x + 2.4, y),
          _gold.withValues(alpha: 0.7),
          0.9,
        );
      }
    }
  }

  void _quill(_Pen pen) {
    final vane = Path()
      ..moveTo(122, 32)
      ..quadraticBezierTo(126, 8, 146, -4)
      ..quadraticBezierTo(144, 16, 122, 32)
      ..close();
    pen.shape(vane, _feather, width: 2);
    pen.stroke(
      Path()
        ..moveTo(120, 36)
        ..quadraticBezierTo(132, 14, 146, -4),
      ink,
      1.5,
    );
  }

  // ---------------------------------------------------------------- head

  void _head(_Pen pen) {
    // Small, rounded ears set wide.
    for (final x in [78.0, 122.0]) {
      pen.shape(Path()..addOval(Rect.fromCircle(center: Offset(x, 22), radius: 8.5)), _fur, shade: _furShade);
      pen.fill(Path()..addOval(Rect.fromCircle(center: Offset(x + (x < 100 ? 1 : -1), 23), radius: 4)), _muzzleShade);
    }
    // Broad skull with ruffled cheek fur.
    final head = Path()
      ..moveTo(100, 16)
      ..cubicTo(118, 16, 128, 26, 129, 38)
      ..lineTo(135, 42)
      ..lineTo(130, 46)
      ..lineTo(134, 52)
      ..lineTo(127, 55)
      ..lineTo(129, 61)
      ..lineTo(120, 63)
      ..cubicTo(114, 70, 107, 72, 100, 72)
      ..cubicTo(93, 72, 86, 70, 80, 63)
      ..lineTo(71, 61)
      ..lineTo(73, 55)
      ..lineTo(66, 52)
      ..lineTo(70, 46)
      ..lineTo(65, 42)
      ..lineTo(71, 38)
      ..cubicTo(72, 26, 82, 16, 100, 16)
      ..close();
    pen.shape(head, _fur, shade: _furShade, hatch: true);
    // Long snout: a bridge between the eyes widening to the muzzle.
    final muzzle = Path()
      ..moveTo(93, 40)
      ..lineTo(107, 40)
      ..quadraticBezierTo(117, 52, 115, 62)
      ..quadraticBezierTo(100, 72, 85, 62)
      ..quadraticBezierTo(83, 52, 93, 40)
      ..close();
    pen.shape(muzzle, _muzzle, shade: _muzzleShade, width: 2.4);
    _eyes(pen);
    _brows(pen);
    _mouth(pen);
    final nose = Path()
      ..moveTo(91, 50)
      ..quadraticBezierTo(100, 45, 109, 50)
      ..quadraticBezierTo(108, 57, 100, 58)
      ..quadraticBezierTo(92, 57, 91, 50)
      ..close();
    pen.fill(nose, ink);
    pen.fill(Path()..addOval(Rect.fromCircle(center: const Offset(96.5, 49.5), radius: 1.5)), Colors.white);
  }

  void _eyes(_Pen pen) {
    for (final x in [86.0, 114.0]) {
      if (look.face == MarkFace.sleepy) {
        pen.stroke(Path()..addArc(Rect.fromCenter(center: Offset(x, 39), width: 10, height: 6), 0.15, math.pi - 0.3), ink, 2.4);
        continue;
      }
      final h = look.face == MarkFace.focused ? 4.5 : 6.5;
      pen.fill(Path()..addOval(Rect.fromCenter(center: Offset(x, 40), width: 6.5, height: h)), ink);
      pen.fill(Path()..addOval(Rect.fromCircle(center: Offset(x + 1.2, 38.8), radius: 1.3)), Colors.white);
    }
  }

  void _brows(_Pen pen) {
    // Heavy wedges; lower towards the snout for focus and grit.
    final (l, r) = switch (look.face) {
      MarkFace.determined => (
          const [Offset(76, 31), Offset(95, 35), Offset(95, 38.5), Offset(77, 35)],
          const [Offset(124, 31), Offset(105, 35), Offset(105, 38.5), Offset(123, 35)],
        ),
      MarkFace.joy => (
          const [Offset(76, 31), Offset(95, 30), Offset(95, 33.5), Offset(77, 35)],
          const [Offset(124, 31), Offset(105, 30), Offset(105, 33.5), Offset(123, 35)],
        ),
      MarkFace.focused => (
          const [Offset(76, 29), Offset(96, 36), Offset(95, 39.5), Offset(77, 33)],
          const [Offset(124, 29), Offset(104, 36), Offset(105, 39.5), Offset(123, 33)],
        ),
      MarkFace.sleepy => (
          const [Offset(77, 33), Offset(94, 33), Offset(94, 35.5), Offset(77, 35.5)],
          const [Offset(123, 33), Offset(106, 33), Offset(106, 35.5), Offset(123, 35.5)],
        ),
    };
    for (final points in [l, r]) {
      pen.fill(Path()..addPolygon(points, true), ink);
    }
  }

  void _mouth(_Pen pen) {
    switch (look.face) {
      case MarkFace.joy:
        // Open roar.
        final open = Path()
          ..moveTo(88, 60)
          ..quadraticBezierTo(100, 63, 112, 60)
          ..quadraticBezierTo(110, 76, 100, 76)
          ..quadraticBezierTo(90, 76, 88, 60)
          ..close();
        pen.fill(open, _mouthInside);
        pen.clip(open, () {
          pen.fill(Path()..addOval(Rect.fromCenter(center: const Offset(100, 75), width: 14, height: 8)), _tongue);
          pen.fill(Path()..addRect(const Rect.fromLTWH(88, 59, 24, 3.4)), Colors.white);
        });
        pen.outline(open, width: 2.2);
      case MarkFace.focused:
        final teeth = Path()..addRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(89, 60, 22, 7), const Radius.circular(2)));
        pen.shape(teeth, Colors.white, width: 2);
        for (final x in [94.5, 100.0, 105.5]) {
          pen.stroke(
            Path()
              ..moveTo(x, 60.5)
              ..lineTo(x, 66.5),
            ink,
            1.2,
          );
        }
      case MarkFace.determined:
        // Confident grin, higher on one side.
        pen.stroke(
          Path()
            ..moveTo(100, 57)
            ..lineTo(100, 61)
            ..moveTo(88, 61)
            ..quadraticBezierTo(100, 68, 113, 59),
          ink,
          2.4,
        );
      case MarkFace.sleepy:
        pen.stroke(
          Path()
            ..moveTo(100, 57)
            ..lineTo(100, 61)
            ..moveTo(95, 63)
            ..quadraticBezierTo(100, 65, 105, 63),
          ink,
          2.2,
        );
    }
  }

  // ---------------------------------------------------------------- arms

  void _arm(_Pen pen, _Arm arm, {required bool fist}) {
    final upperMid = Offset.lerp(arm.shoulder, arm.elbow, 0.5)!;
    final foreMid = Offset.lerp(arm.elbow, arm.fist, 0.45)!;
    final away = upperMid - foreMid;
    final biceps = upperMid + away / away.distance * (arm.flexed ? 8 : 4);
    pen.limb(
      [arm.shoulder, arm.elbow, arm.fist],
      _fur,
      22,
      extra: [
        // Deltoid, biceps and a thick forearm.
        (arm.shoulder, 17),
        (biceps, arm.flexed ? 16 : 13.5),
        (foreMid, 12.5),
      ],
    );
    // Deltoid edge.
    final dir = arm.elbow - arm.shoulder;
    final n = Offset(-dir.dy, dir.dx) / dir.distance;
    final d0 = arm.shoulder + dir * 0.35;
    pen.stroke(
      Path()
        ..moveTo(d0.dx + n.dx * 10, d0.dy + n.dy * 10)
        ..quadraticBezierTo(d0.dx, d0.dy, d0.dx - n.dx * 10, d0.dy - n.dy * 10),
      ink.withValues(alpha: 0.6),
      1.6,
    );
    // Elbow crease on the inside of the bend.
    final toShoulder = arm.shoulder - arm.elbow;
    final toFist = arm.fist - arm.elbow;
    final inner = toShoulder / toShoulder.distance + toFist / toFist.distance;
    if (inner.distance > 0.2) {
      final i = inner / inner.distance;
      final from = arm.elbow + i * 5;
      final to = arm.elbow + i * 15;
      pen.stroke(
        Path()
          ..moveTo(from.dx, from.dy)
          ..lineTo(to.dx, to.dy),
        ink.withValues(alpha: 0.8),
        2,
      );
    }
    // Wrist wrap.
    final a = Offset.lerp(arm.elbow, arm.fist, 0.56)!;
    final b = Offset.lerp(arm.elbow, arm.fist, 0.74)!;
    pen.band(a, b, look.gear, 22);
    if (fist) _fist(pen, arm.fist);
  }

  void _fist(_Pen pen, Offset c) {
    pen.shape(Path()..addOval(Rect.fromCircle(center: c, radius: 12.5)), _fur, shade: _furShade);
    // Knuckles.
    pen.stroke(Path()..addArc(Rect.fromCircle(center: c, radius: 7), math.pi * 1.1, math.pi * 0.8), ink, 1.8);
    for (final dx in [-4.0, 0.0, 4.0]) {
      pen.stroke(
        Path()
          ..moveTo(c.dx + dx, c.dy - 7)
          ..lineTo(c.dx + dx * 1.1, c.dy - 2),
        ink.withValues(alpha: 0.6),
        1.2,
      );
    }
  }

  // ---------------------------------------------------------------- props

  /// A log from [a] to its sawn end [b], where the growth rings show.
  void _log(_Pen pen, Offset a, Offset b, double r) {
    final dir = b - a;
    final n = Offset(-dir.dy, dir.dx) / dir.distance * r;
    final body = Path()
      ..moveTo(a.dx + n.dx, a.dy + n.dy)
      ..lineTo(b.dx + n.dx, b.dy + n.dy)
      ..lineTo(b.dx - n.dx, b.dy - n.dy)
      ..lineTo(a.dx - n.dx, a.dy - n.dy)
      ..arcToPoint(a + n, radius: Radius.circular(r), clockwise: false)
      ..close();
    pen.shape(body, _bark, shade: _darker(_bark), hatch: true);
    for (final (from, to, side) in [(0.12, 0.5, 0.45), (0.4, 0.85, -0.3), (0.2, 0.4, -0.6)]) {
      final p = Offset.lerp(a, b, from)! + n * side;
      final q = Offset.lerp(a, b, to)! + n * side;
      pen.stroke(
        Path()
          ..moveTo(p.dx, p.dy)
          ..lineTo(q.dx, q.dy),
        ink.withValues(alpha: 0.6),
        1.4,
      );
    }
    pen.rotated(b, math.atan2(n.dy, n.dx), () {
      final end = Rect.fromCenter(center: b, width: 2 * r, height: r * 1.15);
      pen.shape(Path()..addOval(end), _woodEnd, width: 2.4);
      for (final f in [0.62, 0.3]) {
        pen.stroke(Path()..addOval(Rect.fromCenter(center: b, width: 2 * r * f, height: r * 1.15 * f)), _rings, 1.2);
      }
    });
  }

  void _logPile(_Pen pen) {
    for (final (c, r) in [(const Offset(22, 186), 9.0), (const Offset(40, 186), 9.0), (const Offset(31, 171), 9.0)]) {
      pen.shape(Path()..addOval(Rect.fromCircle(center: c, radius: r)), _woodEnd, width: 2.2);
      pen.stroke(Path()..addOval(Rect.fromCircle(center: c, radius: r * 0.55)), _rings, 1.2);
      pen.fill(Path()..addOval(Rect.fromCircle(center: c, radius: 1.3)), _rings);
    }
  }

  // ---------------------------------------------------------------- effects

  void _effect(_Pen pen) {
    switch (look.effect) {
      case MarkEffect.none:
        break;
      case MarkEffect.sparkles:
        for (final (c, r) in [(const Offset(14, 74), 9.0), (const Offset(188, 74), 8.0), (const Offset(182, 124), 6.0)]) {
          pen.shape(_star(c, r), _gold, width: 1.8);
        }
      case MarkEffect.sweat:
        final drop = Path()
          ..moveTo(140, 20)
          ..quadraticBezierTo(148, 32, 145, 37)
          ..quadraticBezierTo(140, 42, 135, 37)
          ..quadraticBezierTo(132, 32, 140, 20)
          ..close();
        pen.shape(drop, _sweat, width: 1.8);
      case MarkEffect.zzz:
        for (final (c, s) in [(const Offset(146, 20), 11.0), (const Offset(164, 4), 8.0)]) {
          pen.stroke(
            Path()
              ..moveTo(c.dx - s / 2, c.dy - s / 2)
              ..lineTo(c.dx + s / 2, c.dy - s / 2)
              ..lineTo(c.dx - s / 2, c.dy + s / 2)
              ..lineTo(c.dx + s / 2, c.dy + s / 2),
            ink,
            2.6,
          );
        }
    }
  }

  Path _star(Offset c, double r) {
    final p = Path();
    for (var i = 0; i < 8; i++) {
      final angle = -math.pi / 2 + i * math.pi / 4;
      final point = c + Offset(math.cos(angle), math.sin(angle)) * (i.isEven ? r : r * 0.34);
      i == 0 ? p.moveTo(point.dx, point.dy) : p.lineTo(point.dx, point.dy);
    }
    return p..close();
  }

  Color _darker(Color c) => Color.lerp(c, ink, 0.3)!;

  @override
  bool shouldRepaint(BenchMarkPainter old) => old.look != look || old.frame != frame;
}

/// Ink-sketch drawing helper: washes, outlines with a faint second pen line
/// and hatching on the shadow side (light from the top left).
class _Pen {
  _Pen(this.canvas);

  final Canvas canvas;

  static const _light = Offset(-5, -5);

  Paint _strokePaint(Color color, double width, {bool round = true}) => Paint()
    ..isAntiAlias = true
    ..style = PaintingStyle.stroke
    ..strokeWidth = width
    ..strokeCap = round ? StrokeCap.round : StrokeCap.butt
    ..strokeJoin = StrokeJoin.round
    ..color = color;

  void fill(Path path, Color color) => canvas.drawPath(path, Paint()
    ..isAntiAlias = true
    ..color = color);

  /// The main ink line plus a thin, offset second line, as from a dip pen
  /// going over the contour twice.
  void outline(Path path, {double width = _line}) {
    canvas.drawPath(path, _strokePaint(ink, width));
    canvas.drawPath(path.shift(const Offset(0.9, -0.7)), _strokePaint(ink.withValues(alpha: 0.35), width * 0.35));
  }

  /// Wash in [color], a darker wash on the shadow side, optional hatching,
  /// then the outline.
  void shape(Path path, Color color, {Color? shade, bool hatch = false, double width = _line}) {
    if (shade == null) {
      fill(path, color);
    } else {
      fill(path, shade);
      clip(path, () => fill(path.shift(_light), color));
    }
    if (hatch) _hatch(path);
    outline(path, width: width);
  }

  void _hatch(Path path) {
    final shadow = Path.combine(PathOperation.difference, path, path.shift(const Offset(-9, -7)));
    final b = shadow.getBounds();
    if (b.isEmpty) return;
    clip(shadow, () {
      final paint = _strokePaint(ink.withValues(alpha: 0.32), 1.1);
      for (var x = b.left - b.height; x < b.right; x += 4.5) {
        canvas.drawLine(Offset(x, b.bottom), Offset(x + b.height, b.top), paint);
      }
    });
  }

  void clip(Path clip, VoidCallback draw) {
    canvas.save();
    canvas.clipPath(clip);
    draw();
    canvas.restore();
  }

  void rotated(Offset center, double angle, VoidCallback draw) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);
    canvas.translate(-center.dx, -center.dy);
    draw();
    canvas.restore();
  }

  void stroke(Path path, Color color, double width) => canvas.drawPath(path, _strokePaint(color, width));

  /// A thick straight band from [a] to [b] with square ends and an outline,
  /// e.g. a wrist wrap.
  void band(Offset a, Offset b, Color color, double width) {
    final path = Path()
      ..moveTo(a.dx, a.dy)
      ..lineTo(b.dx, b.dy);
    canvas.drawPath(path, _strokePaint(ink, width + 2 * _line, round: false));
    canvas.drawPath(path, _strokePaint(color, width, round: false));
  }

  /// A thick rounded limb through [points] with an outline, plus round
  /// [extra] parts (deltoid, biceps, forearm) merged into the same outline.
  void limb(List<Offset> points, Color color, double width, {List<(Offset, double)> extra = const []}) {
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final p in points.skip(1)) {
      path.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(path, _strokePaint(ink, width + 2 * _line));
    for (final (c, r) in extra) {
      canvas.drawCircle(c, r + _line, Paint()..color = ink);
    }
    canvas.drawPath(path, _strokePaint(color, width));
    for (final (c, r) in extra) {
      canvas.drawCircle(c, r, Paint()..color = color);
    }
    canvas.drawPath(path.shift(const Offset(0.9, -0.7)), _strokePaint(ink.withValues(alpha: 0.18), 1));
  }
}
