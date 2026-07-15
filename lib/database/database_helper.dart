import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/student.dart';
import '../models/subject.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) {
      await _ensureSchema(_database!);
      return _database!;
    }

    _database = await _initDB('attendance.db');
    await _ensureSchema(_database!);
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
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
        usn TEXT NOT NULL UNIQUE,
        semester INTEGER NOT NULL,
        section TEXT NOT NULL,
        year TEXT NOT NULL
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

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    await _ensureSchema(db);
  }

  Future<void> _ensureSchema(Database db) async {
    final tableInfo = await db.rawQuery('PRAGMA table_info(students)');
    final existingColumns = tableInfo
        .map((column) => column['name'] as String)
        .toSet();

    if (!existingColumns.contains('semester')) {
      await db.execute(
        'ALTER TABLE students ADD COLUMN semester INTEGER NOT NULL DEFAULT 1',
      );
    }

    if (!existingColumns.contains('section')) {
      await db.execute(
        'ALTER TABLE students ADD COLUMN section TEXT NOT NULL DEFAULT "A"',
      );
    }

    if (!existingColumns.contains('year')) {
      await db.execute(
        'ALTER TABLE students ADD COLUMN year TEXT NOT NULL DEFAULT "1st Year"',
      );
    }
  }

  Future<int> insertSubject(Subject subject) async {
    final db = await instance.database;

    return db.insert(
      'subjects',
      subject.toMap(),
    );
  }

  Future<List<Subject>> getAllSubjects() async {
    final db = await instance.database;
    final result = await db.query('subjects');

    return result.map((e) => Subject.fromMap(e)).toList();
  }

  Future<int> updateSubject(Subject subject) async {
    final db = await instance.database;

    return db.update(
      'subjects',
      subject.toMap(),
      where: 'id = ?',
      whereArgs: [subject.id],
    );
  }

  Future<int> deleteSubject(int id) async {
    final db = await instance.database;

    return db.delete(
      'subjects',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> insertStudent(Student student) async {
    final db = await instance.database;

    return db.insert(
      'students',
      student.toMap(),
    );
  }

  Future<Student?> getStudentByUsn(String usn) async {
    final db = await instance.database;

    final result = await db.query(
      'students',
      where: 'usn = ?',
      whereArgs: [usn],
      limit: 1,
    );

    if (result.isEmpty) return null;
    return Student.fromMap(result.first);
  }

  Future<List<Student>> getAllStudents() async {
    final db = await instance.database;
    final result = await db.query('students');

    return result.map((e) => Student.fromMap(e)).toList();
  }

  Future<int> updateStudent(Student student) async {
    final db = await instance.database;

    return db.update(
      'students',
      student.toMap(),
      where: 'id = ?',
      whereArgs: [student.id],
    );
  }

  Future<int> deleteStudent(int id) async {
    final db = await instance.database;

    return db.delete(
      'students',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> insertSubjectStudent(int subjectId, int studentId) async {
    final db = await instance.database;

    return db.insert(
      'subject_students',
      {
        'subject_id': subjectId,
        'student_id': studentId,
      },
    );
  }

  Future<List<Student>> getStudentsBySubject(int subjectId) async {
    final db = await instance.database;

    final result = await db.rawQuery(
      '''
      SELECT s.id, s.student_name, s.usn, s.semester, s.section, s.year
      FROM students s
      INNER JOIN subject_students ss ON s.id = ss.student_id
      WHERE ss.subject_id = ?
      ORDER BY s.student_name ASC
      ''',
      [subjectId],
    );

    return result.map((e) => Student.fromMap(e)).toList();
  }

  Future<List<Map<String, dynamic>>> getAttendanceBySubject(int subjectId) async {
    final db = await instance.database;

    return db.rawQuery(
      '''
      SELECT
        students.student_name,
        students.usn,
        attendance.date,
        attendance.status
      FROM attendance
      INNER JOIN students ON students.id = attendance.student_id
      WHERE attendance.subject_id = ?
      ORDER BY attendance.date DESC
      ''',
      [subjectId],
    );
  }

  Future<int> insertAttendance({
    required int studentId,
    required int subjectId,
    required String date,
    required int status,
  }) async {
    final db = await instance.database;

    return db.insert(
      'attendance',
      {
        'student_id': studentId,
        'subject_id': subjectId,
        'date': date,
        'status': status,
      },
    );
  }

  Future<int> deleteAttendanceBySubjectAndDate({
    required int subjectId,
    required String date,
  }) async {
    final db = await instance.database;

    return db.delete(
      'attendance',
      where: 'subject_id = ? AND date = ?',
      whereArgs: [subjectId, date],
    );
  }

  Future<int> removeStudentFromSubject(int subjectId, int studentId) async {
    final db = await instance.database;

    return db.delete(
      'subject_students',
      where: 'subject_id = ? AND student_id = ?',
      whereArgs: [subjectId, studentId],
    );
  }

  Future<void> close() async {
    final db = await instance.database;
    await db.close();
  }
}