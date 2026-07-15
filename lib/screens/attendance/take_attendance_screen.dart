import 'package:flutter/material.dart';

import '../../database/database_helper.dart';
import '../../models/student.dart';

class TakeAttendanceScreen extends StatefulWidget {
  final int subjectId;
  final String subjectName;

  const TakeAttendanceScreen({
    super.key,
    required this.subjectId,
    required this.subjectName,
  });

  @override
  State<TakeAttendanceScreen> createState() => _TakeAttendanceScreenState();
}

class _TakeAttendanceScreenState extends State<TakeAttendanceScreen> {
  List<Student> students = [];
  final Map<int, bool?> attendance = {};
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    loadStudents();
  }

  Future<void> loadStudents() async {
    final loadedStudents = await DatabaseHelper.instance.getStudentsBySubject(
      widget.subjectId,
    );

    if (!mounted) return;

    setState(() {
      students = loadedStudents;
      attendance
        ..clear()
        ..addEntries(
          students
              .where((student) => student.id != null)
              .map((student) => MapEntry(student.id!, null)),
        );
    });
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFD63384),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && mounted) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  Future<void> _saveAttendance() async {
    if (students.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No students available for this subject.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (attendance.values.any((value) => value == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please mark all students as Present or Absent.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final dateKey = selectedDate.toIso8601String().split('T').first;

    try {
      await DatabaseHelper.instance.deleteAttendanceBySubjectAndDate(
        subjectId: widget.subjectId,
        date: dateKey,
      );

      for (final student in students) {
        final studentId = student.id;
        if (studentId == null) continue;

        await DatabaseHelper.instance.insertAttendance(
          studentId: studentId,
          subjectId: widget.subjectId,
          date: dateKey,
          status: attendance[studentId] == true ? 1 : 0,
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Attendance Saved Successfully for ${MaterialLocalizations.of(context).formatMediumDate(selectedDate)}',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save attendance: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: const Text(
          "Take Attendance",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
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
              "Total Students : ${students.length}",
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 20),
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(15),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: const Color(0xFFD63384)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_month,
                      color: Color(0xFFD63384),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Date: ${MaterialLocalizations.of(context).formatMediumDate(selectedDate)}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.arrow_drop_down,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: students.isEmpty
                  ? Center(
                      child: Text(
                        "No students have been added to this subject yet.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: students.length,
                      itemBuilder: (context, index) {
                        final student = students[index];
                        final studentId = student.id;

                        if (studentId == null) {
                          return const SizedBox.shrink();
                        }

                        return Card(
                          elevation: 3,
                          margin: const EdgeInsets.only(bottom: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        student.studentName,
                                        style: const TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        student.usn,
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    ChoiceChip(
                                      label: const Text("P"),
                                      selected: attendance[studentId] == true,
                                      onSelected: (value) {
                                        setState(() {
                                          attendance[studentId] = true;
                                        });
                                      },
                                    ),
                                    const SizedBox(width: 8),
                                    ChoiceChip(
                                      label: const Text("A"),
                                      selected: attendance[studentId] == false,
                                      onSelected: (value) {
                                        setState(() {
                                          attendance[studentId] = false;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  _saveAttendance();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD63384),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text(
                  "Save Attendance",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}