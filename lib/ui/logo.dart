import 'package:material_ui/material_ui.dart';

import 'brand_mark.dart';

/// Which parts of the logo to paint. Android adaptive icons combine a
/// background and a foreground; themed icons (Android 13+) use a
/// single-colour monochrome layer.
enum LogoLayer { full, background, foreground, monochrome }

const _leatherTop = Color(0xFF6E2C22);
const _leatherBottom = Color(0xFF34140F);
const _gold = Color(0xFFE2B455);

/// Gymoire app icon: the cover of a leather-bound grimoire with the brand
/// mark (see [GymoireMarkPainter]) embossed in gold.
///
/// Drawn on a 108×108 grid, the Android adaptive-icon canvas. Everything
/// that must stay visible lies within a radius of 33 around the centre, the
/// safe zone that survives every launcher mask.
class GymoireLogoPainter extends CustomPainter {
  const GymoireLogoPainter({this.layer = LogoLayer.full});

  final LogoLayer layer;

  static const double grid = 108;

  /// Where the 100 grid of the mark sits on the icon grid.
  static const _place = Rect.fromLTWH(23, 23, 62, 62);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / grid, size.height / grid);
    if (layer == LogoLayer.full || layer == LogoLayer.background) {
      const rect = Rect.fromLTWH(0, 0, grid, grid);
      canvas.drawRect(
        rect,
        Paint()
          ..shader = const RadialGradient(
            center: Alignment(-0.3, -0.4),
            radius: 1.1,
            colors: [_leatherTop, _leatherBottom],
          ).createShader(rect),
      );
    }
    if (layer != LogoLayer.background) {
      canvas.save();
      canvas.translate(_place.left, _place.top);
      if (layer != LogoLayer.monochrome) {
        // Pressed into the leather: a dark offset under the gold.
        canvas.save();
        canvas.translate(0.6, 0.9);
        const GymoireMarkPainter(color: Color(0x99200A06)).paint(canvas, _place.size);
        canvas.restore();
      }
      GymoireMarkPainter(color: layer == LogoLayer.monochrome ? Colors.white : _gold).paint(canvas, _place.size);
      canvas.restore();
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(GymoireLogoPainter old) => old.layer != layer;
}
