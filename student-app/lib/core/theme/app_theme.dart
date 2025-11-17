import 'package:flutter/material.dart';

class AppTheme {
  // Light Theme Colors
  static const Color primaryColor = Color(0xFF1976D2);
  static const Color secondaryColor = Color(0xFF03A9F4);
  static const Color accentColor = Color(0xFFFF9800);
  static const Color backgroundColor = Color(0xFFF5F7FA);
  static const Color surfaceColor = Colors.white;
  static const Color cardColor = Colors.white;
  static const Color errorColor = Color(0xFFE53935);
  static const Color successColor = Color(0xFF43A047);
  static const Color warningColor = Color(0xFFFB8C00);
  static const Color textPrimaryColor = Color(0xFF212121);
  static const Color textSecondaryColor = Color(0xFF757575);
  static const Color dividerColor = Color(0xFFE0E0E0);

  // Dark Theme Colors
  static const Color darkPrimaryColor = Color(0xFF90CAF9);
  static const Color darkSecondaryColor = Color(0xFF4FC3F7);
  static const Color darkAccentColor = Color(0xFFFFB74D);
  static const Color darkBackgroundColor = Color(0xFF121212);
  static const Color darkSurfaceColor = Color(0xFF1E1E1E);
  static const Color darkCardColor = Color(0xFF2C2C2C);
  static const Color darkTextPrimaryColor = Color(0xFFE0E0E0);
  static const Color darkTextSecondaryColor = Color(0xFFB0B0B0);
  static const Color darkDividerColor = Color(0xFF404040);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1976D2), Color(0xFF1565C0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFFF9800), Color(0xFFF57C00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Text Styles
  static const TextStyle headingLarge = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: textPrimaryColor,
    fontFamily: 'Poppins',
  );

  static const TextStyle headingMedium = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: textPrimaryColor,
    fontFamily: 'Poppins',
  );

  static const TextStyle headingSmall = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: textPrimaryColor,
    fontFamily: 'Poppins',
  );

  static const TextStyle titleLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: textPrimaryColor,
    fontFamily: 'Poppins',
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: textPrimaryColor,
    fontFamily: 'Poppins',
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: textPrimaryColor,
    fontFamily: 'Poppins',
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: textPrimaryColor,
    fontFamily: 'Poppins',
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: textSecondaryColor,
    fontFamily: 'Poppins',
  );

  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: textPrimaryColor,
    fontFamily: 'Poppins',
  );

  // Theme Data
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        error: errorColor,
        background: backgroundColor,
        surface: surfaceColor,
      ),
      scaffoldBackgroundColor: backgroundColor,
      fontFamily: 'Poppins',

      // AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          fontFamily: 'Poppins',
        ),
      ),

      // Card Theme
      cardTheme: CardTheme(
        color: surfaceColor,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: textSecondaryColor,
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          fontFamily: 'Poppins',
        ),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: const TextStyle(
          fontSize: 14,
          color: textSecondaryColor,
          fontFamily: 'Poppins',
        ),
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
    );
  }

  // Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: darkPrimaryColor,
        secondary: darkSecondaryColor,
        error: errorColor,
        background: darkBackgroundColor,
        surface: darkSurfaceColor,
      ),
      scaffoldBackgroundColor: darkBackgroundColor,
      fontFamily: 'Poppins',

      // AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: darkSurfaceColor,
        foregroundColor: darkTextPrimaryColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: darkTextPrimaryColor,
          fontFamily: 'Poppins',
        ),
      ),

      // Card Theme
      cardTheme: CardTheme(
        color: darkCardColor,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarThemeData: BottomNavigationBarThemeData(
        backgroundColor: darkSurfaceColor,
        selectedItemColor: darkPrimaryColor,
        unselectedItemColor: darkTextSecondaryColor,
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          fontFamily: 'Poppins',
        ),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkPrimaryColor,
          foregroundColor: darkBackgroundColor,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: darkDividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: darkDividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: darkPrimaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: TextStyle(
          fontSize: 14,
          color: darkTextSecondaryColor,
          fontFamily: 'Poppins',
        ),
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: darkAccentColor,
        foregroundColor: darkBackgroundColor,
        elevation: 4,
      ),
    );
  }

  // Spacing
  static const double spacingXS = 4;
  static const double spacingS = 8;
  static const double spacingM = 16;
  static const double spacingL = 24;
  static const double spacingXL = 32;

  // Border Radius
  static const double radiusS = 8;
  static const double radiusM = 12;
  static const double radiusL = 16;
  static const double radiusXL = 24;
}
