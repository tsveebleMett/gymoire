import 'dart:math';

import 'package:material_ui/material_ui.dart';

import 'format.dart';
import 'theme.dart';

/// Line chart over time; the x axis is real time, so gaps between points
/// keep their length. Shows the lowest and highest value as grid lines.
class TimeLineChart extends StatelessWidget {
  const TimeLineChart({super.key, required this.points, this.minRange = 2, this.height = 170});

  final List<(DateTime, double)> points;

  /// Smallest value range on the y axis, so tiny changes do not look dramatic.
  final double minRange;
  final double height;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: height,
        child: CustomPaint(size: Size.infinite, painter: _LinePainter(points, minRange, context.palette)),
      );
}

class _LinePainter extends CustomPainter {
  _LinePainter(this.points, this.minRange, this.palette);

  final List<(DateTime, double)> points;
  final double minRange;
  final BookPalette palette;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;
    const labelWidth = 44.0;
    const bottomLabels = 18.0;
    final chart = Rect.fromLTRB(labelWidth, 8, size.width - 10, size.height - bottomLabels - 4);
    final values = points.map((p) => p.$2);
    final minV = values.reduce(min);
    final maxV = values.reduce(max);
    final pad = max(minRange / 2, (maxV - minV) * 0.15);
    final lo = max(0.0, minV - pad);
    final hi = maxV + pad;
    final t0 = points.first.$1.millisecondsSinceEpoch.toDouble();
    final t1 = points.last.$1.millisecondsSinceEpoch.toDouble();

    double y(double v) => chart.bottom - chart.height * (v - lo) / (hi - lo);
    Offset at((DateTime, double) p) => Offset(
          t1 == t0 ? chart.center.dx : chart.left + chart.width * (p.$1.millisecondsSinceEpoch - t0) / (t1 - t0),
          y(p.$2),
        );

    final p = palette;
    final grid = Paint()
      ..color = p.track
      ..strokeWidth = 1;
    for (final v in {minV, maxV}) {
      canvas.drawLine(Offset(chart.left, y(v)), Offset(chart.right, y(v)), grid);
      _text(canvas, formatKg((v * 10).round() / 10), Offset(0, y(v)), p.muted, align: _Align.leftMiddle);
    }
    _text(canvas, formatDayShort(points.first.$1), Offset(chart.left, size.height), p.muted, align: _Align.bottomLeft);
    if (points.length > 1) {
      _text(canvas, formatDayShort(points.last.$1), Offset(chart.right, size.height), p.muted, align: _Align.bottomRight);
    }

    final offsets = [for (final p in points) at(p)];
    if (offsets.length > 1) {
      final path = Path()..moveTo(offsets.first.dx, offsets.first.dy);
      for (final o in offsets.skip(1)) {
        path.lineTo(o.dx, o.dy);
      }
      final area = Path.from(path)
        ..lineTo(offsets.last.dx, chart.bottom)
        ..lineTo(offsets.first.dx, chart.bottom)
        ..close();
      canvas.drawPath(area, Paint()..color = p.accent.withValues(alpha: 0.14));
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..strokeJoin = StrokeJoin.round
          ..color = p.accent,
      );
    }
    for (final o in offsets) {
      canvas.drawCircle(o, 4, Paint()..color = p.card);
      canvas.drawCircle(
        o,
        4,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..color = p.accent,
      );
    }
  }

  @override
  bool shouldRepaint(_LinePainter old) => old.points != points || old.palette != palette;
}

/// Vertical bars with a label below each; an optional dashed goal line.
class BarChart extends StatelessWidget {
  const BarChart({super.key, required this.values, required this.labels, this.goal, this.height = 160});

  final List<double> values;

  /// One per bar; an empty label leaves the slot blank.
  final List<String> labels;
  final double? goal;
  final double height;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: height,
        child: CustomPaint(size: Size.infinite, painter: _BarPainter(values, labels, goal, context.palette)),
      );
}

class _BarPainter extends CustomPainter {
  _BarPainter(this.values, this.labels, this.goal, this.palette);

  final List<double> values;
  final List<String> labels;
  final double? goal;
  final BookPalette palette;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    const bottomLabels = 20.0;
    final chart = Rect.fromLTRB(0, 16, size.width, size.height - bottomLabels);
    final top = max(values.reduce(max), goal ?? 0) * 1.15;
    final scale = top == 0 ? 0.0 : chart.height / top;
    final slot = chart.width / values.length;
    final barWidth = min(28.0, slot * 0.6);

    for (var i = 0; i < values.length; i++) {
      final cx = chart.left + slot * (i + 0.5);
      final h = values[i] * scale;
      final reachedGoal = goal != null && values[i] >= goal!;
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(cx - barWidth / 2, chart.bottom - max(h, 3), barWidth, max(h, 3)),
          topLeft: const Radius.circular(8),
          topRight: const Radius.circular(8),
        ),
        Paint()..color = values[i] == 0 ? palette.track : (reachedGoal ? palette.highlight : palette.accent),
      );
      if (values[i] > 0) {
        _text(canvas, formatKg(values[i]), Offset(cx, chart.bottom - h - 2), palette.ink, align: _Align.bottomCenter, size: 11);
      }
      if (labels[i].isNotEmpty) {
        _text(canvas, labels[i], Offset(cx, size.height), palette.muted, align: _Align.bottomCenter, size: 11);
      }
    }

    if (goal != null && scale > 0) {
      final y = chart.bottom - goal! * scale;
      final dash = Paint()
        ..color = palette.muted
        ..strokeWidth = 1.5;
      for (var x = chart.left; x < chart.right; x += 10) {
        canvas.drawLine(Offset(x, y), Offset(min(x + 5, chart.right), y), dash);
      }
    }
  }

  @override
  bool shouldRepaint(_BarPainter old) => old.values != values || old.goal != goal || old.palette != palette;
}

enum _Align { leftMiddle, bottomLeft, bottomRight, bottomCenter }

void _text(Canvas canvas, String text, Offset anchor, Color color, {required _Align align, double size = 12}) {
  final painter = TextPainter(
    text: TextSpan(text: text, style: TextStyle(fontFamily: handFont, fontSize: size * 1.35, color: color, fontWeight: FontWeight.w700)),
    textDirection: TextDirection.ltr,
  )..layout();
  final offset = switch (align) {
    _Align.leftMiddle => Offset(anchor.dx, anchor.dy - painter.height / 2),
    _Align.bottomLeft => Offset(anchor.dx, anchor.dy - painter.height),
    _Align.bottomRight => Offset(anchor.dx - painter.width, anchor.dy - painter.height),
    _Align.bottomCenter => Offset(anchor.dx - painter.width / 2, anchor.dy - painter.height),
  };
  painter.paint(canvas, offset);
}
