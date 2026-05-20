// app_theme.dart — ganti SELURUH file ini:

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const _navy = Color(0xFF0D1B2A);
  static const _navyLight = Color(0xFF1B2E42);
  static const _cyan = Color(0xFF00D4FF);
  static const _amber = Color(0xFFFFC857);
  static const _green = Color(0xFF06D6A0);
  static const _red = Color(0xFFEF476F);
  static const _surface = Color(0xFF162032);
  static const _surfaceHigh = Color(0xFF1F3047);

  static ThemeData get darkTheme {
    // ← KUNCI: pakai ThemeData.dark() TANPA GoogleFonts sebagai base
    // lalu tambahkan Google Fonts HANYA di textTheme, bukan sebagai wrapper
    return ThemeData.dark(useMaterial3: true).copyWith(
      scaffoldBackgroundColor: _navy,
      colorScheme: const ColorScheme.dark(
        primary: _cyan,
        onPrimary: _navy,
        secondary: _amber,
        onSecondary: _navy,
        tertiary: _green,
        error: _red,
        surface: _surface,
        onSurface: Colors.white,
        surfaceContainerHighest: _surfaceHigh,
        primaryContainer: _navyLight,
        onPrimaryContainer: _cyan,
      ),
      // ← Fix utama: set iconTheme secara eksplisit
      iconTheme: const IconThemeData(
        color: Colors.white70,
        size: 24,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(
          color: Colors.white,
          size: 24,
        ),
        actionsIconTheme: IconThemeData(
          color: Colors.white,
          size: 24,
        ),
      ),
      // ← Gunakan copyWith textTheme, BUKAN GoogleFonts.xxxTextTheme()
      textTheme: _buildTextTheme(),
      cardTheme: CardThemeData(
        color: _surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.07)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _cyan,
          foregroundColor: _navy,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.orbitron(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _cyan,
          side: const BorderSide(color: _cyan, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.spaceGrotesk(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected) ? _cyan : Colors.white38),
        trackColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? _cyan.withValues(alpha: 0.4)
                : Colors.white12),
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData.light(useMaterial3: true).copyWith(
      scaffoldBackgroundColor: const Color(0xFFF0F4F8),
      iconTheme: const IconThemeData(
        color: Color(0xFF0D1B2A),
        size: 24,
      ),
      textTheme: _buildLightTextTheme(),
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF005F7A),
        onPrimary: Colors.white,
        secondary: Color(0xFFE8A000),
        surface: Colors.white,
        onSurface: Color(0xFF0D1B2A),
        surfaceContainerHighest: Color(0xFFE2ECF3),
        primaryContainer: Color(0xFFCCEEF7),
        onPrimaryContainer: Color(0xFF003D50),
        error: _red,
      ),
    );
  }

  // ← Bangun textTheme dari scratch dengan copyWith,
  //    BUKAN dengan GoogleFonts.xxxTextTheme() yang bisa corrupt icon font
  static TextTheme _buildTextTheme() {
    return TextTheme(
      displayLarge: GoogleFonts.orbitron(
        fontSize: 48,
        fontWeight: FontWeight.w700,
        color: Colors.white,
        letterSpacing: 2,
      ),
      displayMedium: GoogleFonts.orbitron(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      displaySmall: GoogleFonts.orbitron(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      headlineLarge: GoogleFonts.spaceGrotesk(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
      headlineMedium: GoogleFonts.spaceGrotesk(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      titleLarge: GoogleFonts.orbitron(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      titleMedium: GoogleFonts.spaceGrotesk(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      titleSmall: GoogleFonts.spaceGrotesk(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      bodyLarge: GoogleFonts.spaceGrotesk(
        fontSize: 16,
        color: Colors.white70,
      ),
      bodyMedium: GoogleFonts.spaceGrotesk(
        fontSize: 14,
        color: Colors.white60,
      ),
      bodySmall: GoogleFonts.spaceGrotesk(
        fontSize: 12,
        color: Colors.white54,
      ),
      labelLarge: GoogleFonts.spaceGrotesk(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
        color: Colors.white,
      ),
      labelMedium: GoogleFonts.spaceGrotesk(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: Colors.white70,
      ),
      labelSmall: GoogleFonts.spaceGrotesk(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        letterSpacing: 1.0,
        color: Colors.white54,
      ),
    );
  }

  static TextTheme _buildLightTextTheme() {
    return TextTheme(
      displayLarge: GoogleFonts.orbitron(
        fontSize: 48,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF0D1B2A),
      ),
      titleLarge: GoogleFonts.orbitron(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF0D1B2A),
      ),
      bodyLarge: GoogleFonts.spaceGrotesk(
        fontSize: 16,
        color: const Color(0xFF0D1B2A),
      ),
      bodyMedium: GoogleFonts.spaceGrotesk(
        fontSize: 14,
        color: const Color(0xFF334E68),
      ),
    );
  }
}
