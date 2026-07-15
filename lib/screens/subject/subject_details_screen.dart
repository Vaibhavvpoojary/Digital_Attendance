import 'package:flutter/material.dart';

import '../attendance/take_attendance_screen.dart';
import '../attendance/view_attendance_screen.dart';
import '../student/add_student_screen.dart';
import '../student/remove_student_screen.dart';

class SubjectDetailsScreen extends StatelessWidget {
  final int subjectId;
  final String subjectName;
  final String subjectCode;
  final String section;
  final String roomNo;
  final String year;

  const SubjectDetailsScreen({
    super.key,
    required this.subjectId,
    required this.subjectName,
    required this.subjectCode,
    required this.section,
    required this.roomNo,
    required this.year,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: const Text(
          "Subject Details",
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
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subjectName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  detailRow("Subject Code", subjectCode),
                  detailRow("Section", section),
                  detailRow("Room No", roomNo),
                  detailRow("Year", year),
                ],
              ),
            ),
            const SizedBox(height: 30),
            actionButton(
              context,
              title: "Add Student",
              icon: Icons.person_add,
              color: const Color(0xFFD63384),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddStudentScreen(
                      subjectId: subjectId,
                      subjectName: subjectName,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 15),
            actionButton(
              context,
              title: "Take Attendance",
              icon: Icons.fact_check,
              color: Colors.green,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TakeAttendanceScreen(
                      subjectId: subjectId,
                      subjectName: subjectName,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 15),
            actionButton(
              context,
              title: "View Attendance",
              icon: Icons.bar_chart,
              color: Colors.blue,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ViewAttendanceScreen(
                      subjectName: subjectName,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 15),
            actionButton(
              context,
              title: "Remove Student",
              icon: Icons.person_remove,
              color: Colors.red,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RemoveStudentScreen(
                      subjectId: subjectId,
                      subjectName: subjectName,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget detailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget actionButton(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}