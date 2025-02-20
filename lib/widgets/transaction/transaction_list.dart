import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/ledger_provider.dart';
import '../../utils/constants.dart';
import '../../utils/date_formatter.dart';

class TransactionList extends StatelessWidget {
  const TransactionList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<LedgerProvider>(
      builder: (context, provider, _) {
        final transactions = provider.transactions;

        if (transactions.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.receipt_long,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                const Text(
                  'No transactions yet',
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: transactions.length,
          itemBuilder: (context, index) {
            final transaction = transactions[index];
            final category = provider.getCategoryById(transaction.categoryId);

            return Card(
              margin: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 4,
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: category?.color ?? Colors.grey,
                  child: Text(
                    category?.emoji ?? '📦',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                title: Text(category?.name ?? 'Untracked'),
                subtitle: Text(
                  DateFormatter.formatRelative(transaction.date),
                ),
                trailing: Text(
                  '${transaction.isIncome ? '+' : '-'}${Constants.currencySymbol}${transaction.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: transaction.isIncome ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () => Navigator.pushNamed(
                  context,
                  '/transaction_details',
                  arguments: transaction,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
