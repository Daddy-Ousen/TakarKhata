import 'package:khatabook/core/utils/currency_formatter.dart';

/// Extension methods on [int] for monetary value operations.
///
/// In KhataBook, all monetary values are stored as integers
/// representing cents (smallest currency unit). These extensions
/// provide convenient conversion to display formats.
extension CentsExtensions on int {
  /// Convert cents to formatted currency string.
  /// Example: 125050.toCurrencyString() -> '৳1,250.50'
  String toCurrencyString() => CurrencyFormatter.format(this);

  /// Convert cents to formatted string without symbol.
  /// Example: 125050.toPlainCurrency() -> '1,250.50'
  String toPlainCurrency() => CurrencyFormatter.formatPlain(this);

  /// Convert cents to compact formatted string.
  /// Example: 1250000.toCompactCurrency() -> '৳12.5K'
  String toCompactCurrency() => CurrencyFormatter.formatCompact(this);

  /// Convert cents to major currency units (double).
  /// Example: 125050.asMajorUnits -> 1250.50
  /// WARNING: Only use for display, never for calculations.
  double get asMajorUnits => this / 100.0;

  /// Convert cents to signed currency string.
  /// Example: 125050.toSignedCurrency() -> '+৳1,250.50'
  String toSignedCurrency() => CurrencyFormatter.formatSigned(this);

  /// Whether this amount represents zero.
  bool get isZeroAmount => this == 0;

  /// Whether this amount is positive (income/credit).
  bool get isPositiveAmount => this > 0;

  /// Whether this amount is negative (expense/debit).
  bool get isNegativeAmount => this < 0;
}
