import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import '../models/expense.dart';
import '../models/category.dart';
import '../services/database_service.dart';

class ExpenseProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  List<Expense> _expenses = [];
  List<Category> _categories = [];
  bool _isLoading = false;

  List<Expense> get expenses => _expenses;
  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _databaseService.initializeDatabase();
      _categories = await _databaseService.getCategories();
      _expenses = await _databaseService.getExpenses();

      if (_categories.isEmpty) {
        _categories = Category.getDefaultCategories();
        for (final category in _categories) {
          await _databaseService.insertCategory(category);
        }
      }

      if (_expenses.isEmpty) {
        await _createMockupData();
      }
    } catch (e) {
      debugPrint('Error loading data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _createMockupData() async {
    final mockExpenses = [
      Expense(
        title: 'Grocery Shopping',
        amount: 85.50,
        categoryId: '1', // Food & Dining
        date: DateTime.now().subtract(const Duration(days: 1)),
        description: 'Weekly grocery shopping at supermarket',
        paymentMethod: PaymentMethod.card,
        location: 'SuperMart',
      ),
      Expense(
        title: 'Gas Station',
        amount: 45.20,
        categoryId: '2', // Transportation
        date: DateTime.now().subtract(const Duration(days: 2)),
        description: 'Fuel for the car',
        paymentMethod: PaymentMethod.card,
      ),
      Expense(
        title: 'Coffee & Snacks',
        amount: 12.75,
        categoryId: '1', // Food & Dining
        date: DateTime.now().subtract(const Duration(days: 3)),
        paymentMethod: PaymentMethod.cash,
        location: 'Starbucks',
      ),
      Expense(
        title: 'Movie Tickets',
        amount: 28.00,
        categoryId: '4', // Entertainment
        date: DateTime.now().subtract(const Duration(days: 5)),
        description: 'Weekend movie with friends',
        paymentMethod: PaymentMethod.digitalWallet,
      ),
      Expense(
        title: 'Electric Bill',
        amount: 120.30,
        categoryId: '5', // Bills & Utilities
        date: DateTime.now().subtract(const Duration(days: 7)),
        description: 'Monthly electricity bill',
        paymentMethod: PaymentMethod.transfer,
        isRecurring: true,
      ),
      Expense(
        title: 'New Shoes',
        amount: 89.99,
        categoryId: '3', // Shopping
        date: DateTime.now().subtract(const Duration(days: 10)),
        description: 'Running shoes for exercise',
        paymentMethod: PaymentMethod.card,
      ),
      Expense(
        title: 'Doctor Visit',
        amount: 150.00,
        categoryId: '6', // Health & Medical
        date: DateTime.now().subtract(const Duration(days: 12)),
        description: 'Regular checkup',
        paymentMethod: PaymentMethod.card,
      ),
      Expense(
        title: 'Online Course',
        amount: 49.99,
        categoryId: '7', // Education
        date: DateTime.now().subtract(const Duration(days: 15)),
        description: 'Flutter development course',
        paymentMethod: PaymentMethod.card,
      ),
      Expense(
        title: 'Restaurant Dinner',
        amount: 65.80,
        categoryId: '1', // Food & Dining
        date: DateTime.now().subtract(const Duration(days: 18)),
        description: 'Anniversary dinner',
        paymentMethod: PaymentMethod.card,
        location: 'Italian Bistro',
      ),
      Expense(
        title: 'Haircut',
        amount: 35.00,
        categoryId: '9', // Personal Care
        date: DateTime.now().subtract(const Duration(days: 20)),
        paymentMethod: PaymentMethod.cash,
      ),
    ];

    for (final expense in mockExpenses) {
      await _databaseService.insertExpense(expense);
      _expenses.add(expense);
    }
  }

  Future<void> addExpense(Expense expense) async {
    await _databaseService.insertExpense(expense);
    _expenses.add(expense);
    _expenses.sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();
  }

  Future<void> updateExpense(Expense expense) async {
    await _databaseService.updateExpense(expense);
    final index = _expenses.indexWhere((e) => e.id == expense.id);
    if (index != -1) {
      _expenses[index] = expense;
      _expenses.sort((a, b) => b.date.compareTo(a.date));
      notifyListeners();
    }
  }

  Future<void> deleteExpense(String id) async {
    await _databaseService.deleteExpense(id);
    _expenses.removeWhere((expense) => expense.id == id);
    notifyListeners();
  }

  Future<void> addCategory(Category category) async {
    await _databaseService.insertCategory(category);
    _categories.add(category);
    notifyListeners();
  }

  Future<void> updateCategory(Category category) async {
    await _databaseService.updateCategory(category);
    final index = _categories.indexWhere((c) => c.id == category.id);
    if (index != -1) {
      _categories[index] = category;
      notifyListeners();
    }
  }

  Future<void> deleteCategory(String id) async {
    final hasExpenses = _expenses.any((expense) => expense.categoryId == id);
    if (hasExpenses) {
      throw Exception('Cannot delete category with existing expenses');
    }

    await _databaseService.deleteCategory(id);
    _categories.removeWhere((category) => category.id == id);
    notifyListeners();
  }

  Future<void> clearAllData() async {
    await _databaseService.clearAllExpenses();
    await _databaseService.clearAllCategories();
    _expenses.clear();
    _categories.clear();

    _categories = Category.getDefaultCategories();
    for (final category in _categories) {
      await _databaseService.insertCategory(category);
    }

    notifyListeners();
  }

  Category? getCategoryById(String id) {
    return _categories.firstWhereOrNull((category) => category.id == id);
  }

  double getMonthlyTotal(DateTime month) {
    return _expenses
        .where((expense) =>
            expense.date.year == month.year && expense.date.month == month.month)
        .fold(0, (sum, expense) => sum + expense.amount);
  }

  double getDailyTotal(DateTime date) {
    return _expenses
        .where((expense) =>
            expense.date.year == date.year &&
            expense.date.month == date.month &&
            expense.date.day == date.day)
        .fold(0, (sum, expense) => sum + expense.amount);
  }

  List<Expense> getExpensesInDateRange(DateTime start, DateTime end) {
    return _expenses
        .where((expense) =>
            expense.date.isAfter(start.subtract(const Duration(days: 1))) &&
            expense.date.isBefore(end.add(const Duration(days: 1))))
        .toList();
  }

  Category? getMostSpentCategory() {
    if (_expenses.isEmpty || _categories.isEmpty) return null;

    final categoryTotals = <String, double>{};
    for (final expense in _expenses) {
      categoryTotals[expense.categoryId] =
          (categoryTotals[expense.categoryId] ?? 0) + expense.amount;
    }

    if (categoryTotals.isEmpty) return null;

    final topCategoryId = categoryTotals.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;

    return getCategoryById(topCategoryId);
  }

  Map<String, double> getCategoryTotals() {
    final totals = <String, double>{};
    for (final expense in _expenses) {
      totals[expense.categoryId] = (totals[expense.categoryId] ?? 0) + expense.amount;
    }
    return totals;
  }

  List<Expense> getRecentExpenses({int limit = 5}) {
    final sortedExpenses = [..._expenses]..sort((a, b) => b.date.compareTo(a.date));
    return sortedExpenses.take(limit).toList();
  }

  List<String> suggestCategories(String title) {
    final lowercaseTitle = title.toLowerCase();
    final suggestions = <String>[];

    for (final category in _categories) {
      if (category.name.toLowerCase().contains(lowercaseTitle) ||
          _isRelatedToCategory(lowercaseTitle, category)) {
        suggestions.add(category.id);
      }
    }

    if (suggestions.isEmpty) {
      return [_categories.last.id]; // Return "Other" category
    }

    return suggestions.take(3).toList();
  }

  bool _isRelatedToCategory(String title, Category category) {
    final keywords = {
      '1': ['food', 'restaurant', 'grocery', 'coffee', 'lunch', 'dinner', 'eat'],
      '2': ['gas', 'fuel', 'uber', 'taxi', 'bus', 'train', 'transport'],
      '3': ['shop', 'buy', 'store', 'clothes', 'shoes', 'purchase'],
      '4': ['movie', 'game', 'party', 'fun', 'entertainment', 'music'],
      '5': ['bill', 'electric', 'water', 'internet', 'phone', 'rent'],
      '6': ['doctor', 'hospital', 'medicine', 'health', 'pharmacy'],
      '7': ['book', 'course', 'school', 'education', 'learning'],
      '8': ['flight', 'hotel', 'travel', 'vacation', 'trip'],
      '9': ['salon', 'spa', 'beauty', 'haircut', 'personal'],
    };

    final categoryKeywords = keywords[category.id] ?? [];
    return categoryKeywords.any((keyword) => title.contains(keyword));
  }
}