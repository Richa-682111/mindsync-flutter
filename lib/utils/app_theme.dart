import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ─── DESIGN SYSTEM: Mental Health App + Mood Tracker (UI-UX Pro Max) ───
  // Style: Soft UI Evolution + Neumorphism-inspired
  // Rules: Calm pastels, accessibility-first, soft depth, no harsh contrast
  // Anti-patterns: No neon, no AI purple/pink gradients, no motion overload

  // Color Tokens
  static const Color canvas       = Color(0xFFF7F6F9);  // cool off-white canvas
  static const Color surface      = Color(0xFFFFFFFF);  // card surface
  static const Color surfaceDim   = Color(0xFFEFEDF3);  // subtle section bg
  static const Color border       = Color(0xFFE4E1EC);  // hairline border
  static const Color textPrimary  = Color(0xFF1E1B2E);  // near-black, not harsh
  static const Color textSecondary= Color(0xFF6B6880);  // soft slate
  static const Color textMuted    = Color(0xFF9B98AB);  // de-emphasized
  static const Color accent       = Color(0xFF7C6FA0);  // muted lavender (NOT neon)
  static const Color accentSoft   = Color(0xFFEDE9F6);  // soft accent tint
  static const Color positive     = Color(0xFF6BAF8D);  // muted sage green
  static const Color positiveSoft = Color(0xFFE6F4EE);  // soft green tint
  static const Color warmTone     = Color(0xFFB08B6E);  // warm earth (mood)
  static const Color warmSoft     = Color(0xFFF6EFE8);  // warm tint

  // Mood-specific colors (emotion gradient: sad → happy)
  static const Color moodHappy    = Color(0xFF8DAF8C);  // sage green
  static const Color moodStressed = Color(0xFFAF9B8D);  // warm sand
  static const Color moodAnxious  = Color(0xFF8D9FAF);  // calm blue-grey

  static ThemeData get lightTheme {
    final base = GoogleFonts.interTextTheme();
    return ThemeData(
      scaffoldBackgroundColor: canvas,
      colorScheme: const ColorScheme.light(
        primary: accent,
        secondary: positive,
        surface: surface,
      ),
      textTheme: base.copyWith(
        // Scale: deliberate type hierarchy
        displayLarge:  GoogleFonts.inter(fontSize: 36, fontWeight: FontWeight.w700, color: textPrimary, letterSpacing: -0.8, height: 1.15),
        displayMedium: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w700, color: textPrimary, letterSpacing: -0.5, height: 1.2),
        titleLarge:    GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: textPrimary, letterSpacing: -0.2),
        titleMedium:   GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: textPrimary),
        bodyLarge:     GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w400, color: textPrimary, height: 1.55),
        bodyMedium:    GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, color: textSecondary, height: 1.55),
        labelSmall:    GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, color: textMuted, letterSpacing: 0.5),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: canvas,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: textPrimary),
        titleTextStyle: GoogleFonts.inter(
          color: textPrimary,
          fontSize: 17,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
      ),
      // Flat cards with hairline border (Soft UI Evolution)
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: border, width: 1),
        ),
        margin: const EdgeInsets.symmetric(vertical: 6),
      ),
      // Input fields: filled, calm
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceDim,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: accent, width: 1.5),
        ),
        hintStyle: GoogleFonts.inter(color: textMuted, fontSize: 14),
      ),
      // Buttons: not flashy, clean and functional
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 28),
          textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: -0.1),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accent,
          textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
      dividerTheme: const DividerThemeData(color: border, thickness: 1, space: 0),
    );
  }
}

