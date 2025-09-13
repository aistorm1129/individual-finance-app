import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class Category {
  final String id;
  final String name;
  final String icon;
  final Color color;
  final bool isDefault;
  final double? budgetLimit;

  Category({
    String? id,
    required this.name,
    required this.icon,
    required this.color,
    this.isDefault = false,
    this.budgetLimit,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'color': color.value,
      'isDefault': isDefault ? 1 : 0,
      'budgetLimit': budgetLimit,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      name: map['name'],
      icon: map['icon'],
      color: Color(map['color']),
      isDefault: map['isDefault'] == 1,
      budgetLimit: map['budgetLimit']?.toDouble(),
    );
  }

  Category copyWith({
    String? name,
    String? icon,
    Color? color,
    bool? isDefault,
    double? budgetLimit,
  }) {
    return Category(
      id: id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isDefault: isDefault ?? this.isDefault,
      budgetLimit: budgetLimit ?? this.budgetLimit,
    );
  }

  static List<Category> getDefaultCategories() {
    return [
      Category(
        id: '1',
        name: 'Food & Dining',
        icon: '🍽️',
        color: Colors.orange,
        isDefault: true,
      ),
      Category(
        id: '2',
        name: 'Transportation',
        icon: '🚗',
        color: Colors.blue,
        isDefault: true,
      ),
      Category(
        id: '3',
        name: 'Shopping',
        icon: '🛍️',
        color: Colors.purple,
        isDefault: true,
      ),
      Category(
        id: '4',
        name: 'Entertainment',
        icon: '🎬',
        color: Colors.pink,
        isDefault: true,
      ),
      Category(
        id: '5',
        name: 'Bills & Utilities',
        icon: '💡',
        color: Colors.red,
        isDefault: true,
      ),
      Category(
        id: '6',
        name: 'Health & Medical',
        icon: '🏥',
        color: Colors.green,
        isDefault: true,
      ),
      Category(
        id: '7',
        name: 'Education',
        icon: '📚',
        color: Colors.indigo,
        isDefault: true,
      ),
      Category(
        id: '8',
        name: 'Travel',
        icon: '✈️',
        color: Colors.teal,
        isDefault: true,
      ),
      Category(
        id: '9',
        name: 'Personal Care',
        icon: '💄',
        color: Colors.deepPurple,
        isDefault: true,
      ),
      Category(
        id: '10',
        name: 'Other',
        icon: '📦',
        color: Colors.grey,
        isDefault: true,
      ),
    ];
  }
}