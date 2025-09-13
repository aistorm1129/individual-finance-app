import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    await requestPermissions();
  }

  static Future<void> requestPermissions() async {
    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    await _notifications
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'finance_tracker',
      'Finance Tracker',
      channelDescription: 'Notifications for Finance Tracker app',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(id, title, body, details, payload: payload);
  }

  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    // Don't schedule notifications for past dates
    if (scheduledDate.isBefore(DateTime.now())) {
      return;
    }

    const androidDetails = AndroidNotificationDetails(
      'finance_tracker_reminders',
      'Payment Reminders',
      channelDescription: 'Reminders for bill payments and subscriptions',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final scheduledTz = tz.TZDateTime.from(scheduledDate, tz.local);

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      scheduledTz,
      details,
      payload: payload,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static Future<void> scheduleRepeatingNotification({
    required int id,
    required String title,
    required String body,
    required RepeatInterval repeatInterval,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'finance_tracker_recurring',
      'Recurring Reminders',
      channelDescription: 'Recurring reminders for regular payments',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.periodicallyShow(
      id,
      title,
      body,
      repeatInterval,
      details,
      payload: payload,
    );
  }

  static Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  static Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  static void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap
    // You can navigate to specific screens based on the payload
    final payload = response.payload;
    if (payload != null) {
      // Handle different types of notifications based on payload
      // For example, navigate to reminders screen or specific reminder
    }
  }

  static Future<void> showReminderNotification({
    required String reminderId,
    required String title,
    required String description,
    double? amount,
  }) async {
    final body = amount != null
        ? '$description - \$${amount.toStringAsFixed(2)}'
        : description;

    await showNotification(
      id: reminderId.hashCode,
      title: title,
      body: body,
      payload: 'reminder:$reminderId',
    );
  }

  static Future<void> scheduleReminderNotification({
    required String reminderId,
    required String title,
    required String description,
    required DateTime dueDate,
    double? amount,
  }) async {
    final body = amount != null
        ? '$description - \$${amount.toStringAsFixed(2)}'
        : description;

    // Schedule notification 2 hours before due date
    final notificationTime = dueDate.subtract(const Duration(hours: 2));

    await scheduleNotification(
      id: reminderId.hashCode,
      title: 'Upcoming: $title',
      body: body,
      scheduledDate: notificationTime,
      payload: 'reminder:$reminderId',
    );

    // Schedule notification on due date
    final dueDateNotification = DateTime(
      dueDate.year,
      dueDate.month,
      dueDate.day,
      9, // 9 AM
    );

    await scheduleNotification(
      id: reminderId.hashCode + 1000000, // Different ID
      title: 'Due Today: $title',
      body: body,
      scheduledDate: dueDateNotification,
      payload: 'reminder:$reminderId',
    );
  }
}