import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors (Deep forest greens and golden accents from guidelines)
  static const Color primaryColor = Color(0xFF0A3E2B); // Primary 1 (Deep Forest Green)
  static const Color secondaryColor = Color(0xFF4C8C5A); // Primary 2 (Leaf Green)
  static const Color accentColor = Color(0xFFD4A325); // Secondary (Golden Yellow)
  
  // Status Colors for DNA and Alerts
  static const Color poorColor = Color(0xFFDC3545); // Crimson Red
  static const Color fairColor = Color(0xFFEBB629); // Warning Gold (matches mockup hex)
  static const Color goodColor = Color(0xFF6FAF4F); // Leaf Green (matches mockup hex)
  static const Color excellentColor = Color(0xFF0A3E2B); // Deep Forest Green

  // Background and Surface
  static const Color backgroundColor = Color(0xFFF8F9FA); // Neutral Light
  static const Color surfaceColor = Colors.white;
  static const Color cardColor = Colors.white;
  
  // Text Colors
  static const Color textDark = Color(0xFF212529);
  static const Color textMedium = Color(0xFF495057);
  static const Color textLight = Color(0xFF6C757D);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: secondaryColor,
        background: backgroundColor,
        surface: surfaceColor,
      ),
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      cardTheme: CardTheme(
        color: cardColor,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.04),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.withOpacity(0.12), width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor, width: 1.5),
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey.withOpacity(0.05),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: poorColor, width: 1.5),
        ),
        labelStyle: GoogleFonts.inter(fontSize: 14, color: textLight),
      ),
      // Apply Google Fonts Inter for Body and Plus Jakarta Sans for Headers
      textTheme: GoogleFonts.interTextTheme().copyWith(
        headlineLarge: GoogleFonts.plusJakartaSans(fontSize: 32, fontWeight: FontWeight.bold, color: textDark),
        headlineMedium: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.bold, color: textDark),
        titleLarge: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w600, color: textDark),
        titleMedium: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w500, color: textDark),
        bodyLarge: GoogleFonts.inter(fontSize: 16, color: textMedium),
        bodyMedium: GoogleFonts.inter(fontSize: 14, color: textLight),
      ),
    );
  }
}
