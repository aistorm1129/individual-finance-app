import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/expense_provider.dart';
import '../widgets/expense_chart_widget.dart';
import '../widgets/category_breakdown_widget.dart';
import '../widgets/monthly_trend_widget.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedPeriod = 'This Month';
  final List<String> _periods = ['This Week', 'This Month', 'Last 3 Months', 'This Year'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.date_range_rounded),
            onSelected: (value) => setState(() => _selectedPeriod = value),
            itemBuilder: (context) => _periods.map((period) {
              return PopupMenuItem(
                value: period,
                child: Row(
                  children: [
                    Icon(
                      _selectedPeriod == period
                          ? Icons.check_circle
                          : Icons.circle_outlined,
                      size: 16,
                      color: _selectedPeriod == period
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Text(period),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview', icon: Icon(Icons.dashboard_rounded)),
            Tab(text: 'Categories', icon: Icon(Icons.pie_chart_rounded)),
            Tab(text: 'Trends', icon: Icon(Icons.trending_up_rounded)),
          ],
        ),
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, provider, child) {
          return TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(provider),
              _buildCategoriesTab(provider),
              _buildTrendsTab(provider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOverviewTab(ExpenseProvider provider) {
    final dateRange = _getDateRange(_selectedPeriod);
    final expenses = provider.getExpensesInDateRange(dateRange.start, dateRange.end);
    final totalAmount = expenses.fold<double>(0, (sum, expense) => sum + expense.amount);
    final averageDaily = totalAmount / (dateRange.end.difference(dateRange.start).inDays + 1);
    final expenseCount = expenses.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatsCards(totalAmount, averageDaily, expenseCount)
              .animate()
              .fadeIn(duration: 600.ms)
              .slideY(begin: 0.3, end: 0),

          const SizedBox(height: 24),

          Text(
            'Expense Distribution',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ).animate().fadeIn(delay: 200.ms, duration: 600.ms),

          const SizedBox(height: 16),

          SizedBox(
            height: 300,
            child: ExpenseChartWidget(
              expenses: expenses,
              categories: provider.categories,
            ),
          ).animate().fadeIn(delay: 400.ms, duration: 600.ms),

          const SizedBox(height: 24),

          _buildTopExpenses(expenses, provider)
              .animate()
              .fadeIn(delay: 600.ms, duration: 600.ms)
              .slideY(begin: 0.3, end: 0),
        ],
      ),
    );
  }

  Widget _buildCategoriesTab(ExpenseProvider provider) {
    final dateRange = _getDateRange(_selectedPeriod);
    final expenses = provider.getExpensesInDateRange(dateRange.start, dateRange.end);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Category Breakdown',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ).animate().fadeIn(duration: 600.ms),

          const SizedBox(height: 16),

          CategoryBreakdownWidget(
            expenses: expenses,
            categories: provider.categories,
          ).animate().fadeIn(delay: 200.ms, duration: 600.ms),
        ],
      ),
    );
  }

  Widget _buildTrendsTab(ExpenseProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Monthly Trends',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ).animate().fadeIn(duration: 600.ms),

          const SizedBox(height: 16),

          MonthlyTrendWidget(
            expenses: provider.expenses,
          ).animate().fadeIn(delay: 200.ms, duration: 600.ms),

          const SizedBox(height: 24),

          _buildInsights(provider)
              .animate()
              .fadeIn(delay: 400.ms, duration: 600.ms)
              .slideY(begin: 0.3, end: 0),
        ],
      ),
    );
  }

  Widget _buildStatsCards(double totalAmount, double averageDaily, int expenseCount) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total Spent',
            NumberFormat.currency(symbol: '\$').format(totalAmount),
            Icons.account_balance_wallet_rounded,
            const Color(0xFF6C63FF),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Daily Average',
            NumberFormat.currency(symbol: '\$').format(averageDaily),
            Icons.timeline_rounded,
            const Color(0xFF03DAC6),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Transactions',
            expenseCount.toString(),
            Icons.receipt_long_rounded,
            const Color(0xFFFF6584),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopExpenses(List expenses, ExpenseProvider provider) {
    if (expenses.isEmpty) return const SizedBox();

    final sortedExpenses = [...expenses]..sort((a, b) => b.amount.compareTo(a.amount));
    final topExpenses = sortedExpenses.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Top Expenses',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        ...topExpenses.asMap().entries.map((entry) {
          final index = entry.key;
          final expense = entry.value;
          final category = provider.getCategoryById(expense.categoryId);

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: category?.color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: category?.color,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  category?.icon ?? '📦',
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        expense.title,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        DateFormat('MMM dd').format(expense.date),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  NumberFormat.currency(symbol: '\$').format(expense.amount),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: category?.color,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: Duration(milliseconds: 600 + (index * 100)), duration: 600.ms);
        }),
      ],
    );
  }

  Widget _buildInsights(ExpenseProvider provider) {
    final thisMonth = DateTime.now();
    final lastMonth = DateTime(thisMonth.year, thisMonth.month - 1);

    final thisMonthTotal = provider.getMonthlyTotal(thisMonth);
    final lastMonthTotal = provider.getMonthlyTotal(lastMonth);

    final difference = thisMonthTotal - lastMonthTotal;
    final percentChange = lastMonthTotal > 0 ? (difference / lastMonthTotal * 100) : 0;

    final isIncrease = difference > 0;
    final insights = <String>[];

    if (thisMonthTotal > 0) {
      if (isIncrease) {
        insights.add('Your spending increased by ${percentChange.abs().toStringAsFixed(1)}% compared to last month.');
      } else {
        insights.add('Great job! Your spending decreased by ${percentChange.abs().toStringAsFixed(1)}% compared to last month.');
      }
    }

    final mostSpentCategory = provider.getMostSpentCategory();
    if (mostSpentCategory != null) {
      insights.add('You spend the most on ${mostSpentCategory.name}.');
    }

    if (insights.isEmpty) {
      insights.add('Add more expenses to see personalized insights!');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Smart Insights',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        ...insights.map((insight) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF6C63FF).withOpacity(0.1),
                const Color(0xFF03DAC6).withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF6C63FF).withOpacity(0.2),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.lightbulb_rounded,
                color: const Color(0xFF6C63FF),
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  insight,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  DateTimeRange _getDateRange(String period) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (period) {
      case 'This Week':
        final weekday = now.weekday;
        final startOfWeek = today.subtract(Duration(days: weekday - 1));
        final endOfWeek = startOfWeek.add(const Duration(days: 6));
        return DateTimeRange(start: startOfWeek, end: endOfWeek);

      case 'This Month':
        final startOfMonth = DateTime(now.year, now.month, 1);
        final endOfMonth = DateTime(now.year, now.month + 1, 0);
        return DateTimeRange(start: startOfMonth, end: endOfMonth);

      case 'Last 3 Months':
        final start = DateTime(now.year, now.month - 2, 1);
        final end = DateTime(now.year, now.month + 1, 0);
        return DateTimeRange(start: start, end: end);

      case 'This Year':
        final startOfYear = DateTime(now.year, 1, 1);
        final endOfYear = DateTime(now.year, 12, 31);
        return DateTimeRange(start: startOfYear, end: endOfYear);

      default:
        return DateTimeRange(start: today, end: today);
    }
  }
}