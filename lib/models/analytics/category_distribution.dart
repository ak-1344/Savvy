import 'package:flutter/material.dart';
import '../category.dart';

class CategoryDistribution {
  final Category category;
  final double amount;
  final double percentage;
  final MaterialColor color;

  CategoryDistribution({
    required this.category,
    required this.amount,
    required this.percentage,
    required this.color,
  });
} 