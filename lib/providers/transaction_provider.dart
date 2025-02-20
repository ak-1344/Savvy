import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/transaction.dart';

class TransactionProvider with ChangeNotifier {
  final Box<Transaction> _transactionBox =
      Hive.box<Transaction>('transactions');

  TransactionProvider();

  List<Transaction> getTransactionsForLedger(String ledgerId) {
    return _transactionBox.values
        .where((transaction) => transaction.ledgerId == ledgerId)
        .toList();
  }

  Future<void> addTransaction(Transaction transaction) async {
    await _transactionBox.put(transaction.id, transaction);
    notifyListeners();
  }

  Future<void> deleteTransaction(String id) async {
    await _transactionBox.delete(id);
    notifyListeners();
  }

  Map<DateTime, double> getDailyExpenses(
    String ledgerId,
    DateTime startDate,
    DateTime endDate,
  ) {
    final transactions = _transactionBox.values.where((t) =>
        t.ledgerId == ledgerId &&
        t.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
        t.date.isBefore(endDate.add(const Duration(days: 1))) &&
        t.type == TransactionType.expense);

    final Map<DateTime, double> dailyTotals = {};
    for (var transaction in transactions) {
      final date = DateTime(
          transaction.date.year, transaction.date.month, transaction.date.day);
      dailyTotals[date] = (dailyTotals[date] ?? 0) + transaction.amount;
    }
    return dailyTotals;
  }

  Map<String, double> getCategoryTotals(
    String ledgerId,
    DateTime startDate,
    DateTime endDate,
  ) {
    final transactions = _transactionBox.values.where((t) =>
        t.ledgerId == ledgerId &&
        t.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
        t.date.isBefore(endDate.add(const Duration(days: 1))) &&
        t.type == TransactionType.expense);

    final Map<String, double> categoryTotals = {};
    for (var transaction in transactions) {
      categoryTotals[transaction.categoryId] =
          (categoryTotals[transaction.categoryId] ?? 0) + transaction.amount;
    }
    return categoryTotals;
  }

  double getTotalExpenses(
      String ledgerId, DateTime startDate, DateTime endDate) {
    return _transactionBox.values
        .where((transaction) =>
            transaction.ledgerId == ledgerId &&
            transaction.date.isAfter(startDate) &&
            transaction.date.isBefore(endDate) &&
            transaction.type == TransactionType.expense)
        .fold(0, (sum, transaction) => sum + transaction.amount);
  }

  double getTotalIncome(String ledgerId, DateTime startDate, DateTime endDate) {
    return _transactionBox.values
        .where((transaction) =>
            transaction.ledgerId == ledgerId &&
            transaction.date.isAfter(startDate) &&
            transaction.date.isBefore(endDate) &&
            transaction.type == TransactionType.income)
        .fold(0, (sum, transaction) => sum + transaction.amount);
  }

  double getLedgerBalance(String ledgerId) {
    final transactions = getTransactionsForLedger(ledgerId);
    return transactions.fold(0.0, (sum, transaction) {
      return sum +
          (transaction.type == TransactionType.income
              ? transaction.amount
              : -transaction.amount);
    });
  }
}
