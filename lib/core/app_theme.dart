import 'package:flutter/material.dart';

class AppTheme {
  // ============================================================
  // BRAND COLORS
  // ============================================================

  static const Color primary = Color(0xFF5B4FD8);
  static const Color primaryDark = Color(0xFF3730A3);
  static const Color deepBlue = Color(0xFF183B8C);

  static const Color success = Color(0xFF1F9D61);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFE5484D);

  static const Color surface = Color(0xFFF7F8FC);
  static const Color cardColor = Colors.white;

  static const Color textPrimary = Color(0xFF20232A);
  static const Color textSecondary = Color(0xFF6B7280);

  static const Color borderColor = Color(0xFFE7E9F1);

  // ============================================================
  // LIGHT THEME
  // ============================================================

  static ThemeData get light {
    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
    ).copyWith(
      primary: primary,
      secondary: deepBlue,
      surface: Colors.white,
      error: danger,
    );

    return ThemeData(
      useMaterial3: true,

      colorScheme: scheme,

      scaffoldBackgroundColor: surface,

      fontFamily: null,

      // ========================================================
      // APP BAR
      // ========================================================

      appBarTheme: const AppBarTheme(
        backgroundColor: surface,
        foregroundColor: textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
        iconTheme: IconThemeData(
          color: textPrimary,
        ),
      ),

      // ========================================================
      // CARDS
      // ========================================================

      cardTheme: CardThemeData(
        elevation: 0,
        color: cardColor,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(
            color: borderColor,
          ),
        ),
      ),

      // ========================================================
      // INPUT FIELDS
      // ========================================================

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),

        hintStyle: const TextStyle(
          color: Color(0xFF9CA3AF),
          fontSize: 14,
        ),

        labelStyle: const TextStyle(
          color: textSecondary,
          fontWeight: FontWeight.w500,
        ),

        prefixIconColor: primary,
        suffixIconColor: textSecondary,

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: borderColor,
          ),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: borderColor,
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: primary,
            width: 1.7,
          ),
        ),

        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: danger,
          ),
        ),

        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: danger,
            width: 1.5,
          ),
        ),
      ),

      // ========================================================
      // FILLED BUTTON
      // ========================================================

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,

          minimumSize: const Size.fromHeight(50),

          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 14,
          ),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),

          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      // ========================================================
      // ELEVATED BUTTON
      // ========================================================

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,

          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 14,
          ),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),

          textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      // ========================================================
      // OUTLINED BUTTON
      // ========================================================

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,

          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 14,
          ),

          side: const BorderSide(
            color: primary,
          ),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),

          textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      // ========================================================
      // TEXT BUTTON
      // ========================================================

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      // ========================================================
      // FLOATING ACTION BUTTON
      // ========================================================

      floatingActionButtonTheme:
      const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 3,
      ),

      // ========================================================
      // NAVIGATION BAR
      // ========================================================

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        elevation: 5,
        height: 68,

        indicatorColor:
        primary.withOpacity(0.12),

        iconTheme: WidgetStateProperty.resolveWith(
              (states) {
            if (states.contains(
              WidgetState.selected,
            )) {
              return const IconThemeData(
                color: primary,
                size: 25,
              );
            }

            return const IconThemeData(
              color: Color(0xFF777D89),
              size: 24,
            );
          },
        ),

        labelTextStyle:
        WidgetStateProperty.resolveWith(
              (states) {
            if (states.contains(
              WidgetState.selected,
            )) {
              return const TextStyle(
                color: primary,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              );
            }

            return const TextStyle(
              color: Color(0xFF777D89),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            );
          },
        ),
      ),

      // ========================================================
      // DIVIDER
      // ========================================================

      dividerTheme: const DividerThemeData(
        color: borderColor,
        thickness: 1,
      ),

      // ========================================================
      // PROGRESS INDICATOR
      // ========================================================

      progressIndicatorTheme:
      const ProgressIndicatorThemeData(
        color: primary,
      ),

      // ========================================================
      // SNACK BAR
      // ========================================================

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: textPrimary,

        contentTextStyle: const TextStyle(
          color: Colors.white,
        ),

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      // ========================================================
      // DIALOG
      // ========================================================

      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),

      // ========================================================
      // LIST TILE
      // ========================================================

      listTileTheme: const ListTileThemeData(
        iconColor: primary,
        textColor: textPrimary,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 4,
        ),
      ),

      // ========================================================
      // TEXT
      // ========================================================

      textTheme: const TextTheme(
        headlineSmall: TextStyle(
          color: textPrimary,
          fontWeight: FontWeight.w900,
        ),

        titleLarge: TextStyle(
          color: textPrimary,
          fontWeight: FontWeight.w800,
        ),

        titleMedium: TextStyle(
          color: textPrimary,
          fontWeight: FontWeight.w700,
        ),

        bodyLarge: TextStyle(
          color: textPrimary,
        ),

        bodyMedium: TextStyle(
          color: textSecondary,
        ),
      ),
    );
  }
}