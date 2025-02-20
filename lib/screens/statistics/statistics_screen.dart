import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/ledger_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../utils/date_utils.dart';
import '../../widgets/charts/expense_line_chart.dart';
import '../../widgets/charts/category_pie_chart.dart';
import '../../models/ledger.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({Key? key}) : super(key: key);

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser!;
    final ledgers = context.watch<LedgerProvider>().getLedgersForUser(user.id);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildLedgerSelector(ledgers),
          ),
          Expanded(
            child: _buildStatistics(ledgers),
          ),
        ],
      ),
    );
  }

  Widget _buildLedgerSelector(List<Ledger> ledgers) {
    return DropdownButtonFormField<String>(
      value: ledgers.isNotEmpty ? ledgers.first.id : null,
      decoration: const InputDecoration(
        labelText: 'Select Ledger',
        border: OutlineInputBorder(),
      ),
      items: ledgers.map((ledger) {
        return DropdownMenuItem(
          value: ledger.id,
          child: Text(ledger.name),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedDate = DateTime.now();
          });
        }
      },
    );
  }

  Widget _buildStatistics(List<Ledger> ledgers) {
    if (ledgers.isEmpty) {
      return const Center(child: Text('No ledgers available'));
    }

    return Column(
      children: [
        _buildExpenseChart(ledgers.first),
        _buildCategoryBreakdown(ledgers.first),
      ],
    );
  }

  Widget _buildExpenseChart(Ledger ledger) {
    final startDate = AppDateUtils.getStartOfMonth(_selectedDate);
    final endDate = AppDateUtils.getEndOfMonth(_selectedDate);

    final dailyExpenses = context
        .watch<TransactionProvider>()
        .getDailyExpenses(ledger.id, startDate, endDate);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Daily Expenses',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: ExpenseLineChart(
                dailyExpenses: dailyExpenses,
                currency: ledger.currency,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryBreakdown(Ledger ledger) {
    final startDate = AppDateUtils.getStartOfMonth(_selectedDate);
    final endDate = AppDateUtils.getEndOfMonth(_selectedDate);

    final categoryTotals = context
        .watch<TransactionProvider>()
        .getCategoryTotals(ledger.id, startDate, endDate);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Category Breakdown',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: CategoryPieChart(
                categoryTotals: categoryTotals,
                currency: ledger.currency,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
