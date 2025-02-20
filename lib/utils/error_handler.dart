import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class ErrorHandler {
  static String getErrorMessage(dynamic error) {
    if (error is HiveError) {
      return 'Database error: ${error.message}';
    } else {
      return error.toString();
    }
  }

  static void showError(BuildContext context, dynamic error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          error.toString(),
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }
} 