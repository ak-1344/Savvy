// TODO: Implement recurring transactions functionality
// This feature will be implemented in a future update

// import 'package:flutter/foundation.dart';
// import 'package:hive/hive.dart';
// import '../models/recurring_transaction.dart';
// import 'ledger_provider.dart';
// 
// class RecurringProvider with ChangeNotifier {
//   final Box<RecurringTransaction> _recurringBox;
//   final LedgerProvider _ledgerProvider;
//   final String _currentLedgerId;
// 
//   RecurringProvider(
//     this._recurringBox,
//     this._ledgerProvider,
//     this._currentLedgerId,
//   ) {
//     _processRecurringTransactions();
//   }
// 
//   List<RecurringTransaction> get activeRecurringTransactions =>
//       _recurringBox.values
//           .where((r) => r.ledgerId == _currentLedgerId && r.isActive)
//           .toList();
// 
//   List<RecurringTransaction> get inactiveRecurringTransactions =>
//       _recurringBox.values
//           .where((r) => r.ledgerId == _currentLedgerId && !r.isActive)
//           .toList();
// 
//   Future<void> _processRecurringTransactions() async {
//     final now = DateTime.now();
//     
//     for (var recurring in activeRecurringTransactions) {
//       while (recurring.getNextOccurrence().isBefore(now)) {
//         final success = recurring.isIncome
//             ? await _ledgerProvider.addIncome(
//                 recurring.categoryId,
//                 recurring.amount,
//                 notes: recurring.notes,
//               )
//             : await _ledgerProvider.addExpense(
//                 recurring.categoryId,
//                 recurring.amount,
//                 notes: recurring.notes,
//               );
// 
//         if (success) {
//           recurring.lastProcessed = recurring.getNextOccurrence();
//           await _recurringBox.put(recurring.id, recurring);
//         } else {
//           break;
//         }
//       }
//     }
//   }
// 
//   Future<void> addRecurring(
//     String categoryId,
//     double amount,
//     bool isIncome,
//     String frequency,
//     DateTime startDate, {
//     DateTime? endDate,
//     String? notes,
//   }) async {
//     final recurring = RecurringTransaction(
//       id: 'recurring_${DateTime.now().millisecondsSinceEpoch}',
//       categoryId: categoryId,
//       amount: amount,
//       ledgerId: _currentLedgerId,
//       isIncome: isIncome,
//       frequency: frequency,
//       startDate: startDate,
//       endDate: endDate,
//       notes: notes,
//       lastProcessed: startDate,
//     );
// 
//     await _recurringBox.put(recurring.id, recurring);
//     notifyListeners();
//     await _processRecurringTransactions();
//   }
// 
//   Future<void> updateRecurring(
//     String id,
//     double amount,
//     String frequency,
//     DateTime startDate, {
//     DateTime? endDate,
//     String? notes,
//   }) async {
//     final recurring = _recurringBox.get(id);
//     if (recurring == null) return;
// 
//     recurring.amount = amount;
//     recurring.frequency = frequency;
//     recurring.startDate = startDate;
//     recurring.endDate = endDate;
//     recurring.notes = notes;
// 
//     await _recurringBox.put(id, recurring);
//     notifyListeners();
//   }
// 
//   Future<void> stopRecurring(String id) async {
//     final recurring = _recurringBox.get(id);
//     if (recurring == null) return;
// 
//     recurring.endDate = DateTime.now();
//     await _recurringBox.put(id, recurring);
//     notifyListeners();
//   }
// 
//   Future<void> deleteRecurring(String id) async {
//     await _recurringBox.delete(id);
//     notifyListeners();
//   }
// } 