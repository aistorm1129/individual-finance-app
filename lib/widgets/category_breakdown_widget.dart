import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/expense.dart';
import '../models/category.dart';

class CategoryBreakdownWidget extends StatelessWidget {
  final List<Expense> expenses;
  final List<Category> categories;

  const CategoryBreakdownWidget({
    super.key,
    required this.expenses,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    if (expenses.isEmpty) {
      return _buildEmptyState(context);
    }

    final categoryTotals = _calculateCategoryTotals();
    final total = categoryTotals.values.fold<double>(0, (sum, value) => sum + value);

    if (total == 0) {
      return _buildEmptyState(context);
    }

    final sortedEntries = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      children: sortedEntries.asMap().entries.map((entry) {
        final index = entry.key;
        final categoryEntry = entry.value;
        final category = categories.firstWhere(
          (cat) => cat.id == categoryEntry.key,
          orElse: () => categories.last,
        );
        final amount = categoryEntry.value;
        final percentage = (amount / total) * 100;
        final expenseCount = expenses
            .where((expense) => expense.categoryId == category.id)
            .length;

        return _buildCategoryItem(
          context,
          category,
          amount,
          percentage,
          expenseCount,
        ).animate().fadeIn(
          delay: Duration(milliseconds: index * 100),
          duration: 600.ms,
        ).slideX(begin: 0.3, end: 0);
      }).toList(),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.category_rounded,
              size: 48,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 8),
            Text(
              'No expenses to categorize',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryItem(
    BuildContext context,
    Category category,
    double amount,
    double percentage,
    int expenseCount,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: category.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        category.icon,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$expenseCount transaction${expenseCount != 1 ? 's' : ''}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        NumberFormat.currency(symbol: '\$').format(amount),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: category.color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${percentage.toStringAsFixed(1)}%',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildProgressBar(percentage, category.color),
              if (category.budgetLimit != null) ...[
                const SizedBox(height: 8),
                _buildBudgetInfo(context, amount, category.budgetLimit!, category.color),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar(double percentage, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Share of total',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            Text(
              '${percentage.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  Widget _buildBudgetInfo(BuildContext context, double spent, double budget, Color color) {
    final budgetPercentage = (spent / budget) * 100;
    final isOverBudget = spent > budget;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isOverBudget
            ? Colors.red.withOpacity(0.1)
            : color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            isOverBudget ? Icons.warning_rounded : Icons.savings_rounded,
            size: 16,
            color: isOverBudget ? Colors.red : color,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              isOverBudget
                  ? 'Over budget by ${NumberFormat.currency(symbol: '\$').format(spent - budget)}'
                  : '${NumberFormat.currency(symbol: '\$').format(budget - spent)} remaining',
              style: TextStyle(
                fontSize: 12,
                color: isOverBudget ? Colors.red : color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            '${budgetPercentage.toStringAsFixed(0)}%',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isOverBudget ? Colors.red : color,
            ),
          ),
        ],
      ),
    );
  }

  Map<String, double> _calculateCategoryTotals() {
    final totals = <String, double>{};
    for (final expense in expenses) {
      totals[expense.categoryId] = (totals[expense.categoryId] ?? 0) + expense.amount;
    }
    return totals;
  }
}