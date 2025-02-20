import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../models/category.dart';
import '../../utils/currency_formatter.dart';

class CategoryPieChart extends StatelessWidget {
  final Map<String, double> categoryTotals;
  final String currency;

  const CategoryPieChart({
    Key? key,
    required this.categoryTotals,
    required this.currency,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (categoryTotals.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    final sections = categoryTotals.entries.map((entry) {
      final category = Category.defaultCategories
          .firstWhere((c) => c.id == entry.key);

      return PieChartSectionData(
        value: entry.value,
        title: '${category.name}\n${CurrencyFormatter.format(entry.value, currency)}',
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        color: category.color,
        radius: 100,
      );
    }).toList();

    return PieChart(
      PieChartData(
        sections: sections,
        centerSpaceRadius: 0,
        sectionsSpace: 2,
        pieTouchData: PieTouchData(
          touchCallback: (FlTouchEvent event, pieTouchResponse) {
            // Handle touch events if needed
          },
        ),
      ),
    );
  }
} 