import 'package:flutter/material.dart';

/// Cobrewer palette — retro, flat, friendly.
/// Two colors carry everything: periwinkle canvas, blush pink accent.
abstract final class Palette {
  static const peri = Color(0xFF7185BF);
  static const periDeep = Color(0xFF6377B1);
  static const periWell = Color(0xFF57699F);
  static const blush = Color(0xFFED99A4);
  static const blushDeep = Color(0xFFE8858F);
  static const cream = Color(0xFFF7F4ED);
  static const creamDim = Color(0xFFD9DEF1);
  static const ink = Color(0xFF333A63);

  /// Ink softened toward blush — secondary text on pink surfaces.
  static const inkSoft = Color(0xFF5A5380);
}

ThemeData buildCobrewerTheme() {
  final base = ThemeData(
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: Palette.blush,
      onPrimary: Palette.ink,
      secondary: Palette.cream,
      onSecondary: Palette.ink,
      surface: Palette.periDeep,
      onSurface: Palette.cream,
      error: Palette.blushDeep,
    ),
    scaffoldBackgroundColor: Palette.peri,
    useMaterial3: true,
  );

  return base.copyWith(
    appBarTheme: const AppBarTheme(
      backgroundColor: Palette.peri,
      foregroundColor: Palette.cream,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: Palette.cream,
        fontSize: 22,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.2,
      ),
    ),
    cardTheme: CardThemeData(
      color: Palette.periDeep,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      margin: EdgeInsets.zero,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Palette.periWell,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Palette.cream, width: 1.5),
      ),
      hintStyle: const TextStyle(color: Palette.creamDim),
      labelStyle: const TextStyle(color: Palette.creamDim),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: Palette.blush,
        foregroundColor: Palette.ink,
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Palette.cream,
        side: BorderSide(color: Palette.cream.withValues(alpha: 0.4)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
    chipTheme: base.chipTheme.copyWith(
      backgroundColor: Palette.periWell,
      selectedColor: Palette.blush,
      side: BorderSide.none,
      labelStyle: const TextStyle(color: Palette.cream, fontSize: 13),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Palette.periDeep,
      indicatorColor: Palette.blush,
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          color: states.contains(WidgetState.selected)
              ? Palette.ink
              : Palette.creamDim,
        ),
      ),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(
          fontSize: 12,
          fontWeight: states.contains(WidgetState.selected)
              ? FontWeight.w700
              : FontWeight.w400,
          color: states.contains(WidgetState.selected)
              ? Palette.cream
              : Palette.creamDim,
        ),
      ),
    ),
    dividerTheme: DividerThemeData(
      color: Palette.cream.withValues(alpha: 0.15),
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: Palette.ink,
      contentTextStyle: TextStyle(color: Palette.cream),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
