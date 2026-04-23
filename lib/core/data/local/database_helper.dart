
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('ets_movil.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await _createSavedEts(db);
    await _createCareers(db);
    await _createClassrooms(db);
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createCareers(db);
      await _createClassrooms(db);
    }
  }

  Future<void> _createSavedEts(Database db) async {
    await db.execute('''
CREATE TABLE IF NOT EXISTS saved_ets (
  id TEXT PRIMARY KEY,
  subject TEXT NOT NULL,
  date TEXT NOT NULL,
  shift TEXT NOT NULL,
  classroom TEXT NOT NULL,
  professor TEXT NOT NULL,
  career TEXT NOT NULL,
  semester INTEGER NOT NULL
)
''');
  }

  Future<void> _createCareers(Database db) async {
    await db.execute('''
CREATE TABLE IF NOT EXISTS careers (
  code TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  is_active INTEGER NOT NULL DEFAULT 1
)
''');
  }

  Future<void> _createClassrooms(Database db) async {
    await db.execute('''
CREATE TABLE IF NOT EXISTS classrooms (
  id TEXT PRIMARY KEY,
  building TEXT NOT NULL,
  room TEXT NOT NULL
)
''');
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
