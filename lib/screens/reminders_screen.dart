import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/reminder_provider.dart';
import '../models/reminder.dart';
import '../widgets/reminder_item_widget.dart';
import 'add_reminder_screen.dart';

class RemindersScreen extends StatelessWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reminders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => _navigateToAddReminder(context),
          ),
        ],
      ),
      body: Consumer<ReminderProvider>(
        builder: (context, provider, child) {
          final reminders = provider.reminders;

          if (reminders.isEmpty) {
            return _buildEmptyState(context);
          }

          final overdueReminders = reminders.where((r) => r.isOverdue).toList();
          final todayReminders = reminders.where((r) => r.isDueToday && !r.isCompleted).toList();
          final upcomingReminders = reminders
              .where((r) => r.dueDate.isAfter(DateTime.now()) && !r.isDueToday && !r.isCompleted)
              .toList();
          final completedReminders = reminders.where((r) => r.isCompleted).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (overdueReminders.isNotEmpty) ...[
                  _buildSection(
                    context,
                    'Overdue',
                    overdueReminders,
                    provider,
                    Colors.red,
                    Icons.warning_rounded,
                  ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.3, end: 0),
                  const SizedBox(height: 24),
                ],

                if (todayReminders.isNotEmpty) ...[
                  _buildSection(
                    context,
                    'Due Today',
                    todayReminders,
                    provider,
                    Colors.orange,
                    Icons.today_rounded,
                  ).animate().fadeIn(delay: 200.ms, duration: 600.ms).slideY(begin: 0.3, end: 0),
                  const SizedBox(height: 24),
                ],

                if (upcomingReminders.isNotEmpty) ...[
                  _buildSection(
                    context,
                    'Upcoming',
                    upcomingReminders,
                    provider,
                    const Color(0xFF6C63FF),
                    Icons.schedule_rounded,
                  ).animate().fadeIn(delay: 400.ms, duration: 600.ms).slideY(begin: 0.3, end: 0),
                  const SizedBox(height: 24),
                ],

                if (completedReminders.isNotEmpty) ...[
                  _buildSection(
                    context,
                    'Completed',
                    completedReminders,
                    provider,
                    Colors.green,
                    Icons.check_circle_rounded,
                  ).animate().fadeIn(delay: 600.ms, duration: 600.ms).slideY(begin: 0.3, end: 0),
                  const SizedBox(height: 24),
                ],

                const SizedBox(height: 100),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddReminder(context),
        child: const Icon(Icons.add_rounded),
      ).animate().scale(delay: 800.ms, duration: 400.ms),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_rounded,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No reminders yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Set up payment reminders to never miss a bill',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => _navigateToAddReminder(context),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add First Reminder'),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 800.ms).scale(delay: 200.ms);
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    List<Reminder> reminders,
    ReminderProvider provider,
    Color color,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                reminders.length.toString(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...reminders.asMap().entries.map((entry) {
          final index = entry.key;
          final reminder = entry.value;
          return ReminderItemWidget(
            reminder: reminder,
            onTap: () => _navigateToEditReminder(context, reminder),
            onToggleComplete: () => _toggleReminderComplete(provider, reminder),
            onDelete: () => _deleteReminder(context, provider, reminder),
          ).animate().fadeIn(
            delay: Duration(milliseconds: index * 100),
            duration: 600.ms,
          );
        }),
      ],
    );
  }

  void _navigateToAddReminder(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddReminderScreen(),
      ),
    );
  }

  void _navigateToEditReminder(BuildContext context, Reminder reminder) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddReminderScreen(reminder: reminder),
      ),
    );
  }

  Future<void> _toggleReminderComplete(ReminderProvider provider, Reminder reminder) async {
    try {
      final updatedReminder = reminder.copyWith(
        isCompleted: !reminder.isCompleted,
        completedDate: !reminder.isCompleted ? DateTime.now() : null,
      );
      await provider.updateReminder(updatedReminder);
    } catch (e) {
      // Handle error silently or show a snackbar
    }
  }

  Future<void> _deleteReminder(
    BuildContext context,
    ReminderProvider provider,
    Reminder reminder,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Reminder'),
        content: const Text('Are you sure you want to delete this reminder?'),
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
        await provider.deleteReminder(reminder.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Reminder deleted successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting reminder: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}