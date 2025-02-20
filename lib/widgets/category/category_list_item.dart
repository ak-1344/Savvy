import 'package:flutter/material.dart';
import '../../models/category.dart';

class CategoryListItem extends StatelessWidget {
  final Category category;
  final VoidCallback? onEdit;
  final bool showBalance;

  const CategoryListItem({
    Key? key,
    required this.category,
    this.onEdit,
    this.showBalance = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Text(
            category.emoji,
            style: const TextStyle(fontSize: 20),
          ),
        ),
        title: Text(
          category.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: showBalance
            ? Text(
                'Balance: ₹${category.balance.toStringAsFixed(2)}',
                style: TextStyle(
                  color: category.balance >= 0 ? Colors.green : Colors.red,
                ),
              )
            : null,
        trailing: category.isUntracked
            ? const Chip(
                label: Text('Default'),
                backgroundColor: Colors.grey,
              )
            : IconButton(
                icon: const Icon(Icons.edit),
                onPressed: onEdit,
              ),
      ),
    );
  }
} 