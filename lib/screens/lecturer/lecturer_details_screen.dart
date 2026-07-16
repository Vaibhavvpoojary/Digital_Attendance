import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../home/home_screen.dart';
import '../../database/database_helper.dart';
import '../../models/lecturer.dart';

class LecturerDetailsScreen extends StatefulWidget {
  const LecturerDetailsScreen({super.key});

  @override
  State<LecturerDetailsScreen> createState() =>
      _LecturerDetailsScreenState();
}

class _LecturerDetailsScreenState
    extends State<LecturerDetailsScreen> {

  final TextEditingController nameController =
      TextEditingController();

  final TextEditingController emailController =
      TextEditingController();

  final TextEditingController phoneController =
      TextEditingController();

  final TextEditingController collegeController =
      TextEditingController();

  final TextEditingController employeeIdController =
      TextEditingController();

  String? selectedDepartment;

  String? selectedDesignation;

  final List<String> departments = [
    "Computer Science",
    "Artificial Intelligence & Machine Learning",
    "Information Science",
    "Electronics & Communication",
    "Electrical & Electronics",
    "Mechanical",
    "Civil",
  ];

  final List<String> designations = [
    "Assistant Professor",
    "Associate Professor",
    "Professor",
    "Head of Department",
    "Guest Faculty",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),

      appBar: AppBar(
        backgroundColor: const Color(0xFFD63384),
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text("Lecturer Details"),
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
                  Icons.person,
                  size: 90,
                  color: Color(0xFFD63384),
                ),

                const SizedBox(height: 15),

                const Center(
                  child: Text(
                    "Complete Your Profile",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                const Center(
                  child: Text(
                    "This information is required only once.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 15,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Lecturer Name

                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: "Lecturer Name",
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Email

                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: "Email Address",
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Phone Number

                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: "Mobile Number",
                    prefixIcon: const Icon(Icons.phone),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // College Name

                TextField(
                  controller: collegeController,
                  decoration: InputDecoration(
                    labelText: "College Name",
                    prefixIcon: const Icon(Icons.school),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Department

                DropdownButtonFormField<String>(
                  value: selectedDepartment,
                  decoration: InputDecoration(
                    labelText: "Department",
                    prefixIcon: const Icon(Icons.account_tree),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  items: departments.map((department) {
                    return DropdownMenuItem(
                      value: department,
                      child: Text(department),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedDepartment = value;
                    });
                  },
                ),

                const SizedBox(height: 20),

                                // Designation

                DropdownButtonFormField<String>(
                  value: selectedDesignation,
                  decoration: InputDecoration(
                    labelText: "Designation",
                    prefixIcon: const Icon(Icons.work),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  items: designations.map((designation) {
                    return DropdownMenuItem(
                      value: designation,
                      child: Text(designation),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedDesignation = value;
                    });
                  },
                ),

                const SizedBox(height: 20),

                // Employee ID

                TextField(
                  controller: employeeIdController,
                  decoration: InputDecoration(
                    labelText: "Employee ID",
                    prefixIcon: const Icon(Icons.badge),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),

                const SizedBox(height: 35),

                SizedBox(
                  height: 55,
                  child: ElevatedButton.icon(
                    onPressed: () async {

  // Validation

  if (nameController.text.isEmpty ||
      emailController.text.isEmpty ||
      phoneController.text.isEmpty ||
      collegeController.text.isEmpty ||
      employeeIdController.text.isEmpty ||
      selectedDepartment == null ||
      selectedDesignation == null) {

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Please fill all the fields"),
      ),
    );

    return;
  }

  // Create Lecturer object

  Lecturer lecturer = Lecturer(
    name: nameController.text,
    email: emailController.text,
    phone: phoneController.text,
    college: collegeController.text,
    department: selectedDepartment!,
    designation: selectedDesignation!,
    employeeId: employeeIdController.text,
  );

  // Save into SQLite

  int lecturerId =
      await DatabaseHelper.instance.insertLecturer(lecturer);

  // Save details in SharedPreferences

  final prefs = await SharedPreferences.getInstance();

  await prefs.setInt("lecturerId", lecturerId);

  await prefs.setString("name", lecturer.name);
  await prefs.setString("email", lecturer.email);
  await prefs.setString("phone", lecturer.phone);
  await prefs.setString("college", lecturer.college);
  await prefs.setString("department", lecturer.department);
  await prefs.setString("designation", lecturer.designation);
  await prefs.setString("employeeId", lecturer.employeeId);

  await prefs.setBool("profileCompleted", true);

  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (_) => const HomeScreen(),
    ),
  );

},

                    icon: const Icon(
                      Icons.save,
                      color: Colors.white,
                    ),

                    label: const Text(
                      "SAVE & CONTINUE",
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

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}