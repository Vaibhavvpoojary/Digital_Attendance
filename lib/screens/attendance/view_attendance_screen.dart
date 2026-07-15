import 'package:flutter/material.dart';

import '../../database/database_helper.dart';

class ViewAttendanceScreen extends StatefulWidget {
  final int? subjectId;
  final String subjectName;

  const ViewAttendanceScreen({
    super.key,
    this.subjectId,
    required this.subjectName,
  });

  @override
  State<ViewAttendanceScreen> createState() => _ViewAttendanceScreenState();
}

class _ViewAttendanceScreenState extends State<ViewAttendanceScreen> {
  late Future<List<Map<String, dynamic>>> attendanceFuture;

  @override
  void initState() {
    super.initState();
    attendanceFuture = _loadAttendance();
  }

  Future<int?> _resolveSubjectId() async {
    if (widget.subjectId != null) {
      return widget.subjectId;
    }

    final db = await DatabaseHelper.instance.database;
    final result = await db.query(
      'subjects',
      columns: ['id'],
      where: 'subject_name = ?',
      whereArgs: [widget.subjectName],
      limit: 1,
    );

    if (result.isEmpty) return null;
    return result.first['id'] as int?;
  }

  Future<List<Map<String, dynamic>>> _loadAttendance() async {
    final subjectId = await _resolveSubjectId();

    if (subjectId == null) {
      return [];
    }

    return DatabaseHelper.instance.getAttendanceBySubject(subjectId);
  }

  String _formatDateLabel(String dateValue) {
    final parsedDate = DateTime.tryParse(dateValue);
    if (parsedDate == null) return dateValue;

    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    final weekday = weekdays[parsedDate.weekday - 1];
    final month = months[parsedDate.month - 1];

    return '$weekday, ${parsedDate.day.toString().padLeft(2, '0')} $month ${parsedDate.year}';
  }

  List<Map<String, dynamic>> _groupAttendanceByDate(
    List<Map<String, dynamic>> records,
  ) {
    final grouped = <String, List<Map<String, dynamic>>>{};

    for (final record in records) {
      final dateKey = record['date']?.toString() ?? '';
      grouped.putIfAbsent(dateKey, () => []);
      grouped[dateKey]!.add(record);
    }

    return grouped.entries.map((entry) {
      final recordsForDate = entry.value;
      return {
        'date': entry.key,
        'records': recordsForDate,
        'presentCount': recordsForDate.where((record) => record['status'] == 1).length,
        'absentCount': recordsForDate.where((record) => record['status'] == 0).length,
      };
    }).toList();
  }

  List<Map<String, dynamic>> _recordsByStatus(
    List<Map<String, dynamic>> records,
    int status,
  ) {
    return records.where((record) => record['status'] == status).toList();
  }

  Widget _buildStudentSection({
    required String title,
    required List<Map<String, dynamic>> students,
    required bool isPresent,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 10),
        if (students.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'No students',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          )
        else
          ...students.map(
            (student) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isPresent ? '🟢' : '🔴',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          student['student_name']?.toString() ?? '',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'USN: ${student['usn']?.toString() ?? ''}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: const Text("View Attendance"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: attendanceFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFD63384),
                ),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Failed to load attendance data.',
                  style: TextStyle(
                    color: Colors.red.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }

            final records = snapshot.data ?? [];
            final groupedAttendance = _groupAttendanceByDate(records);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.subjectName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Total Attendance Records : ${records.length}',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: groupedAttendance.isEmpty
                      ? Center(
                          child: Text(
                            'No attendance records found for this subject.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: groupedAttendance.length,
                          itemBuilder: (context, index) {
                            final group = groupedAttendance[index];
                            final dateLabel = _formatDateLabel(group['date'] as String);
                            final groupRecords = group['records'] as List<Map<String, dynamic>>;

                            final presentStudents = _recordsByStatus(groupRecords, 1);
                            final absentStudents = _recordsByStatus(groupRecords, 0);

                            return Card(
                              elevation: 3,
                              margin: const EdgeInsets.only(bottom: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: ExpansionTile(
                                tilePadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                title: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      dateLabel,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Present: ${group['presentCount']} | Absent: ${group['absentCount']}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                children: [
                                  const Divider(height: 24),
                                  _buildStudentSection(
                                    title: '✔ PRESENT STUDENTS',
                                    students: presentStudents,
                                    isPresent: true,
                                  ),
                                  const SizedBox(height: 20),
                                  _buildStudentSection(
                                    title: '✘ ABSENT STUDENTS',
                                    students: absentStudents,
                                    isPresent: false,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}