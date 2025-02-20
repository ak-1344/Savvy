import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/ledger.dart';
import '../models/transaction.dart';
import '../models/category.dart' as models;
import '../models/analytics/analytics_data.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class LedgerProvider with ChangeNotifier {
  final Box<Ledger> _ledgerBox;
  final Box<Transaction> _transactionBox;
  final Box<models.Category> _categoryBox;
  final Box<int> _categoryOrderBox;
  String _currentLedgerId;
  final List<String> _categoryOrder;

  var transactions;

  LedgerProvider({
    required Box<Ledger> ledgerBox,
    required Box<Transaction> transactionBox,
    required Box<models.Category> categoryBox,
    required Box<int> categoryOrderBox,
    required String currentLedgerId,
    required List<String> categoryOrder,
  })  : _ledgerBox = ledgerBox,
        _transactionBox = transactionBox,
        _categoryBox = categoryBox,
        _categoryOrderBox = categoryOrderBox,
        _currentLedgerId = currentLedgerId,
        _categoryOrder = categoryOrder;

  String get currentLedgerId => _currentLedgerId;

  List<Ledger> get ledgers => _ledgerBox.values.toList();

  List<Ledger> getLedgersForUser(String userId) {
    return _ledgerBox.values
        .where((ledger) => ledger.userId == userId)
        .toList();
  }

  Future<void> createLedger(String text,
      {required String name,
      required String userId,
      required String currency}) async {
    final ledger = Ledger(
      id: 'ledger_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      userId: 'current_user_id', // Replace with actual user ID
      createdAt: DateTime.now(),
    );
    await _ledgerBox.put(ledger.id, ledger);
    notifyListeners();
  }

  Future<void> updateLedger(String id, {required String name}) async {
    final ledger = _ledgerBox.get(id);
    if (ledger != null) {
      ledger.name = name;
      await _ledgerBox.put(id, ledger);
      notifyListeners();
    }
  }

  Future<void> updateLedgerBalance(String ledgerId, double amount) async {
    final ledger = _ledgerBox.get(ledgerId);
    if (ledger != null) {
      ledger.balance += amount;
      await _ledgerBox.put(ledgerId, ledger);
      notifyListeners();
    }
  }

  Future<void> deleteLedger(String ledgerId) async {
    if (ledgers.length <= 1) return; // Prevent deleting last ledger

    // Delete all categories and transactions for this ledger
    final categoriesToDelete = categories.where((c) => c.ledgerId == ledgerId);
    for (var category in categoriesToDelete) {
      await _categoryBox.delete(category.id);
    }

    final transactionsToDelete =
        _transactionBox.values.where((t) => t.ledgerId == ledgerId);
    for (var transaction in transactionsToDelete) {
      await _transactionBox.delete(transaction.id);
    }

    await _ledgerBox.delete(ledgerId);

    if (_currentLedgerId == ledgerId) {
      _currentLedgerId = ledgers.first.id;
    }

    notifyListeners();
  }

  // Get all categories for current ledger
  List<models.Category> get categories {
    final orderedIds = _getCategoryOrder();
    final allCategories = _categoryBox.values
        .where((category) => category.ledgerId == _currentLedgerId)
        .toList();

    // Sort categories based on saved order
    allCategories.sort((a, b) {
      final aIndex = orderedIds.indexOf(a.id);
      final bIndex = orderedIds.indexOf(b.id);
      if (aIndex == -1 || bIndex == -1) {
        return 0;
      }
      return aIndex.compareTo(bIndex);
    });

    return allCategories;
  }

  List<String> _getCategoryOrder() {
    return _categoryOrder;
  }

  Future<void> _saveCategoryOrder(List<String> order) async {
    _categoryOrder.clear();
    _categoryOrder.addAll(order);
    notifyListeners();
  }

  Future<void> reorderCategories(int oldIndex, int newIndex) async {
    final currentCategories = categories;
    final category = currentCategories.removeAt(oldIndex);
    currentCategories.insert(newIndex, category);

    await _saveCategoryOrder(
      currentCategories.map((c) => c.id).toList(),
    );
    notifyListeners();
  }

  @override
  Future<void> addCategory(String name, String emoji) async {
    final category = models.Category(
      id: const Uuid().v4(),
      name: name,
      emoji: emoji,
      ledgerId: _currentLedgerId,
      color: Colors.blue,
    );
    await _categoryBox.put(category.id, category);
    notifyListeners();
  }

  @override
  Future<void> deleteCategory(String categoryId) async {
    await _categoryBox.delete(categoryId);
    final currentOrder = _getCategoryOrder();
    currentOrder.remove(categoryId);
    await _saveCategoryOrder(currentOrder);
    notifyListeners();
  }

  // Get total balance across all categories
  double get totalBalance => categories.fold(
        0,
        (sum, category) => sum + category.balance,
      );

  // Initialize with "Untracked" category if not exists
  void _initializeCategories() {
    final hasUntracked = _categoryBox.values.any(
      (category) =>
          category.isUntracked && category.ledgerId == _currentLedgerId,
    );

    if (!hasUntracked) {
      final untrackedCategory = models.Category(
        id: 'untracked_$_currentLedgerId',
        ledgerId: _currentLedgerId,
        name: 'Untracked',
        emoji: '📦',
        isUntracked: true,
        color: Colors.grey,
      );
      _categoryBox.put(untrackedCategory.id, untrackedCategory);
      notifyListeners();
    }
  }

  // Add income to a category
  Future<void> addIncome(String categoryId, double amount,
      {String? notes}) async {
    final category = _categoryBox.get(categoryId);
    if (category == null) return;

    category.addMoney(amount);
    await _categoryBox.put(categoryId, category);

    final transaction = Transaction(
      id: 'trans_${DateTime.now().millisecondsSinceEpoch}',
      ledgerId: _currentLedgerId,
      categoryId: categoryId,
      amount: amount,
      type: TransactionType.income,
      date: DateTime.now(),
      description: '',
    );
    await _transactionBox.add(transaction);

    notifyListeners();
  }

  // Add expense to a category
  Future<bool> addExpense(String categoryId, double amount,
      {String? notes}) async {
    final category = _categoryBox.get(categoryId);
    if (category == null) return false;

    if (!category.deductMoney(amount)) return false;

    await _categoryBox.put(categoryId, category);

    final transaction = Transaction(
      id: 'trans_${DateTime.now().millisecondsSinceEpoch}',
      ledgerId: _currentLedgerId,
      categoryId: categoryId,
      amount: amount,
      type: TransactionType.expense,
      date: DateTime.now(),
      description: '',
    );
    await _transactionBox.add(transaction);

    notifyListeners();
    return true;
  }

  // Get recent transactions
  List<Transaction> getRecentTransactions({int limit = 10}) {
    return _transactionBox.values
        .where((transaction) => transaction.ledgerId == _currentLedgerId)
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp))
      ..take(limit);
  }

  // Get category by ID
  models.Category? getCategoryById(String categoryId) {
    return _categoryBox.get(categoryId);
  }

  // Transfer money between categories
  Future<bool> transferBetweenCategories(
    String fromCategoryId,
    String toCategoryId,
    double amount,
  ) async {
    final fromCategory = _categoryBox.get(fromCategoryId);
    final toCategory = _categoryBox.get(toCategoryId);

    if (fromCategory == null || toCategory == null) return false;
    if (fromCategory.balance < amount) return false;

    fromCategory.deductMoney(amount);
    toCategory.addMoney(amount);

    await _categoryBox.put(fromCategoryId, fromCategory);
    await _categoryBox.put(toCategoryId, toCategory);

    final transaction = Transaction(
      id: 'trans_${DateTime.now().millisecondsSinceEpoch}',
      ledgerId: _currentLedgerId,
      categoryId: fromCategoryId,
      amount: amount,
      type: TransactionType.expense,
      date: DateTime.now(),
      isTransfer: true,
      description: '',
    );
    await _transactionBox.add(transaction);

    notifyListeners();
    return true;
  }

  void switchLedger(String ledgerId) {
    _currentLedgerId = ledgerId;
    notifyListeners();
  }

  Future<void> deleteTransaction(String transactionId) async {
    final transaction = _transactionBox.get(transactionId);
    if (transaction == null) return;

    final category = _categoryBox.get(transaction.categoryId);
    if (category == null) return;

    if (transaction.isTransfer && transaction.targetCategoryId != null) {
      final targetCategory = _categoryBox.get(transaction.targetCategoryId);
      if (targetCategory != null) {
        // Reverse the transfer
        if (transaction.amount <= targetCategory.balance) {
          targetCategory.deductMoney(transaction.amount);
          category.addMoney(transaction.amount);
          await _categoryBox.put(targetCategory.id, targetCategory);
          await _categoryBox.put(category.id, category);
        }
      }
    } else {
      // Reverse the transaction
      if (transaction.isIncome) {
        if (transaction.amount <= category.balance) {
          category.deductMoney(transaction.amount);
        }
      } else {
        category.addMoney(transaction.amount);
      }
      await _categoryBox.put(category.id, category);
    }

    await _transactionBox.delete(transactionId);
    notifyListeners();
  }

  Future<void> updateCategory(
      String categoryId, String name, String emoji) async {
    final category = _categoryBox.get(categoryId);
    if (category == null || category.isUntracked) return;

    category.name = name;
    category.emoji = emoji;
    await _categoryBox.put(categoryId, category);
    notifyListeners();
  }

  AnalyticsData getAnalytics(String timeRange) {
    final now = DateTime.now();
    DateTime startDate;

    switch (timeRange) {
      case 'week':
        startDate = now.subtract(const Duration(days: 7));
        break;
      case 'year':
        startDate = DateTime(now.year - 1, now.month, now.day);
        break;
      case 'month':
      default:
        startDate = DateTime(now.year, now.month - 1, now.day);
        break;
    }

    final transactions = _transactionBox.values
        .where((t) =>
            t.ledgerId == _currentLedgerId && t.timestamp.isAfter(startDate))
        .toList();

    // Calculate totals
    double totalIncome = 0;
    double totalExpenses = 0;
    Map<String, double> categoryExpenses = {};

    for (var transaction in transactions) {
      if (transaction.isTransfer) continue;

      if (transaction.isIncome) {
        totalIncome += transaction.amount;
      } else {
        totalExpenses += transaction.amount;
        categoryExpenses[transaction.categoryId] =
            (categoryExpenses[transaction.categoryId] ?? 0) +
                transaction.amount;
      }
    }

    // Generate spots for charts
    final spots = _generateTimeSeriesSpots(transactions, startDate, now);

    // Calculate category distribution
    final distribution = _calculateCategoryDistribution(categoryExpenses);

    // Calculate average daily expense
    final days = now.difference(startDate).inDays;
    final averageDailyExpense = totalExpenses / days;

    // Calculate savings rate
    final double savingsRate = totalIncome > 0
        ? ((totalIncome - totalExpenses) / totalIncome * 100).toDouble()
        : 0.0;

    return AnalyticsData(
      totalIncome: totalIncome,
      totalExpenses: totalExpenses,
      savingsRate: savingsRate,
      averageDailyExpense: averageDailyExpense,
      incomeSpots: spots.incomeSpots,
      expenseSpots: spots.expenseSpots,
      categoryDistribution: distribution,
      dateLabels: spots.labels,
      color: Colors.blue,
    );
  }

  ({List<FlSpot> incomeSpots, List<FlSpot> expenseSpots, List<String> labels})
      _generateTimeSeriesSpots(
    List<Transaction> transactions,
    DateTime startDate,
    DateTime endDate,
  ) {
    final incomeSpots = <FlSpot>[];
    final expenseSpots = <FlSpot>[];
    final labels = <String>[];

    // Add implementation here

    return (
      incomeSpots: incomeSpots,
      expenseSpots: expenseSpots,
      labels: labels,
    );
  }

  List<CategoryDistributionData> _calculateCategoryDistribution(
    Map<String, double> categoryExpenses,
  ) {
    final total =
        categoryExpenses.values.fold(0.0, (sum, amount) => sum + amount);
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
    ];

    int colorIndex = 0;
    return categoryExpenses.entries
        .map((entry) {
          final category = _categoryBox.get(entry.key);
          if (category == null) return null;

          final percentage = (entry.value / total) * 100;
          final color = colors[colorIndex % colors.length];
          colorIndex++;

          return CategoryDistributionData(
            category: category,
            amount: entry.value,
            color: color,
          );
        })
        .whereType<CategoryDistributionData>()
        .toList();
  }

  getAllTransactions() {}
}
