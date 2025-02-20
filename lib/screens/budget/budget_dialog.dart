import 'package:flutter/material.dart';
import '../../models/budget.dart';
import '../../models/category.dart';

class BudgetDialog extends StatefulWidget {
  final Budget? budget;

  const BudgetDialog({Key? key, this.budget}) : super(key: key);

  @override
  State<BudgetDialog> createState() => _BudgetDialogState();
}

class _BudgetDialogState extends State<BudgetDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _selectedCategoryId;
  final _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.budget?.categoryId ?? 
        Category.defaultCategories.first.id;
    _amountController.text = widget.budget?.amount.toString() ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.budget == null ? 'Add Budget' : 'Edit Budget'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.budget == null)
              DropdownButtonFormField<String>(
                value: _selectedCategoryId,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: Category.defaultCategories.map((category) {
                  return DropdownMenuItem(
                    value: category.id,
                    child: Text(category.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategoryId = value!;
                  });
                },
              ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Amount',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an amount';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
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
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _handleSubmit,
          child: Text(widget.budget == null ? 'Add' : 'Save'),
        ),
      ],
    );
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      Navigator.pop(context, {
        'categoryId': _selectedCategoryId,
        'amount': double.parse(_amountController.text),
      });
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }
} 