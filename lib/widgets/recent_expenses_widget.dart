import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/expense_provider.dart';
import '../widgets/expense_item_widget.dart';

class RecentExpensesWidget extends StatelessWidget {
  const RecentExpensesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseProvider>(
      builder: (context, provider, child) {
        final recentExpenses = provider.getRecentExpenses(limit: 5);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Expenses',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2E3A47),
                  ),
                ),
                if (recentExpenses.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      // Navigate to all expenses - could be implemented with navigation
                      DefaultTabController.of(context)?.animateTo(1);
                    },
                    child: const Text('View All'),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (recentExpenses.isEmpty)
              _buildEmptyState(context)
            else
              ...recentExpenses.asMap().entries.map((entry) {
                final index = entry.key;
                final expense = entry.value;
                final category = provider.getCategoryById(expense.categoryId);

                return ExpenseItemWidget(
                  expense: expense,
                  category: category,
                  onTap: () {
                    // Could navigate to expense details or edit screen
                  },
                ).animate().fadeIn(
                  delay: Duration(milliseconds: index * 100),
                  duration: 600.ms,
                ).slideX(begin: 0.3, end: 0);
              }),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      height: 120,
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
              Icons.receipt_long_rounded,
              size: 32,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 8),
            Text(
              'No recent expenses',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            Text(
              'Start tracking your expenses',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 600.ms);
  }
}