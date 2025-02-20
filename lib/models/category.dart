import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'category.g.dart';

@HiveType(typeId: 1)
class Category extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  double balance;

  @HiveField(3)
  final bool isUntracked;

  @HiveField(4)
  String emoji;

  @HiveField(5)
  final String ledgerId;

  @HiveField(6)
  final Color color;

  IconData? icon;

  Category({
    required this.id,
    required this.name,
    required this.ledgerId,
    this.balance = 0.0,
    this.isUntracked = false,
    required this.emoji,
    required this.color,
    this.icon,
  });

  void addMoney(double amount) {
    balance += amount;
  }

  bool deductMoney(double amount) {
    if (balance >= amount) {
      balance -= amount;
      return true;
    }
    return false;
  }

  static List<Category> get defaultCategories => [
        Category(
          id: 'food',
          name: 'Food & Dining',
          emoji: '🍴',
          isUntracked: false,
          ledgerId: 'default',
          color: Colors.orange,
          icon: Icons.food_bank,
        ),
        Category(
          id: 'transport',
          name: 'Transportation',
          emoji: '🚗',
          isUntracked: false,
          ledgerId: 'default',
          color: Colors.blue,
          icon: null,
        ),
        Category(
          id: 'shopping',
          name: 'Shopping',
          emoji: '🛒',
          isUntracked: false,
          ledgerId: 'default',
          color: Colors.purple,
          icon: Icons.shopping_cart,
        ),
        // Add more categories as needed
      ];
}
