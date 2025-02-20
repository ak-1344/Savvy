import 'package:flutter/material.dart';
import 'package:managment/models/category.dart';
import 'package:provider/provider.dart';
import '../../models/transaction.dart';
import '../../providers/ledger_provider.dart';
import '../../utils/date_formatter.dart';

class TransactionDetailsScreen extends StatelessWidget {
  final Transaction transaction;

  const TransactionDetailsScreen({
    Key? key,
    required this.transaction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: Consumer<LedgerProvider>(
        builder: (context, provider, _) {
          final category = provider.getCategoryById(transaction.categoryId);
          final targetCategory = transaction.targetCategoryId != null
              ? provider.getCategoryById(transaction.targetCategoryId!)
              : null;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildAmountCard(context),
              const SizedBox(height: 16),
              _buildDetailsCard(context, category, targetCategory),
              const SizedBox(height: 16),
              if (transaction.notes?.isNotEmpty ?? false)
                _buildNotesCard(context),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAmountCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              '₹${transaction.amount.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: transaction.isIncome ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              _getTransactionType(),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsCard(
    BuildContext context,
    Category? category,
    Category? targetCategory,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Details',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              'Date',
              DateFormatter.format(transaction.timestamp),
            ),
            _buildDetailRow(
              'Category',
              category != null
                  ? '${category.emoji} ${category.name}'
                  : 'Unknown Category',
            ),
            if (transaction.isTransfer && targetCategory != null)
              _buildDetailRow(
                'To Category',
                '${targetCategory.emoji} ${targetCategory.name}',
              ),
            _buildDetailRow(
              'Time',
              DateFormatter.formatTime(transaction.timestamp),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notes',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Text(transaction.notes!),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(value),
        ],
      ),
    );
  }

  String _getTransactionType() {
    if (transaction.isTransfer) return 'Transfer';
    return transaction.isIncome ? 'Income' : 'Expense';
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transaction?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              context.read<LedgerProvider>().deleteTransaction(transaction.id);
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Return to previous screen
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );
  }
}
