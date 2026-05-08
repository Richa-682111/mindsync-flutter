import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ─── DESIGN SYSTEM: Nature-Organic Wellness Theme ───
  // Earthy greens, warm cream, botanical accents, clean white cards.

  // Background Color (Warm cream)
  static const Color mainBackgroundColor = Color(0xFFF5F0E8);

  // Color Tokens
  static const Color canvas       = Color(0xFFF5F0E8); // Warm cream
  static const Color surface      = Color(0xFFFFFFFF); // Clean white cards
  static const Color surfaceDim   = Color(0xFFF0EBE3); // Slightly darker cream
  static const Color border       = Color(0xFFE8E2D8); // Warm border
  static const Color textPrimary  = Color(0xFF2D3A2D); // Deep forest green
  static const Color textSecondary= Color(0xFF6B7B6B); // Muted olive
  static const Color textMuted    = Color(0xFF9CA89C); // De-emphasized sage

  // Brand / Action — Sage Green
  static const Color accent       = Color(0xFF4A6741); // Primary sage green
  static const Color accentSoft   = Color(0xFFE8EFE6); // Light sage tint
  static const Color accentDark   = Color(0xFF3A5234); // Darker sage

  // Secondary Nature Colors
  static const Color positive     = Color(0xFF6B8F5E); // Moss green
  static const Color positiveSoft = Color(0xFFE6F0E2); // Soft moss tint
  static const Color warmTone     = Color(0xFFC4956A); // Warm earth/amber
  static const Color warmSoft     = Color(0xFFF5E6D0); // Soft peach/cream

  // Featured Card Backgrounds
  static const Color cardPink     = Color(0xFFF2DBD5); // Soft blush
  static const Color cardPeach    = Color(0xFFF5E6D0); // Warm peach
  static const Color cardSage     = Color(0xFFD8E4D2); // Soft sage
  static const Color cardLavender = Color(0xFFE8E0EC); // Soft lavender

  // Mood-specific colors — nature palette
  static const Color moodHappy    = Color(0xFF6B8F5E); // Moss green
  static const Color moodStressed = Color(0xFF8B7355); // Earth brown
  static const Color moodAnxious  = Color(0xFFC4956A); // Warm amber
  static const Color moodSad      = Color(0xFF7B94A8); // Sky sage/blue
  static const Color moodNeutral  = Color(0xFFA8B5A0); // Muted sage
  static const Color moodLove     = Color(0xFFB87E7E); // Earthy rose
  static const Color moodConfused = Color(0xFF9B8EC4); // Soft violet

  // ─── Spacing & Corner Radius ───
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;

  static const double radiusSm = 12.0;
  static const double radiusMd = 16.0;
  static const double radiusLg = 24.0;
  static const double radiusXl = 32.0;

  static ThemeData get lightTheme {
    final baseInter = GoogleFonts.interTextTheme();
    final basePlayfair = GoogleFonts.playfairDisplayTextTheme();

    return ThemeData(
      scaffoldBackgroundColor: canvas,
      colorScheme: const ColorScheme.light(
        primary: accent,
        secondary: positive,
        surface: surface,
      ),
      textTheme: baseInter.copyWith(
        displayLarge:  basePlayfair.displayLarge?.copyWith(fontSize: 42, fontWeight: FontWeight.w700, color: textPrimary, letterSpacing: -0.5, height: 1.2),
        displayMedium: basePlayfair.displayMedium?.copyWith(fontSize: 32, fontWeight: FontWeight.w700, color: textPrimary, letterSpacing: -0.5, height: 1.2),
        titleLarge:    basePlayfair.titleLarge?.copyWith(fontSize: 24, fontWeight: FontWeight.w700, color: textPrimary, letterSpacing: -0.2),
        titleMedium:   GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: textPrimary),
        bodyLarge:     GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w400, color: textPrimary, height: 1.55),
        bodyMedium:    GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, color: textSecondary, height: 1.55),
        labelSmall:    GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: textMuted, letterSpacing: 0.5),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: textPrimary),
        titleTextStyle: basePlayfair.titleLarge?.copyWith(
          color: textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          side: const BorderSide(color: border, width: 1),
        ),
        margin: const EdgeInsets.symmetric(vertical: spacingSm),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceDim,
        contentPadding: const EdgeInsets.symmetric(horizontal: spacingMd, vertical: spacingMd),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusXl),
          borderSide: const BorderSide(color: border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusXl),
          borderSide: const BorderSide(color: border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusXl),
          borderSide: const BorderSide(color: accent, width: 1.5),
        ),
        hintStyle: GoogleFonts.inter(color: textMuted, fontSize: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusXl)),
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 32),
          textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: -0.1),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: accent,
          side: const BorderSide(color: accent, width: 1.2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusXl)),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          textStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accent,
          textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      dividerTheme: const DividerThemeData(color: border, thickness: 1, space: 0),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceDim,
        selectedColor: accentSoft,
        labelStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: const BorderSide(color: border),
      ),
    );
  }
}
