import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../category.dart';

class AnalyticsData {
  final double totalIncome;
  final double totalExpenses;
  final double savingsRate;
  final double averageDailyExpense;
  final List<FlSpot> incomeSpots;
  final List<FlSpot> expenseSpots;
  final List<CategoryDistributionData> categoryDistribution;
  final List<String> dateLabels;
  final MaterialColor color;

  var mostExpensiveCategory;

  var mostExpensiveAmount;

  AnalyticsData({
    required this.totalIncome,
    required this.totalExpenses,
    required this.savingsRate,
    required this.averageDailyExpense,
    required this.incomeSpots,
    required this.expenseSpots,
    required this.categoryDistribution,
    required this.dateLabels,
    required this.color,
  });

  String getDateLabel(int index) {
    if (index >= 0 && index < dateLabels.length) {
      return dateLabels[index];
    }
    return '';
  }
}

class CategoryDistributionData {
  final Category category;
  final double amount;
  final Color color;

  var percentage;

  CategoryDistributionData({
    required this.category,
    required this.amount,
    required this.color,
  });
}
