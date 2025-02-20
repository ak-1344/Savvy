import 'package:hive/hive.dart';

part 'ledger.g.dart';

@HiveType(typeId: 3)
class Ledger {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  final String userId;

  @HiveField(3)
  double balance = 0;

  @HiveField(4)
  String currency = '₹';

  @HiveField(5)
  final DateTime createdAt;

  Ledger({
    required this.id,
    required this.name,
    required this.userId,
    this.balance = 0,
    this.currency = '₹',
    required this.createdAt,
  });
} 