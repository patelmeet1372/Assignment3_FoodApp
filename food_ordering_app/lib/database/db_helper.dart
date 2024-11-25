import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  static Database? _database;

  // Get database instance
  static Future<Database> get getDatabase async {
    if (_database != null) return _database!;
    _database = await initDB();
    return _database!;
  }

  // Initialize database
  static Future<Database> initDB() async {
    final dbPath = await getDatabasesPath();
    return openDatabase(
      join(dbPath, 'food_ordering.db'),
      version: 2,
      onCreate: (db, version) async {
        // Create food_items table
        await db.execute('''
          CREATE TABLE food_items (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            cost REAL NOT NULL
          )
        ''');

        // Create selected_items table
        await db.execute('''
          CREATE TABLE selected_items (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date TEXT NOT NULL,
            target_cost REAL NOT NULL,
            food_name TEXT NOT NULL
          )
        ''');
      },
    );
  }

  // Debug: List database tables
  static Future<void> debugTables() async {
    final db = await getDatabase;
    final tables = await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table'");
    print('Database Tables: $tables');
  }

  // Insert food item
  static Future<void> insertFoodItem(String name, double cost) async {
    final db = await getDatabase;
    await db.insert('food_items', {'name': name, 'cost': cost});
  }

  // Update food item
  static Future<void> updateFoodItem(int id, String name, double cost) async {
    final db = await getDatabase;
    await db.update('food_items', {'name': name, 'cost': cost}, where: 'id = ?', whereArgs: [id]);
  }

  // Delete food item
  static Future<void> deleteFoodItem(int id) async {
    final db = await getDatabase;
    await db.delete('food_items', where: 'id = ?', whereArgs: [id]);
  }

  // Get all food items
  static Future<List<Map<String, dynamic>>> getFoodItems() async {
    final db = await getDatabase;
    return db.query('food_items');
  }

  // Save selected items
  static Future<void> saveSelectedItem(String date, double targetCost, String foodName) async {
    final db = await getDatabase;
    await db.insert('selected_items', {
      'date': date,
      'target_cost': targetCost,
      'food_name': foodName,
    });
  }

  // Delete a specific plan by its ID
  static Future<void> deletePlan(int id) async {
    final db = await getDatabase; // No parentheses here because it's a getter
    await db.delete(
      'selected_items', // Table name
      where: 'id = ?',  // Where clause to delete the specific ID
      whereArgs: [id],  // Arguments to replace the '?' placeholder
    );
  }

  // Get selected items by date
  static Future<List<Map<String, dynamic>>> getSelectedItemsByDate(String date) async {
    final db = await getDatabase;
    return db.query('selected_items', where: 'date = ?', whereArgs: [date]);
  }
}

