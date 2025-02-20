import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ledger_provider.dart';

class TransferDialog extends StatefulWidget {
  const TransferDialog({Key? key}) : super(key: key);

  @override
  State<TransferDialog> createState() => _TransferDialogState();
}

class _TransferDialogState extends State<TransferDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  String? _fromCategoryId;
  String? _toCategoryId;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Transfer Money'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Consumer<LedgerProvider>(
              builder: (context, provider, _) {
                final categories = provider.categories;
                return DropdownButtonFormField<String>(
                  value: _fromCategoryId,
                  decoration: const InputDecoration(
                    labelText: 'From Category',
                  ),
                  items: categories.map((category) {
                    return DropdownMenuItem(
                      value: category.id,
                      child: Text('${category.emoji} ${category.name}'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _fromCategoryId = value);
                  },
                  validator: (value) {
                    if (value == null) return 'Please select a category';
                    return null;
                  },
                );
              },
            ),
            const SizedBox(height: 16),
            Consumer<LedgerProvider>(
              builder: (context, provider, _) {
                final categories = provider.categories;
                return DropdownButtonFormField<String>(
                  value: _toCategoryId,
                  decoration: const InputDecoration(
                    labelText: 'To Category',
                  ),
                  items: categories.map((category) {
                    return DropdownMenuItem(
                      value: category.id,
                      child: Text('${category.emoji} ${category.name}'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _toCategoryId = value);
                  },
                  validator: (value) {
                    if (value == null) return 'Please select a category';
                    if (value == _fromCategoryId) {
                      return 'Please select a different category';
                    }
                    return null;
                  },
                );
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixText: '₹',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Please enter an amount';
                if (double.tryParse(value!) == null) {
                  return 'Please enter a valid amount';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CANCEL'),
        ),
        TextButton(
          onPressed: _handleTransfer,
          child: const Text('TRANSFER'),
        ),
      ],
    );
  }

  Future<void> _handleTransfer() async {
    if (_formKey.currentState?.validate() ?? false) {
      final amount = double.parse(_amountController.text);
      final success = context.read<LedgerProvider>().transferBetweenCategories(
            _fromCategoryId!,
            _toCategoryId!,
            amount,
          );

      if (await success) {
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Insufficient balance in source category'),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }
}
