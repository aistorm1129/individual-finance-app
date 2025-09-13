import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/reminder_provider.dart';
import '../screens/reminders_screen.dart';

class UpcomingRemindersWidget extends StatelessWidget {
  const UpcomingRemindersWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ReminderProvider>(
      builder: (context, provider, child) {
        final overdueReminders = provider.overdueReminders;
        final todayReminders = provider.todayReminders;
        final upcomingReminders = provider.upcomingReminders.take(3).toList();

        final hasReminders = overdueReminders.isNotEmpty ||
            todayReminders.isNotEmpty ||
            upcomingReminders.isNotEmpty;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Payment Reminders',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2E3A47),
                  ),
                ),
                if (hasReminders)
                  TextButton(
                    onPressed: () => _navigateToReminders(context),
                    child: const Text('View All'),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (!hasReminders)
              _buildEmptyState(context)
            else
              Column(
                children: [
                  // Overdue reminders
                  ...overdueReminders.take(2).map((reminder) =>
                    _buildReminderItem(
                      context,
                      reminder.title,
                      reminder.amount,
                      'Overdue',
                      Colors.red,
                      Icons.warning_rounded,
                      reminder.dueDate,
                    ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.3, end: 0)
                  ),

                  // Today's reminders
                  ...todayReminders.take(2).map((reminder) =>
                    _buildReminderItem(
                      context,
                      reminder.title,
                      reminder.amount,
                      'Due Today',
                      Colors.orange,
                      Icons.today_rounded,
                      reminder.dueDate,
                    ).animate().fadeIn(delay: 100.ms, duration: 600.ms).slideX(begin: -0.3, end: 0)
                  ),

                  // Upcoming reminders
                  ...upcomingReminders.map((reminder) =>
                    _buildReminderItem(
                      context,
                      reminder.title,
                      reminder.amount,
                      _getRelativeDate(reminder.dueDate),
                      const Color(0xFF6C63FF),
                      Icons.schedule_rounded,
                      reminder.dueDate,
                    ).animate().fadeIn(delay: 200.ms, duration: 600.ms).slideX(begin: -0.3, end: 0)
                  ),
                ],
              ),
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
              Icons.notifications_rounded,
              size: 32,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 8),
            Text(
              'No upcoming reminders',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            Text(
              'Set payment reminders to stay organized',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 600.ms);
  }

  Widget _buildReminderItem(
    BuildContext context,
    String title,
    double? amount,
    String status,
    Color statusColor,
    IconData icon,
    DateTime dueDate,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: statusColor, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            status,
                            style: TextStyle(
                              fontSize: 10,
                              color: statusColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat('MMM dd').format(dueDate),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (amount != null)
                Text(
                  NumberFormat.currency(symbol: '\$').format(amount),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _getRelativeDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;

    if (difference == 0) return 'Today';
    if (difference == 1) return 'Tomorrow';
    if (difference < 7) return 'In $difference days';
    if (difference < 30) return 'In ${(difference / 7).round()} weeks';
    return 'In ${(difference / 30).round()} months';
  }

  void _navigateToReminders(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const RemindersScreen(),
      ),
    );
  }
}