import 'package:intl/intl.dart';

class AppDateUtils {
  static String getMonthName(int month) {
    return DateFormat('MMMM').format(DateTime(2023, month));
  }

  static String formatDate(DateTime date) {
    return DateFormat('MMM d, y').format(date);
  }

  static String formatDateTime(DateTime date) {
    return DateFormat('MMM d, y HH:mm').format(date);
  }

  static DateTime getStartOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  static DateTime getEndOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0);
  }
} 