import 'package:uuid/uuid.dart';

enum ReminderType { billPayment, subscription, custom }

class Reminder {
  final String id;
  final String title;
  final String? description;
  final double? amount;
  final DateTime dueDate;
  final ReminderType type;
  final bool isRecurring;
  final int? recurringDays;
  final String? categoryId;
  final bool isCompleted;
  final DateTime? completedDate;

  Reminder({
    String? id,
    required this.title,
    this.description,
    this.amount,
    required this.dueDate,
    required this.type,
    this.isRecurring = false,
    this.recurringDays,
    this.categoryId,
    this.isCompleted = false,
    this.completedDate,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'amount': amount,
      'dueDate': dueDate.millisecondsSinceEpoch,
      'type': type.index,
      'isRecurring': isRecurring ? 1 : 0,
      'recurringDays': recurringDays,
      'categoryId': categoryId,
      'isCompleted': isCompleted ? 1 : 0,
      'completedDate': completedDate?.millisecondsSinceEpoch,
    };
  }

  factory Reminder.fromMap(Map<String, dynamic> map) {
    return Reminder(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      amount: map['amount']?.toDouble(),
      dueDate: DateTime.fromMillisecondsSinceEpoch(map['dueDate']),
      type: ReminderType.values[map['type']],
      isRecurring: map['isRecurring'] == 1,
      recurringDays: map['recurringDays'],
      categoryId: map['categoryId'],
      isCompleted: map['isCompleted'] == 1,
      completedDate: map['completedDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['completedDate'])
          : null,
    );
  }

  Reminder copyWith({
    String? title,
    String? description,
    double? amount,
    DateTime? dueDate,
    ReminderType? type,
    bool? isRecurring,
    int? recurringDays,
    String? categoryId,
    bool? isCompleted,
    DateTime? completedDate,
  }) {
    return Reminder(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      dueDate: dueDate ?? this.dueDate,
      type: type ?? this.type,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringDays: recurringDays ?? this.recurringDays,
      categoryId: categoryId ?? this.categoryId,
      isCompleted: isCompleted ?? this.isCompleted,
      completedDate: completedDate ?? this.completedDate,
    );
  }

  bool get isOverdue => DateTime.now().isAfter(dueDate) && !isCompleted;
  bool get isDueToday => dueDate.day == DateTime.now().day &&
      dueDate.month == DateTime.now().month &&
      dueDate.year == DateTime.now().year;
}