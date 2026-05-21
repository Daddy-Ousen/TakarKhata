import 'package:flutter/material.dart';

import 'color_schemes.dart';

/// Centralized typography system for the KhataBook application.
///
/// All text styles use the 'Inter' font family and default to
/// [AppColors.textPrimary] for color. The type scale follows Material 3
/// conventions with additional finance-specific styles for monetary values.
///
/// ## Usage
/// ```dart
/// Text('Total Balance', style: AppTextStyles.headlineMedium);
/// Text('৳12,500.00', style: AppTextStyles.balanceAmount);
/// ```
class AppTextStyles {
  AppTextStyles._();

  static const String _fontFamily = 'Inter';

  // ---------------------------------------------------------------------------
  // Display — hero numbers, splash screens
  // ---------------------------------------------------------------------------

  /// Display large — 57sp, light weight.
  static const TextStyle displayLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 57,
    fontWeight: FontWeight.w300,
    letterSpacing: -0.25,
    height: 1.12,
    color: AppColors.textPrimary,
  );

  /// Display medium — 45sp, light weight.
  static const TextStyle displayMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 45,
    fontWeight: FontWeight.w300,
    letterSpacing: 0,
    height: 1.16,
    color: AppColors.textPrimary,
  );

  /// Display small — 36sp, normal weight.
  static const TextStyle displaySmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 36,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.22,
    color: AppColors.textPrimary,
  );

  // ---------------------------------------------------------------------------
  // Headline — section headers, prominent labels
  // ---------------------------------------------------------------------------

  /// Headline large — 32sp, semi-bold.
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.25,
    color: AppColors.textPrimary,
  );

  /// Headline medium — 28sp, semi-bold.
  static const TextStyle headlineMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.29,
    color: AppColors.textPrimary,
  );

  /// Headline small — 24sp, semi-bold.
  static const TextStyle headlineSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.33,
    color: AppColors.textPrimary,
  );

  // ---------------------------------------------------------------------------
  // Title — card titles, app bar titles
  // ---------------------------------------------------------------------------

  /// Title large — 22sp, semi-bold.
  static const TextStyle titleLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.27,
    color: AppColors.textPrimary,
  );

  /// Title medium — 16sp, medium weight.
  static const TextStyle titleMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
    height: 1.5,
    color: AppColors.textPrimary,
  );

  /// Title small — 14sp, medium weight.
  static const TextStyle titleSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.43,
    color: AppColors.textPrimary,
  );

  // ---------------------------------------------------------------------------
  // Body — paragraphs, descriptions, content
  // ---------------------------------------------------------------------------

  /// Body large — 16sp, normal weight.
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
    height: 1.5,
    color: AppColors.textPrimary,
  );

  /// Body medium — 14sp, normal weight.
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    height: 1.43,
    color: AppColors.textPrimary,
  );

  /// Body small — 12sp, normal weight.
  static const TextStyle bodySmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.33,
    color: AppColors.textPrimary,
  );

  // ---------------------------------------------------------------------------
  // Label — buttons, chips, navigation items
  // ---------------------------------------------------------------------------

  /// Label large — 14sp, medium weight.
  static const TextStyle labelLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.43,
    color: AppColors.textPrimary,
  );

  /// Label medium — 12sp, medium weight.
  static const TextStyle labelMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.33,
    color: AppColors.textPrimary,
  );

  /// Label small — 11sp, medium weight.
  static const TextStyle labelSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.45,
    color: AppColors.textPrimary,
  );

  // ---------------------------------------------------------------------------
  // Finance-specific styles
  // ---------------------------------------------------------------------------

  /// Large bold balance display — used for account totals and net worth.
  ///
  /// Example: ৳1,25,000.00
  static const TextStyle balanceAmount = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 34,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.18,
    color: AppColors.textPrimary,
  );

  /// Medium amount for transaction list items.
  ///
  /// Example: +৳5,000.00 or -৳1,200.00
  static const TextStyle transactionAmount = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.5,
    color: AppColors.textPrimary,
  );

  /// Currency symbol style — matches [balanceAmount] size but lighter weight
  /// so the symbol doesn't visually overpower the numeric value.
  static const TextStyle currencySymbol = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.2,
    color: AppColors.textSecondary,
  );
}
