import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ─── DESIGN SYSTEM: Serenity Theme ───
  // Soft, calming gradients, glassmorphic white surfaces, elegant typography.
  
  // Background Gradient (Peach -> Soft Purple -> Pale Warm)
  static const LinearGradient mainGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFDFD1), // Soft Peach
      Color(0xFFE8D3EC), // Soft Lavender/Purple
      Color(0xFFF9EAE1), // Pale Warm Sand
    ],
    stops: [0.1, 0.5, 0.9],
  );

  // Color Tokens
  static const Color canvas       = Colors.transparent; // Let gradient show through
  static const Color surface      = Color(0xB3FFFFFF);  // 70% white (Glassmorphism)
  static const Color surfaceDim   = Color(0x66FFFFFF);  // 40% white
  static const Color border       = Color(0x4DFFFFFF);  // 30% white border
  static const Color textPrimary  = Color(0xFF3A3131);  // Deep soft charcoal/brown
  static const Color textSecondary= Color(0xFF7A7171);  // Soft slate
  static const Color textMuted    = Color(0xFFA19EAE);  // De-emphasized
  
  // Brand / Action
  static const Color accent       = Color(0xFFB46E96);  // Magenta/Purple
  static const Color accentSoft   = Color(0xFFFAD2E1);  // Soft pink tint
  static const Color positive     = Color(0xFF6BAF8D);  // Muted sage green
  static const Color positiveSoft = Color(0xFFE6F4EE);  // Soft green tint
  static const Color warmTone     = Color(0xFFED9D7A);  // Orange/Peach (Angry/Anxious)
  static const Color warmSoft     = Color(0xFFFDF1EC);  // Soft orange tint

  // Mood-specific colors matching the new chart design
  static const Color moodHappy    = Color(0xFFB46E96);  // Magenta/Purple
  static const Color moodStressed = Color(0xFF635F6A);  // Dark Grey
  static const Color moodAnxious  = Color(0xFFED9D7A);  // Soft Orange/Peach
  static const Color moodSad      = Color(0xFF7B8C9E);  // Soft Blue/Grey
  static const Color moodNeutral  = Color(0xFFC4B8C6);  // Soft Lilac Grey

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
        displayLarge:  basePlayfair.displayLarge?.copyWith(fontSize: 42, fontWeight: FontWeight.w600, color: textPrimary, letterSpacing: -0.5, height: 1.2),
        displayMedium: basePlayfair.displayMedium?.copyWith(fontSize: 32, fontWeight: FontWeight.w600, color: textPrimary, letterSpacing: -0.5, height: 1.2),
        titleLarge:    basePlayfair.titleLarge?.copyWith(fontSize: 24, fontWeight: FontWeight.w600, color: textPrimary, letterSpacing: -0.2),
        titleMedium:   GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: textPrimary),
        bodyLarge:     GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w400, color: textPrimary, height: 1.55),
        bodyMedium:    GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, color: textSecondary, height: 1.55),
        labelSmall:    GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: textMuted, letterSpacing: 0.5),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent, // Let gradient show
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: textPrimary),
        titleTextStyle: basePlayfair.titleLarge?.copyWith(
          color: textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          side: const BorderSide(color: Colors.white, width: 1.5), // subtle highlight
        ),
        margin: const EdgeInsets.symmetric(vertical: spacingSm),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: spacingMd, vertical: spacingMd),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: Colors.white, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: Colors.white, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: accent, width: 1.5),
        ),
        hintStyle: GoogleFonts.inter(color: textMuted, fontSize: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusXl)), // Very rounded
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 32),
          textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: -0.1),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accent,
          textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      dividerTheme: const DividerThemeData(color: border, thickness: 1, space: 0),
    );
  }
}
