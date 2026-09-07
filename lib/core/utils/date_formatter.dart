import 'package:intl/intl.dart';

/// Formatting utilities for dates, timestamps, and deadline indicators.
class DateFormatter {
  DateFormatter._();

  static final DateFormat _displayDateFormat = DateFormat('MMM dd, yyyy');
  static final DateFormat _displayTimeFormat = DateFormat('hh:mm a');
  static final DateFormat _dateTimeFormat = DateFormat('MMM dd, yyyy • hh:mm a');
  static final DateFormat _isoFormat = DateFormat("yyyy-MM-dd'T'HH:mm:ss");

  /// Format DateTime to 'MMM dd, yyyy' (e.g. Feb 15, 2026)
  static String formatDate(DateTime? dateTime) {
    if (dateTime == null) return 'No due date';
    return _displayDateFormat.format(dateTime);
  }

  /// Format DateTime to 'hh:mm a' (e.g. 07:00 PM)
  static String formatTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    return _displayTimeFormat.format(dateTime);
  }

  /// Format DateTime to full 'MMM dd, yyyy • hh:mm a'
  static String formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'No due date';
    return _dateTimeFormat.format(dateTime);
  }

  /// Convert DateTime to ISO-8601 string for REST API payload
  static String toIsoString(DateTime dateTime) {
    return _isoFormat.format(dateTime);
  }

  /// Parse ISO-8601 string or return null on failure
  static DateTime? parseIsoString(dynamic dateValue) {
    if (dateValue == null) return null;
    if (dateValue is DateTime) return dateValue;
    try {
      return DateTime.parse(dateValue.toString());
    } catch (_) {
      return null;
    }
  }

  /// Check whether a due date is overdue compared to now
  static bool isOverdue(DateTime? dueDate) {
    if (dueDate == null) return false;
    return dueDate.isBefore(DateTime.now());
  }

  /// Check whether a date is due today
  static bool isDueToday(DateTime? dueDate) {
    if (dueDate == null) return false;
    final now = DateTime.now();
    return dueDate.year == now.year && dueDate.month == now.month && dueDate.day == now.day;
  }
}
