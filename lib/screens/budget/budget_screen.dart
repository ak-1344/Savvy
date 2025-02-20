import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/budget.dart';
import '../../models/category.dart';
import '../../providers/auth_provider.dart';
import '../../providers/budget_provider.dart';
import '../../providers/ledger_provider.dart';
import '../../utils/currency_formatter.dart';
import '../../utils/error_handler.dart';
import 'budget_dialog.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({Key? key}) : super(key: key);

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  // ignore: unused_field
  String? _selectedLedgerId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ledgers = context
          .read<LedgerProvider>()
          .getLedgersForUser(context.read<AuthProvider>().currentUser!.id);
      if (ledgers.isNotEmpty) {
        setState(() {
          _selectedLedgerId = ledgers.first.id;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final budgets = context.watch<BudgetProvider>().budgets;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: budgets.length,
        itemBuilder: (context, index) => _buildBudgetCard(budgets[index]),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddBudgetDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBudgetCard(Budget budget) {
    final category =
        Category.defaultCategories.firstWhere((c) => c.id == budget.categoryId);
    // ignore: unused_local_variable
    final progress = budget.spent / budget.amount;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  category.name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _showEditBudgetDialog(context, budget),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildProgressBar(budget),
            const SizedBox(height: 8),
            _buildAmountInfo(budget),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(Budget budget) {
    final progress = budget.spent / budget.amount;
    return Column(
      children: [
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(
            progress > 1.0 ? Colors.red : Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(height: 4),
        Text('${(progress * 100).toStringAsFixed(1)}%'),
      ],
    );
  }

  Widget _buildAmountInfo(Budget budget) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Spent: ${CurrencyFormatter.format(budget.spent, "INR")} '
          'of ${CurrencyFormatter.format(budget.amount, "INR")}',
          style: TextStyle(
            color: budget.spent > budget.amount ? Colors.red : Colors.green,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Future<void> _showAddBudgetDialog(BuildContext context) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const BudgetDialog(),
    );

    if (result != null && mounted) {
      try {
        await context.read<BudgetProvider>().addBudget(
              result['categoryId'],
              result['amount'],
            );
      } catch (e) {
        if (mounted) {
          ErrorHandler.showError(context, e);
        }
      }
    }
  }

  Future<void> _showEditBudgetDialog(
      BuildContext context, Budget budget) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => BudgetDialog(budget: budget),
    );

    if (result != null && mounted) {
      try {
        // ignore: use_build_context_synchronously
        await context.read<BudgetProvider>().updateBudget(
              budget.id,
              result['amount'],
              amount: 0,
            );
      } catch (e) {
        if (mounted) {
          ErrorHandler.showError(context, e);
        }
      }
    }
  }
}
