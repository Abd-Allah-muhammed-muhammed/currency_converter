import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// Database helper class for managing SQLite database operations.
///
/// This class follows the singleton pattern to ensure only one
/// database connection is used throughout the application.
class DatabaseHelper {
  DatabaseHelper._();

  static final DatabaseHelper instance = DatabaseHelper._();
  static Database? _database;

  /// Database name.
  static const String _databaseName = 'currency_converter.db';

  /// Database version.
  static const int _databaseVersion = 1;

  /// Table names.
  static const String tableCurrencies = 'currencies';

  /// Column names for currencies table.
  static const String columnCode = 'code';
  static const String columnName = 'name';
  static const String columnFlagUrl = 'flag_url';

  /// Gets the database instance, creating it if necessary.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initializes the database.
  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Creates the database tables.
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableCurrencies (
        $columnCode TEXT PRIMARY KEY,
        $columnName TEXT NOT NULL,
        $columnFlagUrl TEXT
      )
    ''');
  }

  /// Handles database upgrades.
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle future migrations here
  }

  /// Inserts multiple currencies into the database.
  Future<void> insertCurrencies(List<Map<String, dynamic>> currencies) async {
    final db = await database;
    final batch = db.batch();

    for (final currency in currencies) {
      batch.insert(
        tableCurrencies,
        currency,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  /// Gets all currencies from the database.
  Future<List<Map<String, dynamic>>> getCurrencies() async {
    final db = await database;
    return await db.query(tableCurrencies, orderBy: '$columnName ASC');
  }

  /// Gets a single currency by code.
  Future<Map<String, dynamic>?> getCurrencyByCode(String code) async {
    final db = await database;
    final result = await db.query(
      tableCurrencies,
      where: '$columnCode = ?',
      whereArgs: [code],
      limit: 1,
    );
    return result.isNotEmpty ? result.first : null;
  }

  /// Checks if currencies exist in the database.
  Future<bool> hasCurrencies() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM $tableCurrencies');
    final count = Sqflite.firstIntValue(result) ?? 0;
    return count > 0;
  }

  /// Deletes all currencies from the database.
  Future<void> deleteAllCurrencies() async {
    final db = await database;
    await db.delete(tableCurrencies);
  }

  /// Closes the database connection.
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
