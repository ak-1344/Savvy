import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AnalyticsScreen extends StatelessWidget {
  final double totalIncome = 4000;
  final double totalExpenses = 1400;
  final double netSavings = 2600;

  final List<PieChartSectionData> expenseSections = [
    PieChartSectionData(
      color: Colors.red,
      value: 30,
      title: 'Food',
      radius: 50,
    ),
    PieChartSectionData(
      color: Colors.blue,
      value: 20,
      title: 'Transport',
      radius: 50,
    ),
    PieChartSectionData(
      color: Colors.green,
      value: 15,
      title: 'Shopping',
      radius: 50,
    ),
    PieChartSectionData(
      color: Colors.yellow,
      value: 35,
      title: 'Bills',
      radius: 50,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Analytics')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildExpenseBreakdown(context),
            SizedBox(height: 24),
            _buildIncomeVsExpense(context),
            SizedBox(height: 24),
            _buildFinancialSummary(context),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseBreakdown(BuildContext context) {
    return Card(
      color: Theme.of(context).cardColor,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Expense Breakdown', style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(PieChartData(sections: expenseSections)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncomeVsExpense(BuildContext context) {
    return Card(
      color: Theme.of(context).cardColor,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Income vs Expense', style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 5000,
                  titlesData: FlTitlesData(show: true),
                  borderData: FlBorderData(show: false),
                  barGroups: [
                    BarChartGroupData(
                      x: 0,
                      barRods: [
                        BarChartRodData(
                          fromY: 0,
                          toY: totalIncome,
                          width: 20,
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 1,
                      barRods: [
                        BarChartRodData(
                          fromY: 0,
                          toY: totalExpenses,
                          width: 20,
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialSummary(BuildContext context) {
    return Card(
      color: Theme.of(context).cardColor,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Financial Summary', style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 16),
            _buildSummaryItem('Total Income', '\$${totalIncome.toStringAsFixed(2)}'),
            _buildSummaryItem('Total Expenses', '\$${totalExpenses.toStringAsFixed(2)}'),
            _buildSummaryItem('Net Savings', '\$${netSavings.toStringAsFixed(2)}'),
            _buildSummaryItem('Savings Rate', '${(netSavings / totalIncome * 100).toStringAsFixed(1)}%'),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
