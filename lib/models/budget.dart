import 'package:hive/hive.dart';
import 'category.dart';

part 'budget.g.dart';

@HiveType(typeId: 4)
class Budget extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String categoryId;

  @HiveField(2)
  double amount;

  @HiveField(3)
  final String ledgerId;

  @HiveField(4)
  double spent;

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
  DateTime updatedAt;

  Category? category;

  var currentAmount;

  var targetAmount;

  Budget({
    required this.id,
    required this.categoryId,
    required this.amount,
    required this.ledgerId,
    this.spent = 0,
    required this.createdAt,
    required this.updatedAt,
    required String name,
    required DateTime startDate,
    required DateTime endDate,
  });

  bool get isOverBudget => spent > amount;
  double get progress => (spent / amount).clamp(0, 1);
  double get remaining => amount - spent;

  String? get name => null;

  get startDate => null;

  get endDate => null;
}
