import 'package:flutter/material.dart';

import '../../database/database_helper.dart';
import 'edit_attendance_screen.dart';
import 'student_statistics_screen.dart';

enum AttendanceFilter {
  all,
  week,
  month,
  custom,
}

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
  AttendanceFilter selectedFilter = AttendanceFilter.all;
  DateTimeRange? customDateRange;

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

  DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  DateTime? _parseAttendanceDate(Map<String, dynamic> record) {
    final dateValue = record['date']?.toString();
    if (dateValue == null || dateValue.isEmpty) return null;

    final parsedDate = DateTime.tryParse(dateValue);
    if (parsedDate == null) return null;

    return _dateOnly(parsedDate);
  }

  bool _isDateInThisWeek(DateTime date) {
    final today = _dateOnly(DateTime.now());
    final weekStart = today.subtract(const Duration(days: 6));
    return !date.isBefore(weekStart) && !date.isAfter(today);
  }

  bool _isDateInThisMonth(DateTime date) {
    final today = DateTime.now();
    return date.year == today.year && date.month == today.month;
  }

  bool _isDateInCustomRange(DateTime date) {
    final range = customDateRange;
    if (range == null) return false;

    final start = _dateOnly(range.start);
    final end = _dateOnly(range.end);
    return !date.isBefore(start) && !date.isAfter(end);
  }

  bool _shouldShowRecord(Map<String, dynamic> record) {
    final attendanceDate = _parseAttendanceDate(record);
    if (attendanceDate == null) return false;

    switch (selectedFilter) {
      case AttendanceFilter.all:
        return true;
      case AttendanceFilter.week:
        return _isDateInThisWeek(attendanceDate);
      case AttendanceFilter.month:
        return _isDateInThisMonth(attendanceDate);
      case AttendanceFilter.custom:
        return _isDateInCustomRange(attendanceDate);
    }
  }

  List<Map<String, dynamic>> _filterAttendanceRecords(
    List<Map<String, dynamic>> records,
  ) {
    return records.where(_shouldShowRecord).toList();
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

  void _openStudentStatisticsScreen(Map<String, dynamic> record) async {
    final subjectId = await _resolveSubjectId();
    final studentId = record['student_id'] as int?;

    if (!mounted || subjectId == null || studentId == null) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StudentStatisticsScreen(
          subjectId: subjectId,
          studentId: studentId,
        ),
      ),
    );
  }

  String _formatFilterSubtitle() {
    if (selectedFilter != AttendanceFilter.custom || customDateRange == null) {
      return '';
    }

    final start = MaterialLocalizations.of(context).formatMediumDate(
      customDateRange!.start,
    );
    final end = MaterialLocalizations.of(context).formatMediumDate(
      customDateRange!.end,
    );

    return '$start - $end';
  }

  Future<void> _selectCustomDateRange() async {
    final pickedRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDateRange: customDateRange,
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

    if (pickedRange == null || !mounted) {
      return;
    }

    setState(() {
      selectedFilter = AttendanceFilter.custom;
      customDateRange = pickedRange;
    });
  }

  void _applyFilter(AttendanceFilter filter) {
    if (filter == AttendanceFilter.custom) {
      _selectCustomDateRange();
      return;
    }

    setState(() {
      selectedFilter = filter;
    });
  }

  Widget _buildFilterChip({
    required String label,
    required AttendanceFilter filter,
  }) {
    final isSelected = selectedFilter == filter;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => _applyFilter(filter),
      selectedColor: const Color(0xFFD63384),
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black87,
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? const Color(0xFFD63384) : Colors.grey.shade300,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(
                Icons.calendar_month_outlined,
                size: 52,
                color: Color(0xFFD63384),
              ),
              SizedBox(height: 14),
              Text(
                'No Attendance Records Found',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openEditAttendanceScreen({
    required String selectedDate,
    required List<Map<String, dynamic>> attendanceRecords,
  }) async {
    final subjectId = await _resolveSubjectId();

    if (!mounted || subjectId == null) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditAttendanceScreen(
          subjectId: subjectId,
          selectedDate: selectedDate,
          attendanceRecords: attendanceRecords,
        ),
      ),
    );

    if (!mounted) return;

    setState(() {
      attendanceFuture = _loadAttendance();
    });
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
                        InkWell(
                          onTap: () => _openStudentStatisticsScreen(student),
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Text(
                              student['student_name']?.toString() ?? '',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFD63384),
                              ),
                            ),
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
            final filteredRecords = _filterAttendanceRecords(records);
            final groupedAttendance = _groupAttendanceByDate(filteredRecords);
            final filterSubtitle = _formatFilterSubtitle();

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
                  'Total Attendance Records : ${filteredRecords.length}',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 20),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip(
                        label: 'All Attendance',
                        filter: AttendanceFilter.all,
                      ),
                      const SizedBox(width: 10),
                      _buildFilterChip(
                        label: 'This Week',
                        filter: AttendanceFilter.week,
                      ),
                      const SizedBox(width: 10),
                      _buildFilterChip(
                        label: 'This Month',
                        filter: AttendanceFilter.month,
                      ),
                      const SizedBox(width: 10),
                      _buildFilterChip(
                        label: 'Custom',
                        filter: AttendanceFilter.custom,
                      ),
                    ],
                  ),
                ),
                if (filterSubtitle.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    filterSubtitle,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const SizedBox(height: 18),
                Expanded(
                  child: groupedAttendance.isEmpty
                      ? _buildEmptyState()
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
                                  const SizedBox(height: 20),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 50,
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        _openEditAttendanceScreen(
                                          selectedDate: group['date'] as String,
                                          attendanceRecords: groupRecords,
                                        );
                                      },
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Colors.white,
                                      ),
                                      label: const Text(
                                        'Edit Attendance',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFFD63384),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(15),
                                        ),
                                      ),
                                    ),
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