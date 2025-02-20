import 'package:flutter/material.dart';
import 'package:managment/widgets/emoji_picker.dart';
import 'package:provider/provider.dart';
import '../../models/category.dart';
import '../../providers/ledger_provider.dart';
import '../../widgets/category/add_category_dialog.dart';
import '../../widgets/category/category_list_item.dart';

class CategoryManagementScreen extends StatelessWidget {
  const CategoryManagementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Categories'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddCategoryDialog(context),
          ),
        ],
      ),
      body: Consumer<LedgerProvider>(
        builder: (context, provider, _) {
          final categories = provider.categories;

          if (categories.isEmpty) {
            return const Center(
              child: Text('No categories yet. Create one to get started!'),
            );
          }

          return ReorderableListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: categories.length,
            onReorder: (oldIndex, newIndex) {
              if (oldIndex < newIndex) {
                newIndex -= 1;
              }
              if (!categories[oldIndex].isUntracked) {
                provider.reorderCategories(oldIndex, newIndex);
              }
            },
            itemBuilder: (context, index) {
              final category = categories[index];
              return Dismissible(
                key: Key(category.id),
                direction: category.isUntracked
                    ? DismissDirection.none
                    : DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 16),
                  child: const Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                ),
                confirmDismiss: (direction) =>
                    _confirmDelete(context, category),
                onDismissed: (direction) {
                  provider.deleteCategory(category.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${category.name} deleted'),
                      action: SnackBarAction(
                        label: 'UNDO',
                        onPressed: () {
                          provider.addCategory(
                            category.name,
                            category.emoji,
                          );
                        },
                      ),
                    ),
                  );
                },
                child: CategoryListItem(
                  category: category,
                  onEdit: category.isUntracked
                      ? null
                      : () => _showEditDialog(context, category),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddCategoryDialog(),
    );
  }

  void _showEditDialog(BuildContext context, Category category) {
    showDialog(
      context: context,
      builder: (context) => EditCategoryDialog(category: category),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context, Category category) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category?'),
        content: Text(
          'All transactions in "${category.name}" will be moved to Untracked. '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
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

class EditCategoryDialog extends StatefulWidget {
  final Category category;

  const EditCategoryDialog({
    Key? key,
    required this.category,
  }) : super(key: key);

  @override
  State<EditCategoryDialog> createState() => _EditCategoryDialogState();
}

class _EditCategoryDialogState extends State<EditCategoryDialog> {
  late final TextEditingController _nameController;
  late String _selectedEmoji;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category.name);
    _selectedEmoji = widget.category.emoji;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Category'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Category Name',
            ),
          ),
          const SizedBox(height: 16),
          EmojiPicker(
            selectedEmoji: _selectedEmoji,
            onEmojiSelected: (emoji) {
              setState(() => _selectedEmoji = emoji);
            },
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () => _confirmDelete(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete Category'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CANCEL'),
        ),
        TextButton(
          onPressed: _handleSubmit,
          child: const Text('SAVE'),
        ),
      ],
    );
  }

  void _handleSubmit() {
    context.read<LedgerProvider>().updateCategory(
          widget.category.id,
          _nameController.text,
          _selectedEmoji,
        );
    Navigator.pop(context);
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category?'),
        content: const Text(
          'All transactions will be moved to the Untracked category. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              context.read<LedgerProvider>().deleteCategory(widget.category.id);
              Navigator.pop(context); // Close confirmation dialog
              Navigator.pop(context); // Close edit dialog
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

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
