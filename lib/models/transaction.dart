import 'package:hive/hive.dart';

part 'transaction.g.dart';

@HiveType(typeId: 2)
enum TransactionType {
  @HiveField(0)
  income,
  @HiveField(1)
  expense,
}

@HiveType(typeId: 3)
class Transaction extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String categoryId;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final DateTime date;

  @HiveField(4)
  final TransactionType type;

  @HiveField(5)
  final String ledgerId;

  @HiveField(6)
  final String? notes;

  @HiveField(7)
  final bool _isTransfer;

  bool get isIncome => type == TransactionType.income;
  DateTime get timestamp => date;
  bool get isTransfer => _isTransfer;
  String? get targetCategoryId => null;

  Transaction({
    required this.id,
    required this.categoryId,
    required this.amount,
    required this.date,
    required this.type,
    required this.ledgerId,
    this.notes,
    bool isTransfer = false,
    required String description,
  }) : _isTransfer = isTransfer;

  String? get description => null;
}
