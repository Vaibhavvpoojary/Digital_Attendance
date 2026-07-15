import 'package:flutter/material.dart';

import '../../database/database_helper.dart';
import '../../models/student.dart';

class AddStudentScreen extends StatefulWidget {
  final int subjectId;
  final String subjectName;

  const AddStudentScreen({
    super.key,
    required this.subjectId,
    required this.subjectName,
  });

  @override
  State<AddStudentScreen> createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController usnController = TextEditingController();
  final TextEditingController semesterController = TextEditingController();
  final TextEditingController yearController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  String? selectedSection;

  final List<String> sections = [
    "A",
    "B",
    "C",
    "D",
  ];

  void updateYear(String semester) {
    if (semester == "1" || semester == "2") {
      yearController.text = "1st Year";
    } else if (semester == "3" || semester == "4") {
      yearController.text = "2nd Year";
    } else if (semester == "5" || semester == "6") {
      yearController.text = "3rd Year";
    } else if (semester == "7" || semester == "8") {
      yearController.text = "4th Year";
    } else {
      yearController.clear();
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    usnController.dispose();
    semesterController.dispose();
    yearController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future<void> _registerStudent() async {
    if (nameController.text.isEmpty ||
        usnController.text.isEmpty ||
        semesterController.text.isEmpty ||
        selectedSection == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all the required fields."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final trimmedUsn = usnController.text.trim();
    final student = Student(
      studentName: nameController.text.trim(),
      usn: trimmedUsn,
      semester: int.parse(semesterController.text.trim()),
      section: selectedSection!,
      year: yearController.text.trim(),
    );

    try {
      final existingStudent = await DatabaseHelper.instance.getStudentByUsn(trimmedUsn);

      final int studentId;

      if (existingStudent == null) {
        studentId = await DatabaseHelper.instance.insertStudent(student);
      } else {
        final updatedStudent = Student(
          id: existingStudent.id,
          studentName: student.studentName,
          usn: student.usn,
          semester: student.semester,
          section: student.section,
          year: student.year,
        );

        await DatabaseHelper.instance.updateStudent(updatedStudent);
        studentId = existingStudent.id!;
      }

      await DatabaseHelper.instance.insertSubjectStudent(
        widget.subjectId,
        studentId,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Student Registered Successfully!"),
          backgroundColor: Colors.green,
        ),
      );

      nameController.clear();
      usnController.clear();
      semesterController.clear();
      yearController.clear();
      emailController.clear();
      phoneController.clear();

      setState(() {
        selectedSection = null;
      });
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to register student: $error"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD63384),
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text("Add Student"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.school,
                  size: 80,
                  color: Color(0xFFD63384),
                ),
                const SizedBox(height: 15),
                const Center(
                  child: Text(
                    "Register Student",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDE7F1),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: const Color(0xFFD63384)),
                  ),
                  child: Text(
                    "Subject: ${widget.subjectName}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFD63384),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: "Student Name",
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: usnController,
                  decoration: InputDecoration(
                    labelText: "USN",
                    prefixIcon: const Icon(Icons.badge),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: semesterController,
                  keyboardType: TextInputType.number,
                  maxLength: 1,
                  decoration: InputDecoration(
                    labelText: "Semester",
                    hintText: "Enter Semester (1-8)",
                    prefixIcon: const Icon(Icons.school),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    counterText: "",
                  ),
                  onChanged: (value) {
                    updateYear(value);
                  },
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: yearController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: "Year",
                    prefixIcon: const Icon(Icons.calendar_today),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  initialValue: selectedSection,
                  decoration: InputDecoration(
                    labelText: "Section",
                    prefixIcon: const Icon(Icons.groups),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  items: sections.map((section) {
                    return DropdownMenuItem(
                      value: section,
                      child: Text("Section $section"),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedSection = value;
                    });
                  },
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: "Student Email (Optional)",
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  decoration: InputDecoration(
                    labelText: "Phone Number (Optional)",
                    prefixIcon: const Icon(Icons.phone),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    counterText: "",
                  ),
                ),
                const SizedBox(height: 35),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    onPressed: _registerStudent,
                    icon: const Icon(
                      Icons.person_add,
                      color: Colors.white,
                    ),
                    label: const Text(
                      "REGISTER STUDENT",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
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
          ),
        ),
      ),
    );
  }
}