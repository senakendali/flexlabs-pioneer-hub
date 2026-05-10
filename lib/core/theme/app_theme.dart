import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primary = Color(0xFF5B3E8E);
  static const Color primaryDark = Color(0xFF463071);
  static const Color primaryLight = Color(0xFFF1ECFA);

  static const Color background = Color(0xFFF8F7FC);
  static const Color card = Colors.white;

  static const Color textDark = Color(0xFF191624);
  static const Color textMuted = Color(0xFF7B748A);
  static const Color border = Color(0xFFEDE8F5);

  static ThemeData light() {
    final baseTextTheme = GoogleFonts.notoSansTextTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.light,
        primary: primary,
        surface: card,
      ),
      textTheme: baseTextTheme.apply(
        bodyColor: textDark,
        displayColor: textDark,
      ),
      fontFamily: GoogleFonts.notoSans().fontFamily,
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: background,
        foregroundColor: textDark,
        titleTextStyle: GoogleFonts.notoSans(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: textDark,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          textStyle: GoogleFonts.notoSans(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF8F7FB),
        labelStyle: GoogleFonts.notoSans(
          color: textMuted,
          fontWeight: FontWeight.w600,
        ),
        hintStyle: GoogleFonts.notoSans(
          color: textMuted,
          fontWeight: FontWeight.w500,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: primary,
            width: 1.4,
          ),
        ),
      ),
    );
  }
}