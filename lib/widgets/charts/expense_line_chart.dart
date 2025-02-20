import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../utils/currency_formatter.dart';

class ExpenseLineChart extends StatelessWidget {
  final Map<DateTime, double> dailyExpenses;
  final String currency;

  const ExpenseLineChart({
    Key? key,
    required this.dailyExpenses,
    required this.currency,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (dailyExpenses.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    final spots = dailyExpenses.entries.map((entry) {
      return FlSpot(
        entry.key.millisecondsSinceEpoch.toDouble(),
        entry.value,
      );
    }).toList();

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  CurrencyFormatter.format(value, currency),
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                return Text(
                  '${date.day}/${date.month}',
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Theme.of(context).colorScheme.primary,
            barWidth: 2,
            dotData: const FlDotData(show: false),
          ),
        ],
      ),
    );
  }
}
