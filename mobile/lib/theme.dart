import 'package:flutter/material.dart';

/// Cobrewer "System B" — rounded neubrutalism (design/DESIGN.md).
/// Periwinkle canvas, cream cards, 3px ink borders, hard offset shadows.
abstract final class Palette {
  static const peri = Color(0xFF7185BF);
  static const blush = Color(0xFFED99A4);
  static const blushDeep = Color(0xFFE8858F);
  static const olive = Color(0xFFB5B77A);
  static const cream = Color(0xFFF7F4ED);
  static const creamDim = Color(0xFFD9DEF1);
  static const ink = Color(0xFF14162B);

  /// Secondary text on cream/white surfaces.
  static const inkSoft = Color(0xFF4D5170);
}

/// Hard-shadow surface: 3px ink border, zero-blur offset shadow.
BoxDecoration brutBox({
  Color color = Palette.cream,
  double radius = 18,
  double shadow = 5,
}) {
  return BoxDecoration(
    color: color,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: Palette.ink, width: 3),
    boxShadow: [
      if (shadow > 0)
        BoxShadow(color: Palette.ink, offset: Offset(shadow, shadow)),
    ],
  );
}

/// A cream (or colored) card with the System B border + hard shadow.
/// Replaces Material's soft-shadow Card everywhere in the app.
class BrutCard extends StatelessWidget {
  final Widget child;
  final Color color;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final double radius;
  final double shadow;

  const BrutCard({
    super.key,
    required this.child,
    this.color = Palette.cream,
    this.padding = const EdgeInsets.all(14),
    this.onTap,
    this.radius = 18,
    this.shadow = 5,
  });

  @override
  Widget build(BuildContext context) {
    final inner = Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(radius - 3),
      clipBehavior: Clip.antiAlias,
      child: onTap == null
          ? Padding(padding: padding, child: child)
          : InkWell(
              onTap: onTap,
              child: Padding(padding: padding, child: child),
            ),
    );
    return Container(decoration: brutBox(color: color, radius: radius, shadow: shadow), child: inner);
  }
}

ThemeData buildCobrewerTheme() {
  final base = ThemeData(
    brightness: Brightness.dark,
    fontFamily: 'Rubik',
    colorScheme: const ColorScheme.dark(
      primary: Palette.blush,
      onPrimary: Palette.ink,
      secondary: Palette.olive,
      onSecondary: Palette.ink,
      surface: Palette.cream,
      onSurface: Palette.ink,
      error: Palette.blushDeep,
    ),
    scaffoldBackgroundColor: Palette.peri,
    useMaterial3: true,
  );

  return base.copyWith(
    // Scaffold text sits on periwinkle; card text overrides to ink locally.
    textTheme: base.textTheme.apply(
      bodyColor: Palette.cream,
      displayColor: Palette.cream,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Palette.peri,
      foregroundColor: Palette.cream,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontFamily: 'Anton',
        color: Palette.cream,
        fontSize: 26,
        fontWeight: FontWeight.w400,
        letterSpacing: 1,
        shadows: [Shadow(color: Palette.ink, offset: Offset(3, 3))],
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Palette.cream,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Palette.ink, width: 3),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Palette.ink, width: 3),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Palette.blushDeep, width: 3),
      ),
      hintStyle: const TextStyle(color: Palette.inkSoft, fontWeight: FontWeight.w500),
      labelStyle: const TextStyle(color: Palette.inkSoft, fontWeight: FontWeight.w600),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: Palette.blush,
        foregroundColor: Palette.ink,
        textStyle: const TextStyle(
          fontFamily: 'Anton',
          fontSize: 15,
          fontWeight: FontWeight.w400,
          letterSpacing: 1.2,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: Palette.ink, width: 3),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        elevation: 0,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Palette.ink,
        backgroundColor: Palette.cream,
        textStyle: const TextStyle(
          fontFamily: 'Anton',
          fontSize: 13,
          fontWeight: FontWeight.w400,
          letterSpacing: 1,
        ),
        side: const BorderSide(color: Palette.ink, width: 3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Palette.cream,
      indicatorColor: Palette.ink,
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          color: states.contains(WidgetState.selected)
              ? Palette.olive
              : Palette.inkSoft,
        ),
      ),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
          color: states.contains(WidgetState.selected)
              ? Palette.ink
              : Palette.inkSoft,
        ),
      ),
    ),
    chipTheme: base.chipTheme.copyWith(
      backgroundColor: Colors.white,
      side: const BorderSide(color: Palette.ink, width: 2),
      labelStyle: const TextStyle(
        color: Palette.ink,
        fontSize: 13,
        fontWeight: FontWeight.w700,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    popupMenuTheme: const PopupMenuThemeData(
      color: Palette.cream,
      textStyle: TextStyle(color: Palette.ink, fontWeight: FontWeight.w600),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        side: BorderSide(color: Palette.ink, width: 3),
      ),
    ),
    dividerTheme: const DividerThemeData(color: Palette.ink),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: Palette.ink,
      contentTextStyle: TextStyle(color: Palette.cream, fontFamily: 'Rubik'),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
