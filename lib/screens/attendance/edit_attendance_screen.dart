import 'package:flutter/material.dart';

import '../../database/database_helper.dart';

class EditAttendanceScreen extends StatefulWidget {
  final int subjectId;
  final String selectedDate;
  final List<Map<String, dynamic>> attendanceRecords;

  const EditAttendanceScreen({
    super.key,
    required this.subjectId,
    required this.selectedDate,
    this.attendanceRecords = const [],
  });

  @override
  State<EditAttendanceScreen> createState() => _EditAttendanceScreenState();
}

class _EditAttendanceScreenState extends State<EditAttendanceScreen> {
  late Future<List<Map<String, dynamic>>> attendanceFuture;
  String? subjectName;
  final Map<int, int> currentStatusByAttendanceId = {};
  final Map<int, int> originalStatusByAttendanceId = {};

  @override
  void initState() {
    super.initState();
    attendanceFuture = _loadAttendance();
  }

  Future<List<Map<String, dynamic>>> _loadAttendance() async {
    subjectName = await DatabaseHelper.instance.getSubjectNameById(widget.subjectId);

    final shouldUsePassedRecords = widget.attendanceRecords.isNotEmpty &&
        widget.attendanceRecords.every(
          (record) => record['attendance_id'] != null,
        );

    final records = shouldUsePassedRecords
        ? widget.attendanceRecords
        : await DatabaseHelper.instance.getAttendanceBySubjectAndDate(
            subjectId: widget.subjectId,
            date: widget.selectedDate,
          );

    for (final record in records) {
      final attendanceId = record['attendance_id'] as int?;
      final status = record['status'] as int?;

      if (attendanceId != null && status != null) {
        currentStatusByAttendanceId[attendanceId] = status;
        originalStatusByAttendanceId[attendanceId] = status;
      }
    }

    return records;
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

  Future<void> _saveChanges(List<Map<String, dynamic>> records) async {
    try {
      final modifiedRecords = records.where((record) {
        final attendanceId = record['attendance_id'] as int?;
        if (attendanceId == null) return false;
        return currentStatusByAttendanceId[attendanceId] != originalStatusByAttendanceId[attendanceId];
      }).toList();

      for (final record in modifiedRecords) {
        final attendanceId = record['attendance_id'] as int?;
        if (attendanceId == null) continue;

        final status = currentStatusByAttendanceId[attendanceId] ?? 0;
        await DatabaseHelper.instance.updateAttendanceStatus(attendanceId, status);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Attendance Updated Successfully'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update attendance: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildStudentCard(Map<String, dynamic> record) {
    final attendanceId = record['attendance_id'] as int?;
    final studentName = record['student_name']?.toString() ?? '';
    final usn = record['usn']?.toString() ?? '';

    if (attendanceId == null) return const SizedBox.shrink();

    final selectedStatus = currentStatusByAttendanceId[attendanceId] ?? 0;

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              studentName,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'USN\n$usn',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Text('Present'),
                    selected: selectedStatus == 1,
                    selectedColor: const Color(0xFFD63384),
                    labelStyle: TextStyle(
                      color: selectedStatus == 1 ? Colors.white : Colors.black,
                    ),
                    onSelected: (_) {
                      setState(() {
                        currentStatusByAttendanceId[attendanceId] = 1;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ChoiceChip(
                    label: const Text('Absent'),
                    selected: selectedStatus == 0,
                    selectedColor: const Color(0xFFD63384),
                    labelStyle: TextStyle(
                      color: selectedStatus == 0 ? Colors.white : Colors.black,
                    ),
                    onSelected: (_) {
                      setState(() {
                        currentStatusByAttendanceId[attendanceId] = 0;
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Attendance'),
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
                  'Failed to load edit attendance data.',
                  style: TextStyle(
                    color: Colors.red.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }

            final records = snapshot.data ?? [];
            final displayedSubjectName = subjectName ?? 'Subject';

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayedSubjectName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  _formatDateLabel(widget.selectedDate),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: records.isEmpty
                      ? Center(
                          child: Text(
                            'No attendance records found for this date.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: records.length,
                          itemBuilder: (context, index) {
                            return _buildStudentCard(records[index]);
                          },
                        ),
                ),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () => _saveChanges(records),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD63384),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
                      'SAVE CHANGES',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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