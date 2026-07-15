import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/subject.dart';

class DatabaseHelper {
  // Singleton instance
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  // Get database instance
  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('attendance.db');
    return _database!;
  }

  // Initialize database
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();

    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  // Create all tables
  Future _createDB(Database db, int version) async {

    await db.execute('''
      CREATE TABLE subjects(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        subject_name TEXT NOT NULL,
        subject_code TEXT NOT NULL,
        section TEXT NOT NULL,
        room_no TEXT NOT NULL,
        year TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE students(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        student_name TEXT NOT NULL,
        usn TEXT NOT NULL,
      )
    ''');

    await db.execute('''
  CREATE TABLE subject_students(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    subject_id INTEGER NOT NULL,
    student_id INTEGER NOT NULL
  )
''');


    await db.execute('''
      CREATE TABLE attendance(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        student_id INTEGER NOT NULL,
        subject_id INTEGER NOT NULL,
        date TEXT NOT NULL,
        status INTEGER NOT NULL
      )
    ''');
  }

  // Close database
  Future close() async {
    final db = await instance.database;

    db.close();
  }
}