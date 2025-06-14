import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Light Theme Colors
  static const lightPrimary = Color(0xFF6366F1);
  static const lightSecondary = Color(0xFF8B5CF6);
  static const lightBackground = Color(0xFFFFFFFF);
  static const lightSurface = Color(0xFFF8FAFC);
  static const lightCardBackground = Color(0xFFFFFFFF);
  
  // Dark Theme Colors - Much Darker Palette
  static const darkPrimary = Color(0xFF818CF8);
  static const darkSecondary = Color(0xFFA78BFA);
  static const darkBackground = Color(0xFF060612);     // Almost black with subtle blue
  static const darkSurface = Color(0xFF0A0B1E);       // Very dark surface
  static const darkCardBackground = Color(0xFF0F1025); // Darker card background
  static const darkGlassBackground = Color(0xFF0D0E20);
  
  // Gradient Colors for Dark Theme - Much Darker
  static const darkGradientStart = Color(0xFF060612);   // Almost black
  static const darkGradientMid = Color(0xFF0A0B1E);     // Very dark navy
  static const darkGradientEnd = Color(0xFF0F1025);     // Dark with slight blue
  
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: lightPrimary,
      brightness: Brightness.light,
      primary: lightPrimary,
      secondary: lightSecondary,
      surface: lightSurface,
      background: lightBackground,
    ),
    textTheme: GoogleFonts.interTextTheme().copyWith(
      headlineLarge: GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.25,
      ),
      headlineSmall: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: lightCardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: Colors.grey.withOpacity(0.1),
          width: 1,
        ),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 16,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 0,
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
    ),
  );
  
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: darkPrimary,
      brightness: Brightness.dark,
      primary: darkPrimary,
      secondary: darkSecondary,
      surface: darkSurface,
      background: darkBackground,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: const Color(0xFFE2E8F0),
      onBackground: const Color(0xFFE2E8F0),
    ),
    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
      headlineLarge: GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: const Color(0xFFFFFFFF),
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.25,
        color: const Color(0xFFFFFFFF),
      ),
      headlineSmall: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: const Color(0xFFFFFFFF),
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: const Color(0xFFE2E8F0),
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: const Color(0xFFE2E8F0),
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: const Color(0xFFCBD5E1),
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: const Color(0xFFCBD5E1),
      ),
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: darkCardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: darkPrimary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 16,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 0,
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: darkPrimary,
      foregroundColor: Colors.white,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
    ),
    scaffoldBackgroundColor: darkBackground,
  );

  // Theme-aware gradient builders
  static LinearGradient getBackgroundGradient(bool isDark) {
    if (isDark) {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        stops: [0.0, 0.3, 0.6, 1.0],
        colors: [
          Color(0xFF000008), // Almost pure black with hint of blue
          Color(0xFF060612), // Very dark navy
          Color(0xFF0A0B1E), // Dark navy-purple
          Color(0xFF0F1025), // Slightly lighter dark
        ],
      );
    } else {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        stops: [0.0, 0.3, 0.6, 1.0],
        colors: [
          Color(0xFF667EEA), // Beautiful blue
          Color(0xFF764BA2), // Purple
          Color(0xFFF093FB), // Light pink
          Color(0xFFF5576C), // Coral
        ],
      );
    }
  }

  static LinearGradient getGlassmorphismGradient(bool isDark) {
    if (isDark) {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(0.08),  // Reduced for darker theme
          Colors.white.withOpacity(0.02),  // Very subtle
        ],
      );
    } else {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(0.25),
          Colors.white.withOpacity(0.15),
        ],
      );
    }
  }

  static BoxShadow getGlassShadow(bool isDark) {
    if (isDark) {
      return BoxShadow(
        color: Colors.black.withOpacity(0.5),  // Deeper shadow for darker theme
        blurRadius: 25,
        offset: const Offset(0, 12),
      );
    } else {
      return BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 20,
        offset: const Offset(0, 8),
      );
    }
  }

  static Color getGlassBorderColor(bool isDark) {
    if (isDark) {
      return Colors.white.withOpacity(0.12);  // Reduced for darker theme
    } else {
      return Colors.white.withOpacity(0.3);
    }
  }

  static Color getOrbColor(bool isDark) {
    if (isDark) {
      return Colors.white.withOpacity(0.02);  // Much more subtle for darker theme
    } else {
      return Colors.white.withOpacity(0.1);
    }
  }

  // Text color helpers for glassmorphism
  static Color getGlassTextColor(bool isDark) {
    if (isDark) {
      return const Color(0xFFE2E8F0);  // Light gray for better contrast with glass backgrounds
    } else {
      return const Color(0xFF1F2937);  // Dark gray for light mode
    }
  }

  static Color getGlassSecondaryTextColor(bool isDark) {
    if (isDark) {
      return const Color(0xFFCBD5E1);  // Softer light gray for secondary text
    } else {
      return const Color(0xFF6B7280);  // Medium gray for light mode
    }
  }
}
