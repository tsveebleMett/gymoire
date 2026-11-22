import 'package:material_ui/material_ui.dart';

import '../domain/models.dart';

/// Warm and friendly like the hamster: cream background, fur orange as the
/// main color, cocoa brown text, round surfaces with a diffuse shadow.
const bodyFont = 'Nunito';
const displayFont = 'Fredoka';

const fur = Color(0xFFF08A24);
const furLight = Color(0xFFFFD8AE);
const cream = Color(0xFFFFF7EC);
const cocoa = Color(0xFF4A2C17);
const cardColor = Colors.white;
const shadowColor = Color(0x229A5A2C);

/// Pastel tint per muscle group, used for badges in logs and the calendar.
const muscleColors = {
  MuscleGroup.chest: Color(0xFFFFB4A2),
  MuscleGroup.back: Color(0xFF9AD0EC),
  MuscleGroup.legs: Color(0xFFA8DDA8),
  MuscleGroup.shoulders: Color(0xFFFFD670),
  MuscleGroup.arms: Color(0xFFC8B6F2),
  MuscleGroup.core: Color(0xFFF5B8D8),
};

BoxDecoration softSurface({Color color = cardColor, double radius = 24}) => BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: const [BoxShadow(color: shadowColor, blurRadius: 18, offset: Offset(0, 6))],
    );

ThemeData buildTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: fur,
    primary: fur,
    onPrimary: Colors.white,
    surface: cream,
    onSurface: cocoa,
    brightness: Brightness.light,
  );
  final base = ThemeData(colorScheme: scheme, useMaterial3: true, fontFamily: bodyFont, scaffoldBackgroundColor: cream);
  final t = base.textTheme.apply(bodyColor: cocoa, displayColor: cocoa);
  TextStyle? display(TextStyle? s, FontWeight w) => s?.copyWith(fontFamily: displayFont, fontWeight: w);
  const buttonText = TextStyle(fontFamily: displayFont, fontSize: 17, fontWeight: FontWeight.w600);
  final stadium = WidgetStatePropertyAll<OutlinedBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)));

  return base.copyWith(
    textTheme: t.copyWith(
      headlineMedium: display(t.headlineMedium, FontWeight.w600),
      headlineSmall: display(t.headlineSmall, FontWeight.w600),
      titleLarge: display(t.titleLarge, FontWeight.w600),
      titleMedium: display(t.titleMedium, FontWeight.w600),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: cream,
      foregroundColor: cocoa,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: TextStyle(fontFamily: displayFont, fontSize: 24, fontWeight: FontWeight.w600, color: cocoa),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: ButtonStyle(
        textStyle: const WidgetStatePropertyAll(buttonText),
        shape: stadium,
        minimumSize: const WidgetStatePropertyAll(Size(64, 54)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(
        textStyle: const WidgetStatePropertyAll(buttonText),
        shape: stadium,
        minimumSize: const WidgetStatePropertyAll(Size(64, 48)),
        side: const WidgetStatePropertyAll(BorderSide(color: furLight, width: 2)),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: cardColor,
      selectedColor: furLight,
      side: const BorderSide(color: furLight),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      labelStyle: const TextStyle(fontFamily: displayFont, fontWeight: FontWeight.w500, fontSize: 15, color: cocoa),
    ),
    inputDecorationTheme: InputDecorationThemeData(
      filled: true,
      fillColor: cardColor,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: cardColor,
      indicatorColor: furLight,
      labelTextStyle: const WidgetStatePropertyAll(
        TextStyle(fontFamily: displayFont, fontWeight: FontWeight.w500, fontSize: 13, color: cocoa),
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: cream,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      showDragHandle: true,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: cocoa,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      contentTextStyle: const TextStyle(fontFamily: bodyFont, color: Colors.white, fontWeight: FontWeight.w600),
    ),
  );
}
