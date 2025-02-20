import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:managment/models/category.dart';

class CategoryDistributionData {
  final double amount;
  final Color color;

  CategoryDistributionData({
    required this.amount,
    required this.color,
    required Category category,
  });
}

class CategoryDistributionChart extends StatefulWidget {
  final List<CategoryDistributionData> distribution;

  const CategoryDistributionChart({
    Key? key,
    required this.distribution,
  }) : super(key: key);

  @override
  State<CategoryDistributionChart> createState() =>
      _CategoryDistributionChartState();
}

class _CategoryDistributionChartState extends State<CategoryDistributionChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return PieChart(
      PieChartData(
        pieTouchData: PieTouchData(
          touchCallback: (FlTouchEvent event, pieTouchResponse) {
            setState(() {
              if (!event.isInterestedForInteractions ||
                  pieTouchResponse == null ||
                  pieTouchResponse.touchedSection == null) {
                touchedIndex = -1;
                return;
              }
              touchedIndex =
                  pieTouchResponse.touchedSection!.touchedSectionIndex;
            });
          },
        ),
        borderData: FlBorderData(show: false),
        sectionsSpace: 2,
        centerSpaceRadius: 40,
        sections: showingSections(),
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    final total = widget.distribution.fold(
      0.0,
      (sum, item) => sum + item.amount,
    );

    return List.generate(widget.distribution.length, (i) {
      final data = widget.distribution[i];
      final isTouched = i == touchedIndex;
      final percentage = (data.amount / total * 100).roundToDouble();
      final radius = isTouched ? 110.0 : 100.0;

      return PieChartSectionData(
        color: data.color,
        value: data.amount,
        title: '${percentage.toStringAsFixed(1)}%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: isTouched ? 18 : 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    });
  }
}
