import 'package:hive/hive.dart';

part 'recurring_transaction.g.dart';

@HiveType(typeId: 5)
class RecurringTransaction extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String categoryId;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final String ledgerId;

  @HiveField(4)
  final bool isIncome;

  @HiveField(5)
  final String frequency; // daily, weekly, monthly, yearly

  @HiveField(6)
  final DateTime startDate;

  @HiveField(7)
  DateTime? endDate;

  @HiveField(8)
  final String? notes;

  @HiveField(9)
  DateTime lastProcessed;

  RecurringTransaction({
    required this.id,
    required this.categoryId,
    required this.amount,
    required this.ledgerId,
    required this.isIncome,
    required this.frequency,
    required this.startDate,
    this.endDate,
    this.notes,
    required this.lastProcessed,
  });

  bool get isActive => endDate == null || endDate!.isAfter(DateTime.now());

  DateTime getNextOccurrence() {
    final now = DateTime.now();
    if (!isActive || lastProcessed.isAfter(now)) return lastProcessed;

    switch (frequency) {
      case 'daily':
        return lastProcessed.add(const Duration(days: 1));
      case 'weekly':
        return lastProcessed.add(const Duration(days: 7));
      case 'monthly':
        return DateTime(
          lastProcessed.year,
          lastProcessed.month + 1,
          lastProcessed.day,
        );
      case 'yearly':
        return DateTime(
          lastProcessed.year + 1,
          lastProcessed.month,
          lastProcessed.day,
        );
      default:
        return lastProcessed;
    }
  }
} 