import 'package:flutter/material.dart';

class TransactionFilter extends StatelessWidget {
  final String selectedFilter;
  final Function(String) onFilterChanged;

  const TransactionFilter({
    Key? key,
    required this.selectedFilter,
    required this.onFilterChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildFilterChip('All', 'all'),
          const SizedBox(width: 8),
          _buildFilterChip('Income', 'income'),
          const SizedBox(width: 8),
          _buildFilterChip('Expenses', 'expenses'),
          const SizedBox(width: 8),
          _buildFilterChip('Transfers', 'transfers'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    return FilterChip(
      label: Text(label),
      selected: selectedFilter == value,
      onSelected: (_) => onFilterChanged(value),
    );
  }
} 