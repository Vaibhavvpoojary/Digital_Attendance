import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/lecturer.dart';
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

    _database = await _initDB("attendance.db");
    await _ensureSchema(_database!);

    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return openDatabase(
      path,
      version: 3,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {

    //---------------- LECTURERS ----------------//

    await db.execute('''
      CREATE TABLE lecturers(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL,
        phone TEXT NOT NULL,
        college TEXT NOT NULL,
        department TEXT NOT NULL,
        designation TEXT NOT NULL,
        employee_id TEXT NOT NULL
      )
    ''');

    //---------------- SUBJECTS ----------------//

    await db.execute('''
      CREATE TABLE subjects(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        subject_name TEXT NOT NULL,
        subject_code TEXT NOT NULL,
        section TEXT NOT NULL,
        room_no TEXT NOT NULL,
        year TEXT NOT NULL,
        lecturer_id INTEGER NOT NULL
      )
    ''');

    //---------------- STUDENTS ----------------//

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

    //---------------- SUBJECT STUDENTS ----------------//

    await db.execute('''
      CREATE TABLE subject_students(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        subject_id INTEGER NOT NULL,
        student_id INTEGER NOT NULL
      )
    ''');

    //---------------- ATTENDANCE ----------------//

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

  Future<void> _upgradeDB(
      Database db,
      int oldVersion,
      int newVersion,
      ) async {

    await _ensureSchema(db);
  }

  Future<void> _ensureSchema(Database db) async {

    // STUDENTS

    final studentInfo =
        await db.rawQuery("PRAGMA table_info(students)");

    final studentColumns =
        studentInfo.map((e) => e["name"] as String).toSet();

    if (!studentColumns.contains("semester")) {
      await db.execute(
        "ALTER TABLE students ADD COLUMN semester INTEGER NOT NULL DEFAULT 1",
      );
    }

    if (!studentColumns.contains("section")) {
      await db.execute(
        "ALTER TABLE students ADD COLUMN section TEXT NOT NULL DEFAULT 'A'",
      );
    }

    if (!studentColumns.contains("year")) {
      await db.execute(
        "ALTER TABLE students ADD COLUMN year TEXT NOT NULL DEFAULT '1st Year'",
      );
    }

    // SUBJECTS

    final subjectInfo =
        await db.rawQuery("PRAGMA table_info(subjects)");

    final subjectColumns =
        subjectInfo.map((e) => e["name"] as String).toSet();

    if (!subjectColumns.contains("lecturer_id")) {
      await db.execute(
        "ALTER TABLE subjects ADD COLUMN lecturer_id INTEGER NOT NULL DEFAULT 1",
      );
    }
  }

    //=========================================================
  // LECTURER METHODS
  //=========================================================

  Future<int> insertLecturer(Lecturer lecturer) async {
    final db = await instance.database;

    return await db.insert(
      'lecturers',
      lecturer.toMap(),
    );
  }

  Future<Lecturer?> getLecturerById(int id) async {
    final db = await instance.database;

    final result = await db.query(
      'lecturers',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isEmpty) return null;

    return Lecturer.fromMap(result.first);
  }

  Future<List<Lecturer>> getAllLecturers() async {
    final db = await instance.database;

    final result = await db.query(
      'lecturers',
      orderBy: 'name ASC',
    );

    return result.map((e) => Lecturer.fromMap(e)).toList();
  }

  Future<int> updateLecturer(Lecturer lecturer) async {
    final db = await instance.database;

    return db.update(
      'lecturers',
      lecturer.toMap(),
      where: 'id = ?',
      whereArgs: [lecturer.id],
    );
  }

  Future<int> deleteLecturer(int id) async {
    final db = await instance.database;

    return db.delete(
      'lecturers',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  //=========================================================
  // SUBJECT METHODS
  //=========================================================

  Future<int> insertSubject(Subject subject) async {
    final db = await instance.database;

    return db.insert(
      'subjects',
      subject.toMap(),
    );
  }

  Future<List<Subject>> getAllSubjects() async {
    final db = await instance.database;

    final result = await db.query(
      'subjects',
      orderBy: 'subject_name ASC',
    );

    return result.map((e) => Subject.fromMap(e)).toList();
  }

  Future<List<Subject>> getSubjectsByLecturer(int lecturerId) async {
    final db = await instance.database;

    final result = await db.query(
      'subjects',
      where: 'lecturer_id = ?',
      whereArgs: [lecturerId],
      orderBy: 'subject_name ASC',
    );

    return result.map((e) => Subject.fromMap(e)).toList();
  }

  Future<String?> getSubjectNameById(int subjectId) async {
    final db = await instance.database;

    final result = await db.query(
      'subjects',
      columns: ['subject_name'],
      where: 'id = ?',
      whereArgs: [subjectId],
      limit: 1,
    );

    if (result.isEmpty) return null;

    return result.first['subject_name']?.toString();
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

  Future<void> deleteAllSubjects() async {
    final db = await instance.database;

    await db.delete('subjects');
  }

    //=========================================================
  // STUDENT METHODS
  //=========================================================

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

    if (result.isEmpty) {
      return null;
    }

    return Student.fromMap(result.first);
  }

  Future<List<Student>> getAllStudents() async {
    final db = await instance.database;

    final result = await db.query(
      'students',
      orderBy: 'student_name ASC',
    );

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

  //=========================================================
  // SUBJECT - STUDENT METHODS
  //=========================================================

  Future<int> insertSubjectStudent(
    int subjectId,
    int studentId,
  ) async {
    final db = await instance.database;

    return db.insert(
      'subject_students',
      {
        'subject_id': subjectId,
        'student_id': studentId,
      },
    );
  }

  Future<List<Student>> getStudentsBySubject(
    int subjectId,
  ) async {
    final db = await instance.database;

    final result = await db.rawQuery(
      '''
      SELECT
        s.id,
        s.student_name,
        s.usn,
        s.semester,
        s.section,
        s.year
      FROM students s
      INNER JOIN subject_students ss
      ON s.id = ss.student_id
      WHERE ss.subject_id = ?
      ORDER BY s.student_name ASC
      ''',
      [subjectId],
    );

    return result.map((e) => Student.fromMap(e)).toList();
  }

  Future<int> removeStudentFromSubject(
    int subjectId,
    int studentId,
  ) async {
    final db = await instance.database;

    return db.delete(
      'subject_students',
      where: 'subject_id = ? AND student_id = ?',
      whereArgs: [subjectId, studentId],
    );
  }

    //=========================================================
  // ATTENDANCE METHODS
  //=========================================================

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

  Future<List<Map<String, dynamic>>> getAttendanceBySubject(
      int subjectId) async {
    final db = await instance.database;

    return db.rawQuery(
      '''
      SELECT
        students.id AS student_id,
        students.student_name,
        students.usn,
        attendance.date,
        attendance.status
      FROM attendance
      INNER JOIN students
      ON students.id = attendance.student_id
      WHERE attendance.subject_id = ?
      ORDER BY attendance.date DESC
      ''',
      [subjectId],
    );
  }

  Future<List<Map<String, dynamic>>> getAttendanceBySubjectAndDate({
    required int subjectId,
    required String date,
  }) async {
    final db = await instance.database;

    return db.rawQuery(
      '''
      SELECT
        attendance.id AS attendance_id,
        students.id AS student_id,
        students.student_name,
        students.usn,
        attendance.date,
        attendance.status
      FROM attendance
      INNER JOIN students
      ON students.id = attendance.student_id
      WHERE attendance.subject_id = ?
      AND attendance.date = ?
      ORDER BY students.student_name ASC
      ''',
      [subjectId, date],
    );
  }

  Future<int> updateAttendanceStatus(
    int attendanceId,
    int status,
  ) async {
    final db = await instance.database;

    return db.update(
      'attendance',
      {
        'status': status,
      },
      where: 'id = ?',
      whereArgs: [attendanceId],
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

  Future<Map<String, dynamic>?> getStudentAttendanceStatistics({
    required int subjectId,
    required int studentId,
  }) async {
    final db = await instance.database;

    final result = await db.rawQuery(
      '''
      SELECT
        s.student_name,
        s.usn,
        COUNT(a.id) AS total_classes,
        COALESCE(SUM(
          CASE
            WHEN a.status = 1 THEN 1
            ELSE 0
          END
        ),0) AS present_count,
        COALESCE(SUM(
          CASE
            WHEN a.status = 0 THEN 1
            ELSE 0
          END
        ),0) AS absent_count
      FROM students s
      LEFT JOIN attendance a
      ON s.id = a.student_id
      AND a.subject_id = ?
      WHERE s.id = ?
      GROUP BY
        s.id,
        s.student_name,
        s.usn
      LIMIT 1
      ''',
      [subjectId, studentId],
    );

    if (result.isEmpty) {
      return null;
    }

    final row = result.first;

    final totalClasses =
        (row['total_classes'] as int?) ?? 0;

    final presentCount =
        (row['present_count'] as int?) ?? 0;

    final absentCount =
        (row['absent_count'] as int?) ?? 0;

    final percentage = totalClasses == 0
        ? 0.0
        : (presentCount / totalClasses) * 100;

    return {
      "student_name": row["student_name"],
      "usn": row["usn"],
      "total_classes": totalClasses,
      "present_count": presentCount,
      "absent_count": absentCount,
      "attendance_percentage": percentage,
    };
  }

  //=========================================================
  // CLOSE DATABASE
  //=========================================================

  Future<void> close() async {
    final db = await instance.database;
    await db.close();
  }
}