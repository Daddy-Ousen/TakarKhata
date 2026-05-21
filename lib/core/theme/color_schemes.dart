import 'package:flutter/material.dart';

/// Curated color palette for the KhataBook finance application.
///
/// Uses HSL-derived colors for a premium dark finance dashboard aesthetic.
/// All colors are defined as static constants for compile-time safety and
/// consistency across the application.
///
/// Color groups:
/// - **Brand**: Primary brand identity colors
/// - **Backgrounds**: Layered dark surfaces following Material 3 elevation
/// - **Semantic**: Financial meaning-carrying colors (income, expense, etc.)
/// - **Text**: Three-tier text hierarchy (primary, secondary, muted)
/// - **Accent**: Complementary highlight colors
/// - **Chart**: Eight visually distinct colors for data visualization
class AppColors {
  AppColors._();

  // ---------------------------------------------------------------------------
  // Brand
  // ---------------------------------------------------------------------------

  /// Primary brand seed color — emerald green.
  static const Color seedColor = Color(0xFF2ECC71);

  // ---------------------------------------------------------------------------
  // Backgrounds — layered from deepest to most elevated
  // ---------------------------------------------------------------------------

  /// Deepest background — scaffold / root surface.
  static const Color backgroundDark = Color(0xFF0D1117);

  /// Slightly elevated surface — navigation rail, bottom bar.
  static const Color surfaceDark = Color(0xFF161B22);

  /// Card-level surface container.
  static const Color surfaceContainerDark = Color(0xFF1C2128);

  /// Elevated card or dialog surface.
  static const Color surfaceContainerHighDark = Color(0xFF21262D);

  // ---------------------------------------------------------------------------
  // Semantic financial colors
  // ---------------------------------------------------------------------------

  /// Income transactions — emerald green.
  static const Color income = Color(0xFF2ECC71);

  /// Expense transactions — coral red.
  static const Color expense = Color(0xFFE74C3C);

  /// Transfer transactions — electric blue.
  static const Color transfer = Color(0xFF3498DB);

  /// Warning / attention states — amber gold.
  static const Color warning = Color(0xFFF39C12);

  /// Savings goals / targets — teal.
  static const Color savings = Color(0xFF1ABC9C);

  /// Credit / liability indicators — orange.
  static const Color credit = Color(0xFFE67E22);

  // ---------------------------------------------------------------------------
  // Text hierarchy
  // ---------------------------------------------------------------------------

  /// Primary text — high-emphasis headings and body.
  static const Color textPrimary = Color(0xFFE6EDF3);

  /// Secondary text — supporting labels and descriptions.
  static const Color textSecondary = Color(0xFF8B949E);

  /// Muted text — disabled states, placeholders, dividers.
  static const Color textMuted = Color(0xFF484F58);

  // ---------------------------------------------------------------------------
  // Accent highlights
  // ---------------------------------------------------------------------------

  /// Blue accent — links, interactive elements.
  static const Color accentBlue = Color(0xFF58A6FF);

  /// Purple accent — tags, categories, badges.
  static const Color accentPurple = Color(0xFFBC8CFF);

  /// Cyan accent — info states, secondary highlights.
  static const Color accentCyan = Color(0xFF56D4DD);

  // ---------------------------------------------------------------------------
  // Chart palette — 8 visually distinct colors for data visualization
  // ---------------------------------------------------------------------------

  /// Eight distinct colors for pie charts, bar charts, and other
  /// data-visualization components. Ordered for maximum adjacent contrast.
  static const List<Color> chartPalette = [
    Color(0xFF2ECC71), // emerald green
    Color(0xFF3498DB), // electric blue
    Color(0xFFE74C3C), // coral red
    Color(0xFFF39C12), // amber gold
    Color(0xFF9B59B6), // amethyst purple
    Color(0xFF1ABC9C), // teal
    Color(0xFFE67E22), // orange
    Color(0xFF58A6FF), // sky blue
  ];
}
