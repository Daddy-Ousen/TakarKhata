import 'package:flutter/material.dart';

import 'color_schemes.dart';
import 'text_styles.dart';

/// Application-wide theme configuration for KhataBook.
///
/// Provides a fully configured Material 3 dark theme optimized for a
/// finance dashboard. All component themes are explicitly set to ensure
/// consistency regardless of Flutter version defaults.
///
/// ## Usage
/// ```dart
/// MaterialApp(
///   theme: AppTheme.darkTheme,
///   // ...
/// )
/// ```
class AppTheme {
  AppTheme._();

  /// The primary dark theme for the application.
  ///
  /// Built on Material 3 with a custom [ColorScheme] seeded from
  /// [AppColors.seedColor] and overridden surface colors for the
  /// layered dark background aesthetic.
  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.seedColor,
      brightness: Brightness.dark,
    ).copyWith(
      surface: AppColors.backgroundDark,
      onSurface: AppColors.textPrimary,
      surfaceContainerLow: AppColors.surfaceDark,
      surfaceContainer: AppColors.surfaceContainerDark,
      surfaceContainerHigh: AppColors.surfaceContainerHighDark,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      fontFamily: 'Inter',

      // -------------------------------------------------------------------
      // App Bar
      // -------------------------------------------------------------------
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.backgroundDark,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        titleTextStyle: AppTextStyles.titleLarge,
      ),

      // -------------------------------------------------------------------
      // Navigation Rail (desktop sidebar)
      // -------------------------------------------------------------------
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: AppColors.surfaceDark,
        selectedIconTheme: const IconThemeData(color: AppColors.income),
        unselectedIconTheme: const IconThemeData(color: AppColors.textSecondary),
        indicatorColor: AppColors.income.withValues(alpha: 0.15),
      ),

      // -------------------------------------------------------------------
      // Bottom Navigation Bar (legacy — kept for compatibility)
      // -------------------------------------------------------------------
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceDark,
        selectedItemColor: AppColors.income,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // -------------------------------------------------------------------
      // Navigation Bar (Material 3 — mobile)
      // -------------------------------------------------------------------
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surfaceDark,
        indicatorColor: AppColors.income.withValues(alpha: 0.15),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.income);
          }
          return const IconThemeData(color: AppColors.textSecondary);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTextStyles.labelSmall
                .copyWith(color: AppColors.income);
          }
          return AppTextStyles.labelSmall
              .copyWith(color: AppColors.textSecondary);
        }),
      ),

      // -------------------------------------------------------------------
      // Card
      // -------------------------------------------------------------------
      cardTheme: CardThemeData(
        color: AppColors.surfaceContainerDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: AppColors.textMuted.withValues(alpha: 0.2),
          ),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),

      // -------------------------------------------------------------------
      // Input Decoration
      // -------------------------------------------------------------------
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceContainerHighDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.textMuted.withValues(alpha: 0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.income, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.expense),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.expense, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textMuted,
        ),
        labelStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textSecondary,
        ),
      ),

      // -------------------------------------------------------------------
      // Elevated Button
      // -------------------------------------------------------------------
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.income,
          foregroundColor: AppColors.backgroundDark,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: AppTextStyles.labelLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // -------------------------------------------------------------------
      // Text Button
      // -------------------------------------------------------------------
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.accentBlue,
          textStyle: AppTextStyles.labelLarge,
        ),
      ),

      // -------------------------------------------------------------------
      // Outlined Button
      // -------------------------------------------------------------------
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: BorderSide(
            color: AppColors.textMuted.withValues(alpha: 0.4),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // -------------------------------------------------------------------
      // Floating Action Button
      // -------------------------------------------------------------------
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.income,
        foregroundColor: AppColors.backgroundDark,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // -------------------------------------------------------------------
      // Dialog
      // -------------------------------------------------------------------
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surfaceContainerDark,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        titleTextStyle: AppTextStyles.titleLarge,
        contentTextStyle: AppTextStyles.bodyMedium,
      ),

      // -------------------------------------------------------------------
      // Snackbar
      // -------------------------------------------------------------------
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surfaceContainerHighDark,
        contentTextStyle: AppTextStyles.bodyMedium,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      // -------------------------------------------------------------------
      // Divider
      // -------------------------------------------------------------------
      dividerTheme: DividerThemeData(
        color: AppColors.textMuted.withValues(alpha: 0.2),
        thickness: 1,
      ),

      // -------------------------------------------------------------------
      // Chip
      // -------------------------------------------------------------------
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceContainerHighDark,
        selectedColor: AppColors.income.withValues(alpha: 0.2),
        side: BorderSide(
          color: AppColors.textMuted.withValues(alpha: 0.3),
        ),
        labelStyle: AppTextStyles.labelMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),

      // -------------------------------------------------------------------
      // Bottom Sheet
      // -------------------------------------------------------------------
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surfaceContainerDark,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),

      // -------------------------------------------------------------------
      // Switch
      // -------------------------------------------------------------------
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.income;
          }
          return AppColors.textMuted;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.income.withValues(alpha: 0.3);
          }
          return AppColors.surfaceContainerHighDark;
        }),
      ),

      // -------------------------------------------------------------------
      // Progress Indicator
      // -------------------------------------------------------------------
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.income,
        linearTrackColor: AppColors.surfaceContainerHighDark,
      ),
    );
  }
}
