import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
// ignore: depend_on_referenced_packages
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart'; // Add this import
import '../providers/ledger_provider.dart';

class ExportService {
  Future<void> exportToCSV(LedgerProvider provider) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/savvy_export.csv');
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

    final buffer = StringBuffer();

    // Write headers
    buffer.writeln('Date,Type,Category,Amount,Notes');

    // Write transactions
    for (final transaction in provider.getAllTransactions()) {
      final category = provider.getCategoryById(transaction.categoryId);
      buffer.writeln(
        '${dateFormat.format(transaction.timestamp)},${transaction.isIncome ? "Income" : "Expense"},'
        '${category?.name ?? "Unknown"},${transaction.amount},"${transaction.notes ?? ""}"',
      );
    }

    await file.writeAsString(buffer.toString());
  }

  Future<void> importFromCSV(LedgerProvider provider) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result != null) {
      final file = File(result.files.single.path!);
      final lines = await file.readAsLines();

      // Skip header
      for (var i = 1; i < lines.length; i++) {
        final fields = lines[i].split(',');
        if (fields.length >= 4) {
          final date = DateTime.parse(fields[0]);
          final isIncome = fields[1] == 'Income';
          final categoryName = fields[2];
          final amount = double.parse(fields[3]);
          final notes = fields.length > 4 ? fields[4].replaceAll('"', '') : '';

          // Find or create category
          var category = provider.getCategoryByName(categoryName);
          if (category == null) {
            await provider.addCategory(categoryName, '📁');
            category = provider.getCategoryByName(categoryName);
          }

          if (category != null) {
            if (isIncome) {
              await provider.addIncome(category.id, amount, notes: notes);
            } else {
              await provider.addExpense(category.id, amount, notes: notes);
            }
          }
        }
      }
    }
  }
}

extension on LedgerProvider {
  getCategoryByName(String categoryName) {
    return categories.firstWhere(
      (category) => category.name == categoryName,
    );
  }
}
