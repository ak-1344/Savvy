import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/budget.dart';
import '../models/category.dart' as models;
import '../models/transaction.dart';

class BudgetProvider with ChangeNotifier {
  late final Box<Budget> _budgetBox;
  final Box<models.Category> _categoryBox;
  final Box<Transaction> _transactionBox;
  final String _currentLedgerId;

  BudgetProvider({
    required Box<models.Category> categoryBox,
    required Box<Transaction> transactionBox,
    required String currentLedgerId,
    required Box<Budget> budgetBox,
  })  : _categoryBox = categoryBox,
        _transactionBox = transactionBox,
        _currentLedgerId = currentLedgerId {
    _budgetBox = Hive.box<Budget>('budgets');
    _initializeBudgets();
  }

  List<Budget> _budgets = [];
  List<Budget> get budgets => _budgets;

  void _initializeBudgets() {
    _budgets = _budgetBox.values
        .where((budget) => budget.ledgerId == _currentLedgerId)
        .toList();

    for (var budget in _budgets) {
      budget.category = _categoryBox.get(budget.categoryId);
      budget.spent = _calculateCurrentAmount(budget.categoryId);
    }

    notifyListeners();
  }

  double _calculateCurrentAmount(String categoryId) {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);

    return _transactionBox.values
        .where((transaction) =>
            transaction.categoryId == categoryId &&
            transaction.timestamp.isAfter(startOfMonth) &&
            !transaction.isIncome &&
            !transaction.isTransfer)
        .fold(0.0, (sum, transaction) => sum + transaction.amount);
  }

  Future<void> createBudget({
    required String categoryId,
    required double amount,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final budget = Budget(
      id: const Uuid().v4(),
      categoryId: categoryId,
      amount: amount,
      ledgerId: _currentLedgerId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      name: '',
      startDate: startDate,
      endDate: endDate,
    );

    budget.category = _categoryBox.get(categoryId);
    budget.spent = _calculateCurrentAmount(categoryId);

    await _budgetBox.put(budget.id, budget);
    _budgets.add(budget);
    notifyListeners();
  }

  Future<void> updateBudget(String id, result, {required double amount}) async {
    final budget = _budgetBox.get(id);
    if (budget != null) {
      budget.amount = amount;
      await _budgetBox.put(id, budget);
      notifyListeners();
    }
  }

  Future<void> deleteBudget(String id) async {
    await _budgetBox.delete(id);
    _budgets.removeWhere((budget) => budget.id == id);
    notifyListeners();
  }

  void updateAmounts() {
    for (var budget in _budgets) {
      budget.spent = _calculateCurrentAmount(budget.categoryId);
    }
    notifyListeners();
  }

  addBudget(result, result2) {}
}
