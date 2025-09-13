import 'package:uuid/uuid.dart';

enum PaymentMethod { cash, card, transfer, digitalWallet }

class Expense {
  final String id;
  final String title;
  final double amount;
  final String categoryId;
  final DateTime date;
  final String? description;
  final PaymentMethod paymentMethod;
  final String? location;
  final bool isRecurring;
  final String? receipt;

  Expense({
    String? id,
    required this.title,
    required this.amount,
    required this.categoryId,
    required this.date,
    this.description,
    this.paymentMethod = PaymentMethod.cash,
    this.location,
    this.isRecurring = false,
    this.receipt,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'categoryId': categoryId,
      'date': date.millisecondsSinceEpoch,
      'description': description,
      'paymentMethod': paymentMethod.index,
      'location': location,
      'isRecurring': isRecurring ? 1 : 0,
      'receipt': receipt,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      title: map['title'],
      amount: map['amount'].toDouble(),
      categoryId: map['categoryId'],
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      description: map['description'],
      paymentMethod: PaymentMethod.values[map['paymentMethod']],
      location: map['location'],
      isRecurring: map['isRecurring'] == 1,
      receipt: map['receipt'],
    );
  }

  Expense copyWith({
    String? title,
    double? amount,
    String? categoryId,
    DateTime? date,
    String? description,
    PaymentMethod? paymentMethod,
    String? location,
    bool? isRecurring,
    String? receipt,
  }) {
    return Expense(
      id: id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      date: date ?? this.date,
      description: description ?? this.description,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      location: location ?? this.location,
      isRecurring: isRecurring ?? this.isRecurring,
      receipt: receipt ?? this.receipt,
    );
  }
}