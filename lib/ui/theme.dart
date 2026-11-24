import 'package:material_ui/material_ui.dart';

import '../domain/models.dart';

/// Book look: the app is a training journal. Light mode is ink on
/// parchment, dark mode light ink on a night-dark leather book. Headlines
/// and the logged numbers are handwritten (Caveat), running text is set in
/// a book serif (Crimson Pro). Rubric red marks actions, gold marks records
/// and reached goals. Light and dark follow the system setting.
const handFont = 'Caveat';
const bookFont = 'CrimsonPro';

/// Ink colors per muscle group, readable on light and dark pages with white
/// text.
const muscleColors = {
  MuscleGroup.chest: Color(0xFFA8322A),
  MuscleGroup.back: Color(0xFF2F5D8A),
  MuscleGroup.legs: Color(0xFF4E7A3A),
  MuscleGroup.shoulders: Color(0xFFA86F16),
  MuscleGroup.arms: Color(0xFF6B4A8E),
  MuscleGroup.core: Color(0xFF9A4466),
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

/// Colors that depend on light or dark mode. Read with `context.palette`.
class BookPalette extends ThemeExtension<BookPalette> {
  const BookPalette({
    required this.background,
    required this.card,
    required this.ink,
    required this.muted,
    required this.accent,
    required this.accentSoft,
    required this.highlight,
    required this.track,
    required this.border,
    required this.positive,
    required this.positiveSoft,
    required this.negative,
    required this.negativeSoft,
    required this.plate,
    required this.dark,
  });

  /// The desk or cover behind the pages.
  final Color background;

  /// A page.
  final Color card;
  final Color ink;
  final Color muted;

  /// Rubric red: buttons, selections, chart lines.
  final Color accent;

  /// Tinted backgrounds of accent elements.
  final Color accentSoft;

  /// Gold: records and reached goals. Use dark text on it.
  final Color highlight;

  /// Empty parts of bars and progress indicators, grid lines.
  final Color track;
  final Color border;
  final Color positive;
  final Color positiveSoft;
  final Color negative;
  final Color negativeSoft;

  /// Parchment for pasted-in drawings such as Bench Mark; light in both
  /// modes, so the dark ink of the drawings always reads.
  final Color plate;

  final bool dark;

  static const light = BookPalette(
    background: Color(0xFFE9DEC6),
    card: Color(0xFFF8F1E1),
    ink: Color(0xFF2A2018),
    muted: Color(0xFF75644E),
    accent: Color(0xFFA8322A),
    accentSoft: Color(0xFFF1DACB),
    highlight: Color(0xFFD9A93E),
    track: Color(0xFFE6DAC2),
    border: Color(0xFFCDB993),
    positive: Color(0xFF3F6B3A),
    positiveSoft: Color(0xFFDDE6CC),
    negative: Color(0xFF9C4A1A),
    negativeSoft: Color(0xFFF2DCC8),
    plate: Color(0xFFF3E7CC),
    dark: false,
  );

  static const night = BookPalette(
    background: Color(0xFF14100C),
    card: Color(0xFF211A14),
    ink: Color(0xFFEDE2CB),
    muted: Color(0xFFAA9A80),
    accent: Color(0xFFC8441F),
    accentSoft: Color(0xFF3A1D12),
    highlight: Color(0xFFE2B455),
    track: Color(0xFF2F271F),
    border: Color(0xFF4A3D2F),
    positive: Color(0xFFA3C98F),
    positiveSoft: Color(0xFF243020),
    negative: Color(0xFFE99A63),
    negativeSoft: Color(0xFF3A281A),
    plate: Color(0xFFE6D6B4),
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

/// A page: paper color, a thin pencil border and, in light mode, a soft
/// shadow as if lying on the desk.
BoxDecoration cardSurface(BuildContext context, {Color? color, double radius = 6}) {
  final p = context.palette;
  return BoxDecoration(
    color: color ?? p.card,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: p.border, width: 0.8),
    boxShadow: p.dark ? null : const [BoxShadow(color: Color(0x1A3A2A14), blurRadius: 10, offset: Offset(0, 3))],
  );
}

/// A hand-drawn underline: a slightly curved ink stroke, as under a
/// heading in a notebook.
class HandUnderline extends StatelessWidget {
  const HandUnderline({super.key, this.width = 90, this.color});

  final double width;
  final Color? color;

  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.centerLeft,
        child: CustomPaint(
          size: Size(width, 8),
          painter: _UnderlinePainter(color ?? context.palette.accent),
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
    onPrimary: p.dark ? const Color(0xFFFFF4E8) : Colors.white,
    secondary: p.highlight,
    onSecondary: const Color(0xFF2A2018),
    surface: p.card,
    onSurface: p.ink,
    surfaceContainerHighest: p.track,
    outline: p.border,
  );
  final base = ThemeData(colorScheme: scheme, useMaterial3: true, scaffoldBackgroundColor: p.background, fontFamily: bookFont);
  final t = base.textTheme.apply(bodyColor: p.ink, displayColor: p.ink);
  // Caveat runs small and narrow, so handwritten styles get bigger sizes.
  TextStyle? hand(TextStyle? s, double size) => s?.copyWith(fontFamily: handFont, fontSize: size, fontWeight: FontWeight.w700, height: 1.1);
  TextStyle? title(TextStyle? s) => s?.copyWith(fontWeight: FontWeight.w700);
  const buttonText = TextStyle(fontFamily: handFont, fontSize: 24, fontWeight: FontWeight.w700);
  final corners = WidgetStatePropertyAll<OutlinedBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)));

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
      backgroundColor: p.background,
      foregroundColor: p.ink,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: TextStyle(fontFamily: handFont, fontSize: 32, fontWeight: FontWeight.w700, color: p.ink),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: ButtonStyle(
        textStyle: const WidgetStatePropertyAll(buttonText),
        shape: corners,
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
        foregroundColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? scheme.onPrimary : p.ink,
        ),
        side: WidgetStatePropertyAll(BorderSide(color: p.border)),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: p.card,
      selectedColor: p.accentSoft,
      side: BorderSide(color: p.border),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      labelStyle: TextStyle(fontFamily: handFont, fontWeight: FontWeight.w700, fontSize: 21, color: p.ink),
    ),
    inputDecorationTheme: InputDecorationThemeData(
      filled: true,
      fillColor: p.background,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: p.card,
      indicatorColor: p.accentSoft,
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
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(14))),
      showDragHandle: true,
    ),
    dialogTheme: DialogThemeData(backgroundColor: p.card),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: p.dark ? const Color(0xFFE6D6B4) : const Color(0xFF2A2018),
      actionTextColor: p.dark ? const Color(0xFF9E2B20) : p.highlight,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      contentTextStyle: TextStyle(
        fontFamily: bookFont,
        fontSize: 16,
        color: p.dark ? const Color(0xFF2A2018) : const Color(0xFFF8F1E1),
        fontWeight: FontWeight.w600,
      ),
    ),
    dividerTheme: DividerThemeData(color: p.border),
  );
}
