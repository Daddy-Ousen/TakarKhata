import 'package:intl/intl.dart';
import 'package:khatabook/core/constants/app_constants.dart';

/// Formats monetary amounts from cents (integer) to display strings.
///
/// All monetary values in KhataBook are stored as integers representing
/// the smallest currency unit (cents/paisa). This class handles
/// conversion to human-readable format with proper grouping and symbols.
class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _formatter = NumberFormat.currency(
    symbol: AppConstants.currencySymbol,
    decimalDigits: AppConstants.currencyDecimalPlaces,
    locale: 'en_BD',
  );

  static final NumberFormat _compactFormatter = NumberFormat.compactCurrency(
    symbol: AppConstants.currencySymbol,
    decimalDigits: 1,
    locale: 'en_BD',
  );

  static final NumberFormat _plainFormatter = NumberFormat('#,##0.00');

  /// Format cents to full currency string.
  /// Example: 125050 -> '৳1,250.50'
  static String format(int cents) {
    final majorUnits = cents / 100.0;
    return _formatter.format(majorUnits);
  }

  /// Format cents without currency symbol.
  /// Example: 125050 -> '1,250.50'
  static String formatPlain(int cents) {
    final majorUnits = cents / 100.0;
    return _plainFormatter.format(majorUnits);
  }

  /// Format cents as compact string for dashboards.
  /// Example: 1250000 -> '৳12.5K'
  static String formatCompact(int cents) {
    final majorUnits = cents / 100.0;
    return _compactFormatter.format(majorUnits);
  }

  /// Format cents with sign indicator.
  /// Positive amounts get '+', negative get '-'.
  static String formatSigned(int cents) {
    final prefix = cents >= 0 ? '+' : '';
    return '$prefix${format(cents)}';
  }

  /// Parse a user-input string to cents.
  /// Example: '1,250.50' -> 125050
  /// Example: '1250.5' -> 125050
  /// Returns null if parsing fails.
  static int? parse(String input) {
    try {
      // Remove currency symbol and whitespace
      String cleaned = input
          .replaceAll(AppConstants.currencySymbol, '')
          .replaceAll(',', '')
          .replaceAll(' ', '')
          .trim();

      if (cleaned.isEmpty) return null;

      final value = double.tryParse(cleaned);
      if (value == null) return null;

      return (value * 100).round();
    } catch (_) {
      return null;
    }
  }

  /// Parse a user-input string to cents, throwing on failure.
  static int parseOrThrow(String input) {
    final result = parse(input);
    if (result == null) {
      throw FormatException('Cannot parse "$input" as currency amount');
    }
    return result;
  }
}
