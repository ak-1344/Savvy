import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/transaction.dart';
import '../../providers/ledger_provider.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({Key? key}) : super(key: key);

  @override
  _TransactionHistoryScreenState createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  final String _currentFilter = 'all';
  DateTime? _selectedDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction History'),
      ),
      body: Consumer<LedgerProvider>(
        builder: (context, provider, _) {
          final transactions = provider.getRecentTransactions(limit: 100);

          if (transactions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No transactions yet',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            );
          }

          final filteredTransactions = _getFilteredTransactions(transactions);

          return ListView.builder(
            itemCount: filteredTransactions.length,
            itemBuilder: (context, index) {
              return TransactionListItem(
                transaction: filteredTransactions[index],
              );
            },
          );
        },
      ),
    );
  }

  List<Transaction> _getFilteredTransactions(List<Transaction> transactions) {
    return transactions.where((transaction) {
      // Apply date filter
      if (_selectedDate != null) {
        final isSameDay = transaction.timestamp.year == _selectedDate!.year &&
            transaction.timestamp.month == _selectedDate!.month &&
            transaction.timestamp.day == _selectedDate!.day;
        if (!isSameDay) return false;
      }

      // Apply type filter
      switch (_currentFilter) {
        case 'income':
          return transaction.isIncome && !transaction.isTransfer;
        case 'expenses':
          return !transaction.isIncome && !transaction.isTransfer;
        case 'transfers':
          return transaction.isTransfer;
        default:
          return true;
      }
    }).toList();
  }

  void _showDatePicker(BuildContext context) async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (selected != null) {
      setState(() => _selectedDate = selected);
    }
  }
}

class TransactionListItem extends StatelessWidget {
  final Transaction transaction;

  const TransactionListItem({
    Key? key,
    required this.transaction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<LedgerProvider>(
      builder: (context, provider, _) {
        final category = provider.getCategoryById(transaction.categoryId);
        final targetCategory = transaction.targetCategoryId != null
            ? provider.getCategoryById(transaction.targetCategoryId!)
            : null;

        return ListTile(
          leading: CircleAvatar(
            backgroundColor: _getTransactionColor(context),
            child: Text(
              category?.emoji ?? '📦',
              style: const TextStyle(fontSize: 16),
            ),
          ),
          title: Text(
            transaction.isTransfer
                ? 'Transfer: ${category?.name ?? 'Unknown'} → ${targetCategory?.name ?? 'Unknown'}'
                : category?.name ?? 'Unknown Category',
          ),
          subtitle: Text(
            _formatDate(transaction.timestamp),
          ),
          trailing: Text(
            '${transaction.isIncome ? '+' : '-'}₹${transaction.amount.toStringAsFixed(2)}',
            style: TextStyle(
              color: transaction.isIncome ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
          onTap: () => _showTransactionDetails(context),
        );
      },
    );
  }

  Color _getTransactionColor(BuildContext context) {
    if (transaction.isTransfer) return Colors.blue;
    return transaction.isIncome ? Colors.green : Colors.red;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _showTransactionDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => TransactionDetailsSheet(transaction: transaction),
    );
  }
}

class TransactionDetailsSheet extends StatelessWidget {
  final Transaction transaction;

  const TransactionDetailsSheet({
    Key? key,
    required this.transaction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<LedgerProvider>(
      builder: (context, provider, _) {
        final category = provider.getCategoryById(transaction.categoryId);
        final targetCategory = transaction.targetCategoryId != null
            ? provider.getCategoryById(transaction.targetCategoryId!)
            : null;

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Transaction Details',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              _buildDetailRow('Type', _getTransactionType()),
              _buildDetailRow(
                  'Amount', '₹${transaction.amount.toStringAsFixed(2)}'),
              _buildDetailRow(
                  'Category', '${category?.emoji} ${category?.name}'),
              if (transaction.isTransfer)
                _buildDetailRow('To Category',
                    '${targetCategory?.emoji} ${targetCategory?.name}'),
              _buildDetailRow('Date', _formatDate(transaction.timestamp)),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _confirmDelete(context, provider),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: const Text('Delete Transaction'),
                ),
              ),
            ],
          ),
        );
      },
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _confirmDelete(BuildContext context, LedgerProvider provider) {
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
              provider.deleteTransaction(transaction.id);
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close details sheet
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
