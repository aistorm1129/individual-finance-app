import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/expense_provider.dart';
import '../models/expense.dart';
import '../widgets/expense_item_widget.dart';
import 'add_expense_screen.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  String _selectedFilter = 'All';
  String _selectedSort = 'Date';
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: _showSearchDialog,
          ),
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, provider, child) {
          final expenses = _getFilteredExpenses(provider);

          if (expenses.isEmpty) {
            return _buildEmptyState();
          }

          return Column(
            children: [
              _buildSummaryCard(expenses),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: expenses.length,
                  itemBuilder: (context, index) {
                    final expense = expenses[index];
                    return ExpenseItemWidget(
                      expense: expense,
                      category: provider.getCategoryById(expense.categoryId),
                      onTap: () => _navigateToEditExpense(expense),
                      onDelete: () => _deleteExpense(expense.id, provider),
                    )
                        .animate()
                        .fadeIn(
                          delay: Duration(milliseconds: index * 50),
                          duration: 600.ms,
                        )
                        .slideY(begin: 0.3, end: 0);
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddExpense(),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  Widget _buildSummaryCard(List<Expense> expenses) {
    final total = expenses.fold<double>(0, (sum, expense) => sum + expense.amount);
    final count = expenses.length;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6C63FF), Color(0xFF03DAC6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C63FF).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Amount',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  NumberFormat.currency(symbol: '\$').format(total),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.white.withOpacity(0.3),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Expenses',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  count.toString(),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.3, end: 0);
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_rounded,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No expenses found',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start tracking your expenses by adding one',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _navigateToAddExpense,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add First Expense'),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 800.ms).scale(delay: 200.ms);
  }

  List<Expense> _getFilteredExpenses(ExpenseProvider provider) {
    var expenses = provider.expenses.toList();

    // Apply search filter
    if (_searchController.text.isNotEmpty) {
      expenses = expenses.where((expense) {
        return expense.title.toLowerCase().contains(_searchController.text.toLowerCase()) ||
            (expense.description?.toLowerCase().contains(_searchController.text.toLowerCase()) ?? false);
      }).toList();
    }

    // Apply category filter
    if (_selectedFilter != 'All') {
      final category = provider.categories.firstWhere(
        (cat) => cat.name == _selectedFilter,
        orElse: () => provider.categories.first,
      );
      expenses = expenses.where((expense) => expense.categoryId == category.id).toList();
    }

    // Apply sorting
    switch (_selectedSort) {
      case 'Date':
        expenses.sort((a, b) => b.date.compareTo(a.date));
        break;
      case 'Amount (High to Low)':
        expenses.sort((a, b) => b.amount.compareTo(a.amount));
        break;
      case 'Amount (Low to High)':
        expenses.sort((a, b) => a.amount.compareTo(b.amount));
        break;
      case 'Title':
        expenses.sort((a, b) => a.title.compareTo(b.title));
        break;
    }

    return expenses;
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Expenses'),
        content: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Search by title or description...',
            prefixIcon: Icon(Icons.search_rounded),
          ),
          onChanged: (value) => setState(() {}),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _searchController.clear();
              setState(() {});
              Navigator.of(context).pop();
            },
            child: const Text('Clear'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    final provider = Provider.of<ExpenseProvider>(context, listen: false);
    final categories = ['All', ...provider.categories.map((cat) => cat.name)];
    final sortOptions = [
      'Date',
      'Amount (High to Low)',
      'Amount (Low to High)',
      'Title',
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter & Sort'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Filter by Category:'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: categories.map((category) {
                  return FilterChip(
                    label: Text(category),
                    selected: _selectedFilter == category,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedFilter = category);
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              const Text('Sort by:'),
              const SizedBox(height: 8),
              Column(
                children: sortOptions.map((option) {
                  return RadioListTile<String>(
                    title: Text(option),
                    value: option,
                    groupValue: _selectedSort,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedSort = value);
                      }
                    },
                    dense: true,
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedFilter = 'All';
                _selectedSort = 'Date';
              });
              Navigator.of(context).pop();
            },
            child: const Text('Reset'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _navigateToAddExpense() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddExpenseScreen(),
      ),
    );
  }

  void _navigateToEditExpense(Expense expense) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddExpenseScreen(expense: expense),
      ),
    );
  }

  Future<void> _deleteExpense(String expenseId, ExpenseProvider provider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Expense'),
        content: const Text('Are you sure you want to delete this expense?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await provider.deleteExpense(expenseId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Expense deleted successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting expense: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}