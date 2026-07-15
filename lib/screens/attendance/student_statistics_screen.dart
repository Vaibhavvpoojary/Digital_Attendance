import 'package:flutter/material.dart';

import '../../database/database_helper.dart';

class StudentStatisticsScreen extends StatefulWidget {
  final int studentId;
  final int subjectId;

  const StudentStatisticsScreen({
    super.key,
    required this.studentId,
    required this.subjectId,
  });

  @override
  State<StudentStatisticsScreen> createState() => _StudentStatisticsScreenState();
}

class _StudentStatisticsScreenState extends State<StudentStatisticsScreen> {
  late Future<Map<String, dynamic>?> statisticsFuture;

  @override
  void initState() {
    super.initState();
    statisticsFuture = _loadStatistics();
  }

  Future<Map<String, dynamic>?> _loadStatistics() {
    return DatabaseHelper.instance.getStudentAttendanceStatistics(
      subjectId: widget.subjectId,
      studentId: widget.studentId,
    );
  }

  Color _statusColor(double attendancePercentage) {
    if (attendancePercentage >= 85) {
      return const Color(0xFF2E7D32);
    }

    if (attendancePercentage >= 75) {
      return const Color(0xFFF57C00);
    }

    return const Color(0xFFD32F2F);
  }

  String _statusLabel(double attendancePercentage) {
    if (attendancePercentage >= 85) {
      return 'Excellent';
    }

    if (attendancePercentage >= 75) {
      return 'Good';
    }

    return 'Needs Improvement';
  }

  Widget _buildSummaryCard({
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: valueColor ?? Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: const Text('Student Statistics'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: statisticsFuture,
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
                'Failed to load student statistics.',
                style: TextStyle(
                  color: Colors.red.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }

          final statistics = snapshot.data;
          if (statistics == null) {
            return Center(
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                  child: Text(
                    'No statistics available for this student.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            );
          }

          final studentName = statistics['student_name']?.toString() ?? '';
          final usn = statistics['usn']?.toString() ?? '';
          final totalClasses = (statistics['total_classes'] as int?) ?? 0;
          final presentCount = (statistics['present_count'] as int?) ?? 0;
          final absentCount = (statistics['absent_count'] as int?) ?? 0;
          final attendancePercentage =
              (statistics['attendance_percentage'] as double?) ?? 0.0;
          final progressValue = (attendancePercentage / 100).clamp(0.0, 1.0);
          final statusColor = _statusColor(attendancePercentage);
          final statusLabel = _statusLabel(attendancePercentage);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Student Name',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          studentName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'USN',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          usn,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Attendance Summary',
                  style: TextStyle(
                    color: Colors.grey.shade800,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.6,
                  children: [
                    _buildSummaryCard(
                      label: 'Total Classes',
                      value: totalClasses.toString(),
                    ),
                    _buildSummaryCard(
                      label: 'Present',
                      value: presentCount.toString(),
                      valueColor: const Color(0xFF2E7D32),
                    ),
                    _buildSummaryCard(
                      label: 'Absent',
                      value: absentCount.toString(),
                      valueColor: const Color(0xFFD32F2F),
                    ),
                    _buildSummaryCard(
                      label: 'Attendance',
                      value: '${attendancePercentage.toStringAsFixed(2)}%',
                      valueColor: statusColor,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Attendance',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${attendancePercentage.toStringAsFixed(2)}%',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: statusColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: progressValue,
                            minHeight: 10,
                            backgroundColor: Colors.grey.shade300,
                            valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          statusLabel,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Attendance Status',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          statusLabel,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
