// lib/app/core/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Modern medical-themed vibrant green color palette (Refined from screenshot)
  static const Color primaryGreen = Color(0xFF13C296); // Vibrant Green
  static const Color deepGreen = Color(0xFF045844);
  static const Color accentGreen = Color(0xFF13C296);
  static const Color lightGreen = Color(0xFFF0FFF4);
  static const Color successGreen = Color(0xFF22C55E);
  static const Color warningOrange = Color(0xFFF59E0B);
  static const Color errorRed = Color(0xFFEF4444);
  
  static const Color primaryBlue = Color(0xFF2196F3); // Modern Blue for icons
  static const Color lightBlue = Color(0xFFE3F2FD);
  
  static const Color textDark = Color(0xFF111928); // Darker for high contrast
  static const Color textLight = Color(0xFF637085); // Modern grayish subtext
  static const Color backgroundLight = Color(0xFFFBFCFB);

  // Gradient definitions (Refined)
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF13C296), Color(0xFF0D9D7A)],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2196F3), Color(0xFF1E88E5)],
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF9FAFB), Color(0xFFFFFFFF)],
  );

  static final lightTheme = ThemeData(
    useMaterial3: true,
    primaryColor: primaryGreen,
    scaffoldBackgroundColor: backgroundLight,
    colorScheme: ColorScheme.light(
      primary: primaryGreen,
      secondary: primaryBlue,
      surface: Colors.white,
      error: errorRed,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
    ),
    
    // Text theme with modern hierarchy
    textTheme: TextTheme(
      displayLarge: GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: textDark,
      ),
      displayMedium: GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: textDark,
      ),
      displaySmall: GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: textDark,
      ),
      headlineMedium: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: textDark,
      ),
      titleLarge: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: textDark,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        color: textDark,
        fontWeight: FontWeight.w500,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        color: textLight,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        color: textLight,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),

    // AppBar theme (Clean and Minimal)
    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: false, // Left aligned as in screenshot
      backgroundColor: Colors.transparent,
      foregroundColor: textDark,
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: textDark,
      ),
      iconTheme: const IconThemeData(color: textDark, size: 24),
    ),

    // Input decoration theme (Modern Borderlessish look)
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryGreen, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: errorRed, width: 1),
      ),
      labelStyle: GoogleFonts.inter(fontSize: 14, color: textLight),
      hintStyle: GoogleFonts.inter(fontSize: 14, color: Colors.grey.shade400),
    ),

    // Elevated button theme (Vibrant Green)
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        textStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),

    // Card theme (Subtle elevation and soft corners)
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade100, width: 1),
      ),
      color: Colors.white,
    ),
  );
}
