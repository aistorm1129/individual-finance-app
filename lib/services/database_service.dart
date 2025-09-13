import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/expense.dart';
import '../models/category.dart';
import '../models/reminder.dart';

class DatabaseService {
  static Database? _database;
  static const String _databaseName = 'finance_tracker.db';
  static const int _databaseVersion = 1;

  static const String _expensesTable = 'expenses';
  static const String _categoriesTable = 'categories';
  static const String _remindersTable = 'reminders';

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_categoriesTable (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        icon TEXT NOT NULL,
        color INTEGER NOT NULL,
        isDefault INTEGER NOT NULL DEFAULT 0,
        budgetLimit REAL
      )
    ''');

    await db.execute('''
      CREATE TABLE $_expensesTable (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        categoryId TEXT NOT NULL,
        date INTEGER NOT NULL,
        description TEXT,
        paymentMethod INTEGER NOT NULL,
        location TEXT,
        isRecurring INTEGER NOT NULL DEFAULT 0,
        receipt TEXT,
        FOREIGN KEY (categoryId) REFERENCES $_categoriesTable (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE $_remindersTable (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        amount REAL,
        dueDate INTEGER NOT NULL,
        type INTEGER NOT NULL,
        isRecurring INTEGER NOT NULL DEFAULT 0,
        recurringDays INTEGER,
        categoryId TEXT,
        isCompleted INTEGER NOT NULL DEFAULT 0,
        completedDate INTEGER,
        FOREIGN KEY (categoryId) REFERENCES $_categoriesTable (id)
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_expenses_date ON $_expensesTable (date);
    ''');

    await db.execute('''
      CREATE INDEX idx_expenses_category ON $_expensesTable (categoryId);
    ''');

    await db.execute('''
      CREATE INDEX idx_reminders_due_date ON $_remindersTable (dueDate);
    ''');
  }

  Future<void> initializeDatabase() async {
    await database;
  }

  // Category operations
  Future<void> insertCategory(Category category) async {
    final db = await database;
    await db.insert(
      _categoriesTable,
      category.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Category>> getCategories() async {
    final db = await database;
    final maps = await db.query(_categoriesTable, orderBy: 'name ASC');
    return maps.map((map) => Category.fromMap(map)).toList();
  }

  Future<void> updateCategory(Category category) async {
    final db = await database;
    await db.update(
      _categoriesTable,
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  Future<void> deleteCategory(String id) async {
    final db = await database;
    await db.delete(
      _categoriesTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> clearAllCategories() async {
    final db = await database;
    await db.delete(_categoriesTable);
  }

  // Expense operations
  Future<void> insertExpense(Expense expense) async {
    final db = await database;
    await db.insert(
      _expensesTable,
      expense.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Expense>> getExpenses() async {
    final db = await database;
    final maps = await db.query(_expensesTable, orderBy: 'date DESC');
    return maps.map((map) => Expense.fromMap(map)).toList();
  }

  Future<List<Expense>> getExpensesByCategory(String categoryId) async {
    final db = await database;
    final maps = await db.query(
      _expensesTable,
      where: 'categoryId = ?',
      whereArgs: [categoryId],
      orderBy: 'date DESC',
    );
    return maps.map((map) => Expense.fromMap(map)).toList();
  }

  Future<List<Expense>> getExpensesByDateRange(DateTime start, DateTime end) async {
    final db = await database;
    final maps = await db.query(
      _expensesTable,
      where: 'date BETWEEN ? AND ?',
      whereArgs: [start.millisecondsSinceEpoch, end.millisecondsSinceEpoch],
      orderBy: 'date DESC',
    );
    return maps.map((map) => Expense.fromMap(map)).toList();
  }

  Future<void> updateExpense(Expense expense) async {
    final db = await database;
    await db.update(
      _expensesTable,
      expense.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  Future<void> deleteExpense(String id) async {
    final db = await database;
    await db.delete(
      _expensesTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> clearAllExpenses() async {
    final db = await database;
    await db.delete(_expensesTable);
  }

  // Reminder operations
  Future<void> insertReminder(Reminder reminder) async {
    final db = await database;
    await db.insert(
      _remindersTable,
      reminder.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Reminder>> getReminders() async {
    final db = await database;
    final maps = await db.query(_remindersTable, orderBy: 'dueDate ASC');
    return maps.map((map) => Reminder.fromMap(map)).toList();
  }

  Future<List<Reminder>> getActiveReminders() async {
    final db = await database;
    final maps = await db.query(
      _remindersTable,
      where: 'isCompleted = ?',
      whereArgs: [0],
      orderBy: 'dueDate ASC',
    );
    return maps.map((map) => Reminder.fromMap(map)).toList();
  }

  Future<List<Reminder>> getOverdueReminders() async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;
    final maps = await db.query(
      _remindersTable,
      where: 'dueDate < ? AND isCompleted = ?',
      whereArgs: [now, 0],
      orderBy: 'dueDate ASC',
    );
    return maps.map((map) => Reminder.fromMap(map)).toList();
  }

  Future<void> updateReminder(Reminder reminder) async {
    final db = await database;
    await db.update(
      _remindersTable,
      reminder.toMap(),
      where: 'id = ?',
      whereArgs: [reminder.id],
    );
  }

  Future<void> deleteReminder(String id) async {
    final db = await database;
    await db.delete(
      _remindersTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> clearAllReminders() async {
    final db = await database;
    await db.delete(_remindersTable);
  }

  // Statistics and aggregations
  Future<double> getTotalExpensesForMonth(int year, int month) async {
    final db = await database;
    final startOfMonth = DateTime(year, month, 1);
    final endOfMonth = DateTime(year, month + 1, 0, 23, 59, 59);

    final result = await db.rawQuery('''
      SELECT SUM(amount) as total
      FROM $_expensesTable
      WHERE date BETWEEN ? AND ?
    ''', [startOfMonth.millisecondsSinceEpoch, endOfMonth.millisecondsSinceEpoch]);

    return (result.first['total'] as double?) ?? 0.0;
  }

  Future<Map<String, double>> getCategoryTotals() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT categoryId, SUM(amount) as total
      FROM $_expensesTable
      GROUP BY categoryId
    ''');

    final totals = <String, double>{};
    for (final row in result) {
      totals[row['categoryId'] as String] = row['total'] as double;
    }
    return totals;
  }

  Future<List<Map<String, dynamic>>> getMonthlyTotals(int year) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT
        strftime('%m', datetime(date/1000, 'unixepoch')) as month,
        SUM(amount) as total
      FROM $_expensesTable
      WHERE strftime('%Y', datetime(date/1000, 'unixepoch')) = ?
      GROUP BY month
      ORDER BY month
    ''', [year.toString()]);

    return result;
  }

  Future<void> closeDatabase() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}