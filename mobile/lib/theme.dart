import 'package:flutter/material.dart';

/// Cobrewer brand palette — cobra theme: dark, sleek, precise.
abstract final class CobraColors {
  static const background = Color(0xFF0A0A0A);
  static const surface = Color(0xFF141414);
  static const surfaceRaised = Color(0xFF1C1C1C);
  static const border = Color(0xFF2A2A2A);
  static const green = Color(0xFF4ADE80);
  static const greenDeep = Color(0xFF16A34A);
  static const amber = Color(0xFFF59E0B);
  static const text = Color(0xFFF5F5F5);
  static const textMuted = Color(0xFF9CA3AF);
}

ThemeData buildCobraTheme() {
  final base = ThemeData(
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: CobraColors.green,
      onPrimary: CobraColors.background,
      secondary: CobraColors.amber,
      surface: CobraColors.surface,
      onSurface: CobraColors.text,
      error: Color(0xFFF87171),
    ),
    scaffoldBackgroundColor: CobraColors.background,
    useMaterial3: true,
  );

  return base.copyWith(
    appBarTheme: const AppBarTheme(
      backgroundColor: CobraColors.background,
      foregroundColor: CobraColors.text,
      elevation: 0,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      color: CobraColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: CobraColors.border),
      ),
      margin: EdgeInsets.zero,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: CobraColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: CobraColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: CobraColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: CobraColors.green),
      ),
      hintStyle: const TextStyle(color: CobraColors.textMuted),
      labelStyle: const TextStyle(color: CobraColors.textMuted),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: CobraColors.green,
        foregroundColor: CobraColors.background,
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: CobraColors.text,
        side: const BorderSide(color: CobraColors.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
    chipTheme: base.chipTheme.copyWith(
      backgroundColor: CobraColors.surface,
      selectedColor: CobraColors.greenDeep,
      side: const BorderSide(color: CobraColors.border),
      labelStyle: const TextStyle(color: CobraColors.text, fontSize: 13),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: CobraColors.surface,
      indicatorColor: CobraColors.greenDeep.withValues(alpha: 0.35),
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          color: states.contains(WidgetState.selected)
              ? CobraColors.green
              : CobraColors.textMuted,
        ),
      ),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(
          fontSize: 12,
          color: states.contains(WidgetState.selected)
              ? CobraColors.green
              : CobraColors.textMuted,
        ),
      ),
    ),
    dividerTheme: const DividerThemeData(color: CobraColors.border),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: CobraColors.surfaceRaised,
      contentTextStyle: TextStyle(color: CobraColors.text),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
