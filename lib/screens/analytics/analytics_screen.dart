import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/ledger_provider.dart';
import '../../models/transaction.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({Key? key}) : super(key: key);

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String _timeRange = 'Month'; // 'Week', 'Month', 'Year'

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        actions: [
          DropdownButton<String>(
            value: _timeRange,
            items: const [
              DropdownMenuItem(value: 'Week', child: Text('Week')),
              DropdownMenuItem(value: 'Month', child: Text('Month')),
              DropdownMenuItem(value: 'Year', child: Text('Year')),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() => _timeRange = value);
              }
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),
            _buildSummaryCards(),
            const SizedBox(height: 24),
            _buildExpenseChart(),
            const SizedBox(height: 24),
            _buildCategoryDistribution(),
            const SizedBox(height: 24),
            _buildTransactionTrends(),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Consumer<LedgerProvider>(
      builder: (context, provider, _) {
        final analytics = provider.getAnalytics(_timeRange.toLowerCase());

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: _SummaryCard(
                  title: 'Income',
                  amount: analytics.totalIncome,
                  icon: Icons.arrow_upward,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _SummaryCard(
                  title: 'Expenses',
                  amount: analytics.totalExpenses,
                  icon: Icons.arrow_downward,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildExpenseChart() {
    return SizedBox(
      height: 300,
      child: Consumer<LedgerProvider>(
        builder: (context, provider, _) {
          final analytics = provider.getAnalytics(_timeRange.toLowerCase());

          return Padding(
            padding: const EdgeInsets.all(16),
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text(analytics.getDateLabel(value.toInt()));
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: analytics.expenseSpots,
                    isCurved: true,
                    color: Colors.red,
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                  ),
                  LineChartBarData(
                    spots: analytics.incomeSpots,
                    isCurved: true,
                    color: Colors.green,
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryDistribution() {
    return SizedBox(
      height: 300,
      child: Consumer<LedgerProvider>(
        builder: (context, provider, _) {
          final analytics = provider.getAnalytics(_timeRange.toLowerCase());

          return Padding(
            padding: const EdgeInsets.all(16),
            child: PieChart(
              PieChartData(
                sections: analytics.categoryDistribution.map((dist) {
                  return PieChartSectionData(
                    value: dist.percentage,
                    title:
                        '${dist.category.name}\n${dist.percentage.toStringAsFixed(1)}%',
                    color: dist.color,
                    radius: 100,
                  );
                }).toList(),
                sectionsSpace: 2,
                centerSpaceRadius: 40,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTransactionTrends() {
    return Consumer<LedgerProvider>(
      builder: (context, provider, _) {
        final analytics = provider.getAnalytics(_timeRange.toLowerCase());

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Insights',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              _InsightCard(
                title: 'Most Expensive Category',
                value: analytics.mostExpensiveCategory?.name ?? 'N/A',
                subtitle:
                    '₹${analytics.mostExpensiveAmount.toStringAsFixed(2)}',
              ),
              const SizedBox(height: 8),
              _InsightCard(
                title: 'Average Daily Expense',
                value: '₹${analytics.averageDailyExpense.toStringAsFixed(2)}',
                subtitle: 'Based on ${_timeRange.toLowerCase()} data',
              ),
              const SizedBox(height: 8),
              _InsightCard(
                title: 'Savings Rate',
                value: '${analytics.savingsRate.toStringAsFixed(1)}%',
                subtitle: 'Of total income',
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final double amount;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.amount,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(title),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '₹${amount.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;

  const _InsightCard({
    required this.title,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
