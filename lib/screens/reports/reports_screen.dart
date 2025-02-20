import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/ledger_provider.dart';
import '../../widgets/reports/expense_chart.dart';
import '../../widgets/reports/income_chart.dart';
import '../../widgets/reports/category_distribution.dart' as widget_types;
// ignore: unused_import
import '../../utils/date_formatter.dart';
import '../../models/analytics/analytics_data.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({Key? key}) : super(key: key);

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _timeRange = 'month';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Reports'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Categories'),
            Tab(text: 'Trends'),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            initialValue: _timeRange,
            onSelected: (value) {
              setState(() => _timeRange = value);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'week',
                child: Text('This Week'),
              ),
              const PopupMenuItem(
                value: 'month',
                child: Text('This Month'),
              ),
              const PopupMenuItem(
                value: 'year',
                child: Text('This Year'),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<LedgerProvider>(
        builder: (context, provider, _) {
          final analytics = provider.getAnalytics(_timeRange);

          return TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(analytics),
              _buildCategoriesTab(analytics),
              _buildTrendsTab(analytics),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOverviewTab(AnalyticsData analytics) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSummaryCard(analytics),
        const SizedBox(height: 16),
        _buildIncomeVsExpenseChart(analytics),
        const SizedBox(height: 16),
        _buildSavingsCard(analytics),
      ],
    );
  }

  Widget _buildSummaryCard(AnalyticsData analytics) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Summary for ${_getTimeRangeText()}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildSummaryRow(
              'Total Income',
              analytics.totalIncome,
              Colors.green,
            ),
            const SizedBox(height: 8),
            _buildSummaryRow(
              'Total Expenses',
              analytics.totalExpenses,
              Colors.red,
            ),
            const Divider(height: 24),
            _buildSummaryRow(
              'Net Balance',
              analytics.totalIncome - analytics.totalExpenses,
              (analytics.totalIncome - analytics.totalExpenses) >= 0
                  ? Colors.green
                  : Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(
          '₹${amount.toStringAsFixed(2)}',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildIncomeVsExpenseChart(AnalyticsData analytics) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Income vs Expenses',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: IncomeExpenseChart(analytics: analytics),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavingsCard(AnalyticsData analytics) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Savings Rate',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: analytics.savingsRate / 100,
              backgroundColor: Colors.grey[200],
              color: Colors.green,
            ),
            const SizedBox(height: 8),
            Text(
              '${analytics.savingsRate.toStringAsFixed(1)}% of income saved',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesTab(AnalyticsData analytics) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Expense Distribution',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 300,
                  child: widget_types.CategoryDistributionChart(
                    distribution: analytics.categoryDistribution
                        .map((data) => widget_types.CategoryDistributionData(
                              category: data.category,
                              amount: data.amount,
                              color: data.color,
                            ))
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildTopCategoriesCard(analytics),
      ],
    );
  }

  Widget _buildTopCategoriesCard(AnalyticsData analytics) {
    final sortedCategories = List.from(analytics.categoryDistribution)
      ..sort((a, b) => b.amount.compareTo(a.amount));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Top Categories',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ...sortedCategories.take(5).map((category) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: category.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(category.category.name),
                      ),
                      Text(
                        '₹${category.amount.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendsTab(AnalyticsData analytics) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildTrendCard(
          'Daily Average',
          analytics.averageDailyExpense,
          'Based on your expenses this $_timeRange',
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Spending Trend',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: ExpenseChart(analytics: analytics),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTrendCard(String title, double value, String subtitle) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Text(
              '₹${value.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  String _getTimeRangeText() {
    switch (_timeRange) {
      case 'week':
        return 'This Week';
      case 'year':
        return 'This Year';
      default:
        return 'This Month';
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
