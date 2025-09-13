import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/expense_provider.dart';
import '../providers/reminder_provider.dart';
import '../widgets/dashboard_card.dart';
import '../widgets/recent_expenses_widget.dart';
import '../widgets/upcoming_reminders_widget.dart';
import '../widgets/category_spending_widget.dart';
import 'add_expense_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF6C63FF),
              Color(0xFF03DAC6),
            ],
            stops: [0.0, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildOverviewCards(context),
                        const SizedBox(height: 24),
                        _buildQuickActions(context),
                        const SizedBox(height: 24),
                        const CategorySpendingWidget(),
                        const SizedBox(height: 24),
                        const RecentExpensesWidget(),
                        const SizedBox(height: 24),
                        const UpcomingRemindersWidget(),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddExpense(context),
        child: const Icon(Icons.add_rounded),
      ).animate().scale(delay: 800.ms, duration: 400.ms),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good ${_getGreeting()}!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.2, end: 0),
              const SizedBox(height: 4),
              Text(
                'Track your expenses smartly',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withOpacity(0.8),
                ),
              ).animate().fadeIn(delay: 200.ms, duration: 600.ms).slideX(begin: -0.2, end: 0),
            ],
          ),
          const Spacer(),
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.notifications_rounded,
              color: Colors.white,
            ),
          ).animate().fadeIn(delay: 400.ms, duration: 600.ms).scale(),
        ],
      ),
    );
  }

  Widget _buildOverviewCards(BuildContext context) {
    return Consumer<ExpenseProvider>(
      builder: (context, provider, child) {
        final today = DateTime.now();
        final thisMonth = DateTime(today.year, today.month);
        final lastMonth = DateTime(today.year, today.month - 1);

        final thisMonthTotal = provider.getMonthlyTotal(thisMonth);
        final lastMonthTotal = provider.getMonthlyTotal(lastMonth);
        final todayTotal = provider.getDailyTotal(today);
        final totalExpenses = provider.expenses.length;

        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: DashboardCard(
                    title: 'This Month',
                    amount: thisMonthTotal,
                    icon: Icons.calendar_month_rounded,
                    color: const Color(0xFF6C63FF),
                  ).animate().fadeIn(delay: 100.ms, duration: 600.ms).slideY(begin: 0.3, end: 0),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DashboardCard(
                    title: 'Today',
                    amount: todayTotal,
                    icon: Icons.today_rounded,
                    color: const Color(0xFF03DAC6),
                  ).animate().fadeIn(delay: 200.ms, duration: 600.ms).slideY(begin: 0.3, end: 0),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DashboardCard(
                    title: 'Last Month',
                    amount: lastMonthTotal,
                    icon: Icons.trending_down_rounded,
                    color: const Color(0xFFFF6584),
                  ).animate().fadeIn(delay: 300.ms, duration: 600.ms).slideY(begin: 0.3, end: 0),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DashboardCard(
                    title: 'Total Expenses',
                    amount: totalExpenses.toDouble(),
                    icon: Icons.receipt_long_rounded,
                    color: const Color(0xFFFF9800),
                    isCount: true,
                  ).animate().fadeIn(delay: 400.ms, duration: 600.ms).slideY(begin: 0.3, end: 0),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2E3A47),
          ),
        ).animate().fadeIn(delay: 500.ms, duration: 600.ms),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                context,
                'Add Expense',
                Icons.add_circle_rounded,
                const Color(0xFF6C63FF),
                () => _navigateToAddExpense(context),
              ).animate().fadeIn(delay: 600.ms, duration: 600.ms).slideX(begin: -0.2, end: 0),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                context,
                'View Reports',
                Icons.analytics_rounded,
                const Color(0xFF03DAC6),
                () => DefaultTabController.of(context)?.animateTo(2),
              ).animate().fadeIn(delay: 700.ms, duration: 600.ms).slideX(begin: 0.2, end: 0),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2E3A47),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }

  void _navigateToAddExpense(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddExpenseScreen(),
      ),
    );
  }
}