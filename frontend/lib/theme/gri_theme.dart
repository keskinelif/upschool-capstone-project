import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class GriColors {
  static const bg = Color(0xFFF4F4F4);
  static const border = Color(0xFFD3D4D6);
  static const muted = Color(0xFFA8AAAD);
  static const secondary = Color(0xFF7B7E82);
  static const primary = Color(0xFF232529);
  static const errorBg = Color(0xFFFCE4EC);
  static const errorText = Color(0xFFC62828);
  static const onPrimary = Color(0xFFFFFFFF);
}

abstract final class GriRadii {
  static const sm = 6.0;
  static const md = 10.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const full = 999.0;
}

abstract final class GriSpacing {
  static const sp1 = 4.0;
  static const sp2 = 8.0;
  static const sp3 = 12.0;
  static const sp4 = 16.0;
  static const sp5 = 20.0;
  static const sp6 = 24.0;
  static const sp8 = 32.0;
  static const sp12 = 48.0;
}

abstract final class GriTheme {
  static ThemeData material() {
    final base = ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: GriColors.bg,
      colorScheme: const ColorScheme.light(
        primary: GriColors.primary,
        onPrimary: GriColors.onPrimary,
        surface: GriColors.bg,
        onSurface: GriColors.primary,
        error: GriColors.errorText,
      ),
    );

    return base.copyWith(
      textTheme: GoogleFonts.dmSansTextTheme(base.textTheme).apply(
        bodyColor: GriColors.primary,
        displayColor: GriColors.primary,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: GriColors.onPrimary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(GriRadii.md),
          borderSide: const BorderSide(color: GriColors.border, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(GriRadii.md),
          borderSide: const BorderSide(color: GriColors.border, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(GriRadii.md),
          borderSide: const BorderSide(color: GriColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(GriRadii.md),
          borderSide: const BorderSide(color: GriColors.errorText, width: 1.5),
        ),
        labelStyle: GoogleFonts.dmSans(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.66,
          color: GriColors.muted,
        ),
        hintStyle: GoogleFonts.dmSans(
          fontSize: 14,
          color: GriColors.muted,
        ),
      ),
    );
  }

  static TextStyle displayTitle() => GoogleFonts.dmSerifDisplay(
        fontSize: 36,
        color: GriColors.primary,
        letterSpacing: -0.9,
      );

  static TextStyle body() => GoogleFonts.dmSans(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.6,
        color: GriColors.primary,
      );

  static TextStyle caption() => GoogleFonts.dmSans(
        fontSize: 12,
        color: GriColors.secondary,
      );

  static TextStyle h1() => GoogleFonts.dmSans(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: GriColors.primary,
      );

  static TextStyle h3() => GoogleFonts.dmSans(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: GriColors.primary,
      );

  static TextStyle navLabel({required bool active}) => GoogleFonts.dmSans(
        fontSize: 11,
        fontWeight: active ? FontWeight.w700 : FontWeight.w400,
        color: active ? GriColors.primary : GriColors.muted,
      );
}
