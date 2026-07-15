import 'package:flutter/material.dart';

import '../../database/database_helper.dart';
import '../../models/student.dart';

class RegisteredStudentsScreen extends StatefulWidget {
  final int? subjectId;

  const RegisteredStudentsScreen({super.key, this.subjectId});

  @override
  State<RegisteredStudentsScreen> createState() =>
      _RegisteredStudentsScreenState();
}

class _RegisteredStudentsScreenState extends State<RegisteredStudentsScreen> {
  final TextEditingController searchController = TextEditingController();

  List<Student> students = [];
  List<Student> filteredStudents = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadStudents();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> loadStudents() async {
    final loadedStudents = widget.subjectId == null
        ? await DatabaseHelper.instance.getAllStudents()
        : await DatabaseHelper.instance.getStudentsBySubject(widget.subjectId!);

    if (!mounted) return;

    setState(() {
      students = loadedStudents;
      filteredStudents = _filterStudents(searchController.text);
      isLoading = false;
    });
  }

  List<Student> _filterStudents(String query) {
    final searchText = query.trim().toLowerCase();

    if (searchText.isEmpty) {
      return List<Student>.from(students);
    }

    return students.where((student) {
      return student.usn.toLowerCase().startsWith(searchText);
    }).toList();
  }

  void _onSearchChanged(String query) {
    setState(() {
      filteredStudents = _filterStudents(query);
    });
  }

  void _clearSearch() {
    searchController.clear();
    _onSearchChanged('');
  }

  Widget _buildEmptyState({required bool noStudentsAdded}) {
    final icon = noStudentsAdded ? Icons.people_outline : Icons.search_off;
    final message = noStudentsAdded ? 'No Students Added' : 'No Student Found';

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
            children: [
              Icon(
                icon,
                size: 50,
                color: const Color(0xFFD63384),
              ),
              const SizedBox(height: 14),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStudentCard(Student student) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              student.studentName,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text('USN : ${student.usn}'),
            Text('Semester : ${student.semester}'),
            Text('Section : ${student.section}'),
            Text('Year : ${student.year}'),
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
        title: const Text(
          'Registered Students',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFD63384),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFD63384),
              ),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
                  child: TextField(
                    controller: searchController,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Search by USN',
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Color(0xFFD63384),
                      ),
                      suffixIcon: searchController.text.isEmpty
                          ? null
                          : IconButton(
                              onPressed: _clearSearch,
                              icon: const Icon(
                                Icons.clear,
                                color: Color(0xFFD63384),
                              ),
                            ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(18)),
                        borderSide: BorderSide(
                          color: Color(0xFFD63384),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: students.isEmpty
                      ? _buildEmptyState(noStudentsAdded: true)
                      : filteredStudents.isEmpty
                          ? _buildEmptyState(noStudentsAdded: false)
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                              itemCount: filteredStudents.length,
                              itemBuilder: (context, index) {
                                final student = filteredStudents[index];
                                return _buildStudentCard(student);
                              },
                            ),
                ),
              ],
            ),
    );
  }
}
