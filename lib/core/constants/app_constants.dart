/// Application-wide constants for KhataBook.
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'KhataBook';
  static const String appVersion = '1.0.0';

  // Database
  static const String databaseName = 'khatabook.db';
  static const int databaseVersion = 1;

  // Currency
  static const String currencySymbol = '৳';
  static const String currencyCode = 'BDT';
  static const int currencyDecimalPlaces = 2;

  // Validation
  /// Maximum transaction amount in cents (999,999.99)
  static const int maxTransactionAmount = 99999999;

  /// Minimum transaction amount in cents (0.01)
  static const int minTransactionAmount = 1;

  // Sync
  static const int syncSchemaVersion = 1;
  static const String syncFileExtension = '.khatabook';

  // UI
  static const int defaultPageSize = 50;
  static const int searchDebounceMs = 300;
  static const int animationDurationMs = 300;

  // Breakpoints
  static const double mobileBreakpoint = 600;
  static const double desktopBreakpoint = 1200;
}
