import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/reminder.dart';

class ReminderItemWidget extends StatelessWidget {
  final Reminder reminder;
  final VoidCallback? onTap;
  final VoidCallback? onToggleComplete;
  final VoidCallback? onDelete;

  const ReminderItemWidget({
    super.key,
    required this.reminder,
    this.onTap,
    this.onToggleComplete,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    final statusIcon = _getStatusIcon();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                GestureDetector(
                  onTap: onToggleComplete,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: reminder.isCompleted
                          ? Colors.green
                          : Colors.transparent,
                      border: Border.all(
                        color: reminder.isCompleted
                            ? Colors.green
                            : Colors.grey.shade400,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: reminder.isCompleted
                        ? const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 16,
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(statusIcon, color: statusColor, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reminder.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          decoration: reminder.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                          color: reminder.isCompleted
                              ? Colors.grey.shade600
                              : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (reminder.description != null) ...[
                        Text(
                          reminder.description!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                      ],
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              _getStatusText(),
                              style: TextStyle(
                                fontSize: 10,
                                color: statusColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            DateFormat('MMM dd, yyyy').format(reminder.dueDate),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                          ),
                          if (reminder.isRecurring) ...[
                            const SizedBox(width: 8),
                            Icon(
                              Icons.repeat_rounded,
                              size: 12,
                              color: Colors.grey.shade600,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (reminder.amount != null)
                      Text(
                        NumberFormat.currency(symbol: '\$').format(reminder.amount),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    const SizedBox(height: 4),
                    if (onDelete != null)
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'delete') {
                            onDelete?.call();
                          } else if (value == 'toggle') {
                            onToggleComplete?.call();
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'toggle',
                            child: Row(
                              children: [
                                Icon(
                                  reminder.isCompleted
                                      ? Icons.undo_rounded
                                      : Icons.check_circle_rounded,
                                  color: reminder.isCompleted
                                      ? Colors.orange
                                      : Colors.green,
                                ),
                                const SizedBox(width: 8),
                                Text(reminder.isCompleted
                                    ? 'Mark Incomplete'
                                    : 'Mark Complete'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete_rounded, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Delete'),
                              ],
                            ),
                          ),
                        ],
                        child: Icon(
                          Icons.more_vert_rounded,
                          color: Colors.grey.shade600,
                          size: 20,
                        ),
                      )
                    else
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Colors.grey.shade400,
                        size: 16,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor() {
    if (reminder.isCompleted) return Colors.green;
    if (reminder.isOverdue) return Colors.red;
    if (reminder.isDueToday) return Colors.orange;
    return const Color(0xFF6C63FF);
  }

  IconData _getStatusIcon() {
    if (reminder.isCompleted) return Icons.check_circle_rounded;
    if (reminder.isOverdue) return Icons.warning_rounded;
    if (reminder.isDueToday) return Icons.today_rounded;

    switch (reminder.type) {
      case ReminderType.billPayment:
        return Icons.receipt_rounded;
      case ReminderType.subscription:
        return Icons.subscriptions_rounded;
      case ReminderType.custom:
        return Icons.notification_important_rounded;
    }
  }

  String _getStatusText() {
    if (reminder.isCompleted) return 'Completed';
    if (reminder.isOverdue) return 'Overdue';
    if (reminder.isDueToday) return 'Due Today';

    final daysUntilDue = reminder.dueDate.difference(DateTime.now()).inDays;
    if (daysUntilDue == 1) return 'Tomorrow';
    if (daysUntilDue < 7) return 'In $daysUntilDue days';
    if (daysUntilDue < 30) return 'In ${(daysUntilDue / 7).round()} weeks';
    return 'In ${(daysUntilDue / 30).round()} months';
  }
}