import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../domain/models.dart';

/// Grimoire look: the app is an old, handwritten training codex. Light mode
/// is iron-gall ink on aged vellum; dark mode follows the medieval "black
/// hours", books written in bone-white and gold on black-dyed vellum.
/// Verdigris (the alchemists' copper green) marks actions, cinnabar or
/// gilding marks rubrics such as underlined headings, gold leaf marks
/// records and reached goals. Headlines and the logged numbers are
/// handwritten (Caveat), running text is set in a book serif (Crimson Pro).
/// Light and dark follow the system setting.
const handFont = 'Caveat';
const bookFont = 'CrimsonPro';

/// Historical pigments per muscle group, readable on light and dark pages
/// with white text: cinnabar, indigo, sap green, ochre, sepia, slate.
const muscleColors = {
  MuscleGroup.chest: Color(0xFF9B3426),
  MuscleGroup.back: Color(0xFF2D4A73),
  MuscleGroup.legs: Color(0xFF586A24),
  MuscleGroup.shoulders: Color(0xFF94661A),
  MuscleGroup.arms: Color(0xFF6B4630),
  MuscleGroup.core: Color(0xFF4B5862),
};

/// Two-letter badge text, because several groups share their initial.
const muscleAbbreviations = {
  MuscleGroup.chest: 'BR',
  MuscleGroup.back: 'RÜ',
  MuscleGroup.legs: 'BE',
  MuscleGroup.shoulders: 'SC',
  MuscleGroup.arms: 'AR',
  MuscleGroup.core: 'RU',
};

/// Dark iron-gall ink for text on gold and on pasted-in parchment, in both
/// modes.
const inkOnGold = Color(0xFF2B1E16);

/// Colors that depend on light or dark mode. Read with `context.palette`.
class BookPalette extends ThemeExtension<BookPalette> {
  const BookPalette({
    required this.background,
    required this.card,
    required this.ink,
    required this.muted,
    required this.accent,
    required this.onAccent,
    required this.accentSoft,
    required this.rubric,
    required this.highlight,
    required this.track,
    required this.border,
    required this.positive,
    required this.positiveSoft,
    required this.negative,
    required this.negativeSoft,
    required this.plate,
    required this.speck,
    required this.dark,
  });

  /// The open book behind the entries.
  final Color background;

  /// An entry: a framed area on the page.
  final Color card;
  final Color ink;
  final Color muted;

  /// Verdigris: buttons, selections, chart lines.
  final Color accent;

  /// Text and icons on [accent].
  final Color onAccent;

  /// A thin verdigris wash: tinted backgrounds of accent elements.
  final Color accentSoft;

  /// Rubrics: hand-drawn underlines of headings. Cinnabar on vellum,
  /// gilding on the black pages.
  final Color rubric;

  /// Gold leaf: records and reached goals. Use [inkOnGold] on it.
  final Color highlight;

  /// Empty parts of bars and progress indicators, grid lines.
  final Color track;

  /// Ink rules of the frames.
  final Color border;
  final Color positive;
  final Color positiveSoft;
  final Color negative;
  final Color negativeSoft;

  /// Parchment for pasted-in drawings such as Bench Mark; light in both
  /// modes, so the dark ink of the drawings always reads.
  final Color plate;

  /// Stains and fibers of the page texture: foxing on vellum, gold dust
  /// on the black pages.
  final Color speck;

  final bool dark;

  /// Iron-gall ink on aged vellum.
  static const light = BookPalette(
    background: Color(0xFFE4D5B5),
    card: Color(0xFFF1E7CF),
    ink: Color(0xFF2B1E16),
    muted: Color(0xFF6C5B45),
    accent: Color(0xFF2E5E52),
    onAccent: Color(0xFFF6EFDD),
    accentSoft: Color(0xFFD9DCC2),
    rubric: Color(0xFF8E2B20),
    highlight: Color(0xFFC79D3D),
    track: Color(0xFFDFD1B1),
    border: Color(0xFFA48B63),
    positive: Color(0xFF3D6838),
    positiveSoft: Color(0xFFDCDFC1),
    negative: Color(0xFF8E3A22),
    negativeSoft: Color(0xFFE8D0B3),
    plate: Color(0xFFF4E9CE),
    speck: Color(0xFF8A5A2B),
    dark: false,
  );

  /// Bone-white ink and gold on black-dyed vellum.
  static const night = BookPalette(
    background: Color(0xFF0E1113),
    card: Color(0xFF161B1E),
    ink: Color(0xFFE8E0CC),
    muted: Color(0xFF9D9988),
    accent: Color(0xFF7DB3A0),
    onAccent: Color(0xFF0D1614),
    accentSoft: Color(0xFF1E2E2A),
    rubric: Color(0xFFC9A24E),
    highlight: Color(0xFFD8B45A),
    track: Color(0xFF242B2E),
    border: Color(0xFF4A5149),
    positive: Color(0xFF9CC49A),
    positiveSoft: Color(0xFF1D2A22),
    negative: Color(0xFFD08A73),
    negativeSoft: Color(0xFF2F201C),
    plate: Color(0xFFE6D7B4),
    speck: Color(0xFFC9A24E),
    dark: true,
  );

  @override
  BookPalette copyWith() => this;

  @override
  BookPalette lerp(BookPalette? other, double t) => t < 0.5 || other == null ? this : other;
}

extension PaletteContext on BuildContext {
  BookPalette get palette => Theme.of(this).extension<BookPalette>()!;
}

/// An entry on the page: a lightly tinted area inside a hand-ruled double
/// frame whose lines overshoot at the corners.
Decoration cardSurface(BuildContext context, {Color? color, double radius = 6}) {
  final p = context.palette;
  return InkFrameDecoration(fill: color ?? p.card, line: p.border, shadow: !p.dark);
}

/// A double ink frame drawn by hand: the outer rule wobbles slightly and
/// runs past the corners, the inner rule is finer. The wobble is derived
/// from the size, so a frame looks the same on every repaint.
class InkFrameDecoration extends Decoration {
  const InkFrameDecoration({required this.fill, required this.line, this.shadow = false});

  final Color fill;
  final Color line;

  /// A faint shadow as if the entry were a sheet laid onto the page.
  final bool shadow;

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) => _InkFramePainter(this);

  @override
  bool operator ==(Object other) =>
      other is InkFrameDecoration && other.fill == fill && other.line == line && other.shadow == shadow;

  @override
  int get hashCode => Object.hash(fill, line, shadow);
}

class _InkFramePainter extends BoxPainter {
  _InkFramePainter(this.d);

  final InkFrameDecoration d;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final size = configuration.size;
    if (size == null || size.isEmpty) return;
    final rect = offset & size;
    final body = RRect.fromRectAndRadius(rect.deflate(1), const Radius.circular(2));
    if (d.shadow) {
      canvas.drawRRect(
        body.shift(const Offset(0, 2)),
        Paint()
          ..color = const Color(0x1F3A2410)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
    }
    if (d.fill.a > 0) canvas.drawRRect(body, Paint()..color = d.fill);

    final seed = (size.width * 7 + size.height * 13).round();
    final outer = Paint()
      ..color = d.line
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;
    final inner = Paint()
      ..color = d.line.withValues(alpha: d.line.a * 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7;
    final o = rect.deflate(2.5);
    const run = 2.0;
    _wobblyLine(canvas, Offset(o.left - run, o.top), Offset(o.right + run, o.top), seed, outer);
    _wobblyLine(canvas, Offset(o.right, o.top - run), Offset(o.right, o.bottom + run), seed + 1, outer);
    _wobblyLine(canvas, Offset(o.right + run, o.bottom), Offset(o.left - run, o.bottom), seed + 2, outer);
    _wobblyLine(canvas, Offset(o.left, o.bottom + run), Offset(o.left, o.top - run), seed + 3, outer);
    canvas.drawRect(rect.deflate(5.5), inner);
  }

  static void _wobblyLine(Canvas canvas, Offset a, Offset b, int seed, Paint paint) {
    final length = (b - a).distance;
    final steps = math.max(2, (length / 28).round());
    final normal = Offset(-(b.dy - a.dy), b.dx - a.dx) / length;
    final path = Path()..moveTo(a.dx, a.dy);
    for (var i = 1; i <= steps; i++) {
      final t = i / steps;
      final wobble = i == steps ? 0.0 : math.sin(seed * 1.31 + i * 2.17) * 0.6;
      final pt = Offset.lerp(a, b, t)! + normal * wobble;
      path.lineTo(pt.dx, pt.dy);
    }
    canvas.drawPath(path, paint);
  }
}

/// The open book behind a screen: the page color with fibers, stains and
/// darker edges, painted once per size.
class BookPage extends StatelessWidget {
  const BookPage({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: _PageTexturePainter(context.palette),
        child: child,
      );
}

class _PageTexturePainter extends CustomPainter {
  _PageTexturePainter(this.p);

  final BookPalette p;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..color = p.background);
    final random = math.Random(1453);

    // Fibers: short faint strokes in the grain of the vellum.
    final fiber = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 0.6;
    final fibers = (size.width * size.height / 900).round();
    for (var i = 0; i < fibers; i++) {
      final start = Offset(random.nextDouble() * size.width, random.nextDouble() * size.height);
      final angle = -0.25 + random.nextDouble() * 0.5;
      final length = 4 + random.nextDouble() * 14;
      fiber.color = (p.dark ? p.ink : p.speck).withValues(alpha: 0.025 + random.nextDouble() * 0.04);
      canvas.drawLine(start, start + Offset(math.cos(angle), math.sin(angle)) * length, fiber);
    }

    // Foxing on vellum, specks of gold dust on the black pages.
    final stains = (size.width * size.height / 26000).round();
    for (var i = 0; i < stains; i++) {
      final c = Offset(random.nextDouble() * size.width, random.nextDouble() * size.height);
      final r = p.dark ? 0.6 + random.nextDouble() * 1.1 : 2 + random.nextDouble() * 9;
      final alpha = p.dark ? 0.10 + random.nextDouble() * 0.18 : 0.04 + random.nextDouble() * 0.06;
      canvas.drawCircle(
        c,
        r,
        Paint()
          ..shader = RadialGradient(
            colors: [p.speck.withValues(alpha: alpha), p.speck.withValues(alpha: 0)],
          ).createShader(Rect.fromCircle(center: c, radius: r)),
      );
    }

    // Edges darkened by age and handling.
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0, -0.1),
          radius: 1.05,
          colors: [
            const Color(0x00000000),
            p.dark ? const Color(0x59000000) : const Color(0x2E5A3A14),
          ],
          stops: const [0.6, 1],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(_PageTexturePainter old) => old.p != p;
}

/// A hand-drawn underline: a slightly curved rubric stroke, as under a
/// heading in a manuscript.
class HandUnderline extends StatelessWidget {
  const HandUnderline({super.key, this.width = 90, this.color});

  final double width;
  final Color? color;

  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.centerLeft,
        child: CustomPaint(
          size: Size(width, 8),
          painter: _UnderlinePainter(color ?? context.palette.rubric),
        ),
      );
}

class _UnderlinePainter extends CustomPainter {
  _UnderlinePainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2.4;
    canvas.drawPath(
      Path()
        ..moveTo(2, size.height * 0.6)
        ..quadraticBezierTo(size.width * 0.45, size.height * 0.15, size.width - 2, size.height * 0.45),
      paint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(size.width * 0.12, size.height * 0.95)
        ..quadraticBezierTo(size.width * 0.5, size.height * 0.55, size.width * 0.8, size.height * 0.8),
      paint..strokeWidth = 1.4,
    );
    // A small diamond at the end of the stroke, the scribe's flourish.
    final tip = Offset(size.width + 3, size.height * 0.45);
    canvas.drawPath(
      Path()
        ..moveTo(tip.dx - 2.6, tip.dy)
        ..lineTo(tip.dx, tip.dy - 2.6)
        ..lineTo(tip.dx + 2.6, tip.dy)
        ..lineTo(tip.dx, tip.dy + 2.6)
        ..close(),
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(_UnderlinePainter old) => old.color != color;
}

ThemeData buildTheme({required Brightness brightness}) {
  final p = brightness == Brightness.dark ? BookPalette.night : BookPalette.light;
  final scheme = ColorScheme.fromSeed(
    seedColor: p.accent,
    brightness: brightness,
    primary: p.accent,
    onPrimary: p.onAccent,
    secondary: p.highlight,
    onSecondary: inkOnGold,
    tertiary: p.rubric,
    error: p.negative,
    surface: p.card,
    onSurface: p.ink,
    surfaceTint: Colors.transparent,
    surfaceContainerHighest: p.track,
    outline: p.border,
  );
  final base = ThemeData(colorScheme: scheme, useMaterial3: true, scaffoldBackgroundColor: p.background, fontFamily: bookFont);
  final t = base.textTheme.apply(bodyColor: p.ink, displayColor: p.ink);
  // Caveat runs small and narrow, so handwritten styles get bigger sizes.
  TextStyle? hand(TextStyle? s, double size) => s?.copyWith(fontFamily: handFont, fontSize: size, fontWeight: FontWeight.w700, height: 1.1);
  TextStyle? title(TextStyle? s) => s?.copyWith(fontWeight: FontWeight.w700);
  const buttonText = TextStyle(fontFamily: handFont, fontSize: 24, fontWeight: FontWeight.w700);
  // Nearly square like a pasted-in label, not a pill.
  const label = RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(3)));
  const corners = WidgetStatePropertyAll<OutlinedBorder>(label);
  // Filled labels: on vellum verdigris with a darker edge where the ink
  // pooled; on the black pages deep verdigris with bone-white text and a
  // gilded edge, like tooling on a leather cover.
  final filledFill = p.dark ? const Color(0xFF2B5A4F) : p.accent;
  final filledText = p.dark ? p.ink : p.onAccent;
  final inkedEdge = p.dark
      ? BorderSide(color: p.rubric.withValues(alpha: 0.75), width: 1.2)
      : BorderSide(color: Color.lerp(p.accent, p.ink, 0.4)!, width: 1.2);

  return base.copyWith(
    extensions: [p],
    textTheme: t.copyWith(
      headlineLarge: hand(t.headlineLarge, 46),
      headlineMedium: hand(t.headlineMedium, 42),
      headlineSmall: hand(t.headlineSmall, 34),
      titleLarge: title(t.titleLarge),
      titleMedium: title(t.titleMedium)?.copyWith(fontSize: 18),
      bodyLarge: t.bodyLarge?.copyWith(fontSize: 18),
      bodySmall: t.bodySmall?.copyWith(color: p.muted, fontSize: 14),
      bodyMedium: t.bodyMedium?.copyWith(color: p.muted, fontSize: 16),
      labelLarge: t.labelLarge?.copyWith(fontSize: 15),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: p.ink,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(fontFamily: handFont, fontSize: 32, fontWeight: FontWeight.w700, color: p.ink),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: ButtonStyle(
        textStyle: const WidgetStatePropertyAll(buttonText),
        shape: corners,
        backgroundColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.disabled) ? p.track : filledFill,
        ),
        foregroundColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.disabled) ? p.muted : filledText,
        ),
        side: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.disabled) ? BorderSide(color: p.border) : inkedEdge,
        ),
        minimumSize: const WidgetStatePropertyAll(Size(64, 54)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(
        textStyle: const WidgetStatePropertyAll(buttonText),
        shape: corners,
        minimumSize: const WidgetStatePropertyAll(Size(64, 48)),
        side: WidgetStatePropertyAll(BorderSide(color: p.accent, width: 1.5)),
      ),
    ),
    textButtonTheme: const TextButtonThemeData(
      style: ButtonStyle(textStyle: WidgetStatePropertyAll(TextStyle(fontFamily: handFont, fontSize: 22, fontWeight: FontWeight.w700))),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        shape: corners,
        textStyle: const WidgetStatePropertyAll(TextStyle(fontFamily: handFont, fontSize: 20, fontWeight: FontWeight.w700)),
        backgroundColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? p.accent : p.card),
        foregroundColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? p.onAccent : p.ink),
        side: WidgetStatePropertyAll(BorderSide(color: p.border)),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: p.card,
      selectedColor: p.accentSoft,
      side: BorderSide(color: p.border),
      shape: label,
      labelStyle: TextStyle(fontFamily: handFont, fontWeight: FontWeight.w700, fontSize: 21, color: p.ink),
    ),
    inputDecorationTheme: InputDecorationThemeData(
      filled: true,
      fillColor: p.card,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(3), borderSide: BorderSide(color: p.border)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(3), borderSide: BorderSide(color: p.border)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(3), borderSide: BorderSide(color: p.accent, width: 1.5)),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: p.card,
      surfaceTintColor: Colors.transparent,
      indicatorColor: p.accentSoft,
      indicatorShape: label,
      iconTheme: WidgetStateProperty.resolveWith(
        (s) => IconThemeData(color: s.contains(WidgetState.selected) ? p.accent : p.muted),
      ),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (s) => TextStyle(
          fontFamily: handFont,
          fontWeight: FontWeight.w700,
          fontSize: 18,
          color: s.contains(WidgetState.selected) ? p.ink : p.muted,
        ),
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: p.card,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        side: BorderSide(color: p.border),
      ),
      showDragHandle: true,
      dragHandleColor: p.border,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: p.card,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4), side: BorderSide(color: p.border)),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: p.dark ? p.plate : p.ink,
      actionTextColor: p.dark ? BookPalette.light.accent : p.highlight,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(3))),
      contentTextStyle: TextStyle(
        fontFamily: bookFont,
        fontSize: 16,
        color: p.dark ? inkOnGold : p.card,
        fontWeight: FontWeight.w600,
      ),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(color: p.accent, linearTrackColor: p.track),
    dividerTheme: DividerThemeData(color: p.border, thickness: 0.8),
  );
}
