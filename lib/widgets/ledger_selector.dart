import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/ledger.dart';
import '../providers/ledger_provider.dart';

class LedgerSelector extends StatelessWidget {
  const LedgerSelector({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.account_balance_wallet),
      onPressed: () => _showLedgerSelector(context),
    );
  }

  void _showLedgerSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const LedgerSelectorSheet(),
    );
  }
}

class LedgerSelectorSheet extends StatelessWidget {
  const LedgerSelectorSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Select Ledger',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => _showCreateLedgerDialog(context),
              ),
            ],
          ),
        ),
        const Divider(),
        Consumer<LedgerProvider>(
          builder: (context, provider, _) {
            return ListView.builder(
              shrinkWrap: true,
              itemCount: provider.ledgers.length,
              itemBuilder: (context, index) {
                final ledger = provider.ledgers[index];
                return ListTile(
                  leading: const Icon(Icons.book),
                  title: Text(ledger.name),
                  subtitle: Text(
                    'Created ${_formatDate(ledger.createdAt)}',
                  ),
                  selected: provider.currentLedgerId == ledger.id,
                  onTap: () {
                    provider.switchLedger(ledger.id);
                    Navigator.pop(context);
                  },
                  trailing: provider.ledgers.length > 1
                      ? IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () =>
                              _confirmDeleteLedger(context, ledger),
                        )
                      : null,
                );
              },
            );
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showCreateLedgerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const CreateLedgerDialog(),
    );
  }

  void _confirmDeleteLedger(BuildContext context, Ledger ledger) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Ledger?'),
        content: Text(
          'Are you sure you want to delete "${ledger.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              context.read<LedgerProvider>().deleteLedger(ledger.id);
              Navigator.pop(context);
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

class CreateLedgerDialog extends StatefulWidget {
  const CreateLedgerDialog({Key? key}) : super(key: key);

  @override
  State<CreateLedgerDialog> createState() => _CreateLedgerDialogState();
}

class _CreateLedgerDialogState extends State<CreateLedgerDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create New Ledger'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Ledger Name',
            hintText: 'e.g., Personal, Business',
          ),
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'Please enter a name';
            }
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CANCEL'),
        ),
        TextButton(
          onPressed: _handleCreate,
          child: const Text('CREATE'),
        ),
      ],
    );
  }

  void _handleCreate() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<LedgerProvider>().createLedger(_nameController.text,
          userId: '', name: '', currency: '');
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
