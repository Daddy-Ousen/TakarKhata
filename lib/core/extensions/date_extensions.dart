/// Extension methods on [DateTime] for common date operations.
///
/// Provides convenient accessors for date boundaries used in
/// financial reporting and filtering.
extension DateTimeExtensions on DateTime {
  /// Returns this date at midnight (00:00:00.000).
  DateTime get startOfDay => DateTime(year, month, day);

  /// Returns this date at the last millisecond (23:59:59.999).
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59, 999);

  /// Returns the first day of this month at midnight.
  DateTime get startOfMonth => DateTime(year, month, 1);

  /// Returns the last day of this month at 23:59:59.999.
  DateTime get endOfMonth => DateTime(year, month + 1, 0, 23, 59, 59, 999);

  /// Returns January 1 of this year at midnight.
  DateTime get startOfYear => DateTime(year, 1, 1);

  /// Returns December 31 of this year at 23:59:59.999.
  DateTime get endOfYear => DateTime(year, 12, 31, 23, 59, 59, 999);

  /// Returns the first day of the previous month at midnight.
  DateTime get startOfPreviousMonth => DateTime(year, month - 1, 1);

  /// Returns the last day of the previous month at 23:59:59.999.
  DateTime get endOfPreviousMonth =>
      DateTime(year, month, 0, 23, 59, 59, 999);

  /// Whether this date falls on the same calendar day as [other].
  bool isSameDay(DateTime other) =>
      year == other.year && month == other.month && day == other.day;

  /// Whether this date falls in the same month and year as [other].
  bool isSameMonth(DateTime other) =>
      year == other.year && month == other.month;

  /// Whether this date falls in the same year as [other].
  bool isSameYear(DateTime other) => year == other.year;

  /// Whether this date is today.
  bool get isToday => isSameDay(DateTime.now());

  /// Whether this date was yesterday.
  bool get isYesterday =>
      isSameDay(DateTime.now().subtract(const Duration(days: 1)));

  /// Returns the number of days in this month.
  int get daysInMonth => DateTime(year, month + 1, 0).day;

  /// Returns the week number (ISO 8601) for this date.
  int get weekNumber {
    final dayOfYear = difference(DateTime(year, 1, 1)).inDays;
    return ((dayOfYear - weekday + 10) / 7).floor();
  }
}
