import 'package:flutter/material.dart';
import '../models/reminder.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';

class ReminderProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  List<Reminder> _reminders = [];
  bool _isLoading = false;

  List<Reminder> get reminders => _reminders;
  bool get isLoading => _isLoading;

  List<Reminder> get overdueReminders =>
      _reminders.where((r) => r.isOverdue).toList();

  List<Reminder> get todayReminders =>
      _reminders.where((r) => r.isDueToday && !r.isCompleted).toList();

  List<Reminder> get upcomingReminders =>
      _reminders
          .where((r) =>
              r.dueDate.isAfter(DateTime.now()) &&
              !r.isDueToday &&
              !r.isCompleted)
          .toList();

  Future<void> loadReminders() async {
    _isLoading = true;
    notifyListeners();

    try {
      _reminders = await _databaseService.getReminders();
      _reminders.sort((a, b) => a.dueDate.compareTo(b.dueDate));

      if (_reminders.isEmpty) {
        await _createMockupReminders();
      }
    } catch (e) {
      debugPrint('Error loading reminders: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _createMockupReminders() async {
    final mockReminders = [
      Reminder(
        title: 'Electric Bill',
        description: 'Monthly electricity bill payment',
        amount: 120.30,
        dueDate: DateTime.now().add(const Duration(days: 3)),
        type: ReminderType.billPayment,
        isRecurring: true,
        recurringDays: 30,
        categoryId: '5', // Bills & Utilities
      ),
      Reminder(
        title: 'Netflix Subscription',
        description: 'Monthly Netflix payment',
        amount: 15.99,
        dueDate: DateTime.now().add(const Duration(days: 7)),
        type: ReminderType.subscription,
        isRecurring: true,
        recurringDays: 30,
      ),
      Reminder(
        title: 'Car Insurance',
        description: 'Quarterly car insurance payment',
        amount: 350.00,
        dueDate: DateTime.now().add(const Duration(days: 15)),
        type: ReminderType.billPayment,
        isRecurring: true,
        recurringDays: 90,
        categoryId: '2', // Transportation
      ),
      Reminder(
        title: 'Gym Membership',
        description: 'Monthly gym membership fee',
        amount: 45.00,
        dueDate: DateTime.now().add(const Duration(days: 10)),
        type: ReminderType.subscription,
        isRecurring: true,
        recurringDays: 30,
      ),
      Reminder(
        title: 'Rent Payment',
        description: 'Monthly apartment rent',
        amount: 1200.00,
        dueDate: DateTime.now().add(const Duration(days: 25)),
        type: ReminderType.billPayment,
        isRecurring: true,
        recurringDays: 30,
      ),
    ];

    for (final reminder in mockReminders) {
      await _databaseService.insertReminder(reminder);
      _reminders.add(reminder);
      await _scheduleNotification(reminder);
    }

    _reminders.sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }

  Future<void> addReminder(Reminder reminder) async {
    await _databaseService.insertReminder(reminder);
    _reminders.add(reminder);
    _reminders.sort((a, b) => a.dueDate.compareTo(b.dueDate));

    await _scheduleNotification(reminder);
    notifyListeners();
  }

  Future<void> updateReminder(Reminder reminder) async {
    await _databaseService.updateReminder(reminder);
    final index = _reminders.indexWhere((r) => r.id == reminder.id);
    if (index != -1) {
      _reminders[index] = reminder;
      _reminders.sort((a, b) => a.dueDate.compareTo(b.dueDate));

      await _scheduleNotification(reminder);
      notifyListeners();
    }
  }

  Future<void> deleteReminder(String id) async {
    await _databaseService.deleteReminder(id);
    _reminders.removeWhere((reminder) => reminder.id == id);

    await NotificationService.cancelNotification(id.hashCode);
    notifyListeners();
  }

  Future<void> completeReminder(String id) async {
    final index = _reminders.indexWhere((r) => r.id == id);
    if (index != -1) {
      final reminder = _reminders[index];
      final updatedReminder = reminder.copyWith(
        isCompleted: true,
        completedDate: DateTime.now(),
      );

      await updateReminder(updatedReminder);

      if (reminder.isRecurring && reminder.recurringDays != null) {
        final nextReminder = reminder.copyWith(
          dueDate: reminder.dueDate.add(Duration(days: reminder.recurringDays!)),
          isCompleted: false,
          completedDate: null,
        );
        await addReminder(nextReminder);
      }
    }
  }

  Future<void> clearAllReminders() async {
    await _databaseService.clearAllReminders();

    for (final reminder in _reminders) {
      await NotificationService.cancelNotification(reminder.id.hashCode);
    }

    _reminders.clear();
    notifyListeners();
  }

  Future<void> _scheduleNotification(Reminder reminder) async {
    if (reminder.isCompleted || reminder.dueDate.isBefore(DateTime.now())) {
      return;
    }

    final title = 'Payment Reminder';
    final body = reminder.amount != null
        ? '${reminder.title} - \$${reminder.amount!.toStringAsFixed(2)} is due'
        : '${reminder.title} is due';

    await NotificationService.scheduleNotification(
      id: reminder.id.hashCode,
      title: title,
      body: body,
      scheduledDate: reminder.dueDate.subtract(const Duration(hours: 2)), // 2 hours before
    );

    await NotificationService.scheduleNotification(
      id: reminder.id.hashCode + 1000000, // Different ID for same-day notification
      title: 'Due Today!',
      body: body,
      scheduledDate: DateTime(
        reminder.dueDate.year,
        reminder.dueDate.month,
        reminder.dueDate.day,
        9, // 9 AM
      ),
    );
  }

  int get overdueCount => overdueReminders.length;
  int get todayCount => todayReminders.length;
  int get upcomingCount => upcomingReminders.length;

  double getTotalUpcomingAmount() {
    return _reminders
        .where((r) => !r.isCompleted && r.amount != null)
        .fold(0.0, (sum, r) => sum + r.amount!);
  }

  List<Reminder> getRemindersByType(ReminderType type) {
    return _reminders.where((r) => r.type == type).toList();
  }

  List<Reminder> getRemindersForDateRange(DateTime start, DateTime end) {
    return _reminders
        .where((r) =>
            r.dueDate.isAfter(start.subtract(const Duration(days: 1))) &&
            r.dueDate.isBefore(end.add(const Duration(days: 1))))
        .toList();
  }
}