import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/ledger_provider.dart';

class AddTransactionScreen extends StatefulWidget {
  final bool isIncome;

  const AddTransactionScreen({
    Key? key,
    this.isIncome = false,
  }) : super(key: key);

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  String? _selectedCategoryId;
  String? _targetCategoryId;
  bool _isTransfer = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isTransfer
              ? 'Transfer Money'
              : widget.isIncome
                  ? 'Add Income'
                  : 'Add Expense',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!widget.isIncome)
                SwitchListTile(
                  title: const Text('Transfer between categories'),
                  value: _isTransfer,
                  onChanged: (value) {
                    setState(() {
                      _isTransfer = value;
                      _targetCategoryId = null;
                    });
                  },
                ),
              const SizedBox(height: 16),
              _buildAmountField(),
              const SizedBox(height: 16),
              _buildCategoryDropdown(
                label: _isTransfer ? 'From Category' : 'Category',
                value: _selectedCategoryId,
                onChanged: (value) {
                  setState(() => _selectedCategoryId = value);
                },
              ),
              if (_isTransfer) ...[
                const SizedBox(height: 16),
                _buildCategoryDropdown(
                  label: 'To Category',
                  value: _targetCategoryId,
                  onChanged: (value) {
                    setState(() => _targetCategoryId = value);
                  },
                  excludeId: _selectedCategoryId,
                ),
              ],
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (Optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: _handleSubmit,
            child: const Text('SAVE'),
          ),
        ),
      ),
    );
  }

  Widget _buildAmountField() {
    return TextFormField(
      controller: _amountController,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        labelText: 'Amount',
        prefixText: '₹',
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value?.isEmpty ?? true) {
          return 'Please enter an amount';
        }
        final amount = double.tryParse(value!);
        if (amount == null || amount <= 0) {
          return 'Please enter a valid amount';
        }
        return null;
      },
    );
  }

  Widget _buildCategoryDropdown({
    required String label,
    required String? value,
    required Function(String?) onChanged,
    String? excludeId,
  }) {
    return Consumer<LedgerProvider>(
      builder: (context, provider, _) {
        final categories = provider.categories
            .where((c) => !c.isUntracked && c.id != excludeId)
            .toList();

        return DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
          ),
          items: categories.map((category) {
            return DropdownMenuItem(
              value: category.id,
              child: Text('${category.emoji} ${category.name}'),
            );
          }).toList(),
          onChanged: onChanged,
          validator: (value) {
            if (value == null) {
              return 'Please select a category';
            }
            return null;
          },
        );
      },
    );
  }

  void _handleSubmit() async {
    if (_formKey.currentState?.validate() ?? false) {
      final amount = double.parse(_amountController.text);
      final provider = context.read<LedgerProvider>();

      bool success = true;
      if (_isTransfer) {
        success = await provider.transferBetweenCategories(
          _selectedCategoryId!,
          _targetCategoryId!,
          amount,
        );
      } else if (widget.isIncome) {
        provider.addIncome(
          _selectedCategoryId!,
          amount,
        );
      } else {
        provider.addExpense(
          _selectedCategoryId!,
          amount,
        );
      }

      if (mounted) {
        if (success) {
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Insufficient balance for this transaction'),
            ),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
