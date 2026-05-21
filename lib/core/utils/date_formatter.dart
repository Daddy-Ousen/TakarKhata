import 'package:intl/intl.dart';

/// Date formatting utilities for the KhataBook application.
///
/// Provides consistent date/time formatting throughout the UI.
class DateFormatter {
  DateFormatter._();

  static final DateFormat _dateFormat = DateFormat('MMM dd, yyyy');
  static final DateFormat _dateTimeFormat = DateFormat('MMM dd, yyyy HH:mm');
  static final DateFormat _monthYearFormat = DateFormat('MMMM yyyy');
  static final DateFormat _shortMonthYear = DateFormat('MMM yyyy');
  static final DateFormat _dayMonth = DateFormat('dd MMM');
  static final DateFormat _timeOnly = DateFormat('HH:mm');
  static final DateFormat _isoDate = DateFormat('yyyy-MM-dd');

  /// Format as 'MMM dd, yyyy' (e.g., 'May 20, 2026')
  static String formatDate(DateTime date) => _dateFormat.format(date);

  /// Format as 'MMM dd, yyyy HH:mm' (e.g., 'May 20, 2026 14:30')
  static String formatDateTime(DateTime date) => _dateTimeFormat.format(date);

  /// Format as 'MMMM yyyy' (e.g., 'May 2026')
  static String formatMonthYear(DateTime date) => _monthYearFormat.format(date);

  /// Format as 'MMM yyyy' (e.g., 'May 2026')
  static String formatShortMonthYear(DateTime date) =>
      _shortMonthYear.format(date);

  /// Format as 'dd MMM' (e.g., '20 May')
  static String formatDayMonth(DateTime date) => _dayMonth.format(date);

  /// Format as 'HH:mm' (e.g., '14:30')
  static String formatTime(DateTime date) => _timeOnly.format(date);

  /// Format as ISO date 'yyyy-MM-dd' (e.g., '2026-05-20')
  static String formatIso(DateTime date) => _isoDate.format(date);

  /// Format as relative string: 'Today', 'Yesterday', or 'MMM dd'.
  /// Uses the device's local time zone for comparison.
  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateDay = DateTime(date.year, date.month, date.day);

    final difference = today.difference(dateDay).inDays;

    if (difference == 0) return 'Today';
    if (difference == 1) return 'Yesterday';
    if (difference == -1) return 'Tomorrow';
    if (difference > 0 && difference <= 6) return '${difference}d ago';
    if (date.year == now.year) return _dayMonth.format(date);
    return _dateFormat.format(date);
  }

  /// Format a date range for display.
  /// Example: 'May 01 - May 31, 2026'
  static String formatDateRange(DateTime from, DateTime to) {
    if (from.year == to.year && from.month == to.month) {
      return '${DateFormat('MMM dd').format(from)} - ${DateFormat('dd, yyyy').format(to)}';
    }
    if (from.year == to.year) {
      return '${DateFormat('MMM dd').format(from)} - ${DateFormat('MMM dd, yyyy').format(to)}';
    }
    return '${formatDate(from)} - ${formatDate(to)}';
  }
}
