import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LecturerProfileScreen extends StatefulWidget {
  const LecturerProfileScreen({super.key});

  @override
  State<LecturerProfileScreen> createState() =>
      _LecturerProfileScreenState();
}

class _LecturerProfileScreenState
    extends State<LecturerProfileScreen> {

  String lecturerName = "";
  String designation = "";
  String email = "";
  String phone = "";
  String college = "";
  String department = "";
  String employeeId = "";

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      lecturerName = prefs.getString("name") ?? "";
      designation = prefs.getString("designation") ?? "";
      email = prefs.getString("email") ?? "";
      phone = prefs.getString("phone") ?? "";
      college = prefs.getString("college") ?? "";
      department = prefs.getString("department") ?? "";
      employeeId = prefs.getString("employeeId") ?? "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),

      appBar: AppBar(
        title: const Text("My Profile"),
        centerTitle: true,
        backgroundColor: const Color(0xFFD63384),
        foregroundColor: Colors.white,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 30,
                ),
                child: Column(
                  children: [

                    const CircleAvatar(
                      radius: 55,
                      backgroundColor: Color(0xFFD63384),
                      child: Icon(
                        Icons.person,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 20),

                    Text(
                      lecturerName.isEmpty
                          ? "Lecturer Name"
                          : lecturerName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD63384).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        designation.isEmpty
                            ? "Designation"
                            : designation,
                        style: const TextStyle(
                          color: Color(0xFFD63384),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),

                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

                        Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [

                    ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFFFFE4F1),
                        child: Icon(
                          Icons.email,
                          color: Color(0xFFD63384),
                        ),
                      ),
                      title: const Text(
                        "Email",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        email.isEmpty ? "Not Available" : email,
                      ),
                    ),

                    const Divider(),

                    ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFFFFE4F1),
                        child: Icon(
                          Icons.phone,
                          color: Color(0xFFD63384),
                        ),
                      ),
                      title: const Text(
                        "Phone Number",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        phone.isEmpty ? "Not Available" : phone,
                      ),
                    ),

                    const Divider(),

                    ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFFFFE4F1),
                        child: Icon(
                          Icons.school,
                          color: Color(0xFFD63384),
                        ),
                      ),
                      title: const Text(
                        "College",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        college.isEmpty ? "Not Available" : college,
                      ),
                    ),

                    const Divider(),

                    ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFFFFE4F1),
                        child: Icon(
                          Icons.account_tree,
                          color: Color(0xFFD63384),
                        ),
                      ),
                      title: const Text(
                        "Department",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        department.isEmpty ? "Not Available" : department,
                      ),
                    ),

                    const Divider(),

                    ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFFFFE4F1),
                        child: Icon(
                          Icons.badge,
                          color: Color(0xFFD63384),
                        ),
                      ),
                      title: const Text(
                        "Employee ID",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        employeeId.isEmpty ? "Not Available" : employeeId,
                      ),
                    ),

                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

                        SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: Navigate to Edit Profile Screen
                },
                icon: const Icon(
                  Icons.edit,
                  color: Colors.white,
                ),
                label: const Text(
                  "EDIT PROFILE",
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

            const SizedBox(height: 15),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Logout will be available in Version 2.0",
                      ),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.logout,
                  color: Color(0xFFD63384),
                ),
                label: const Text(
                  "LOGOUT",
                  style: TextStyle(
                    color: Color(0xFFD63384),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(
                    color: Color(0xFFD63384),
                    width: 2,
                  ),
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
    );
  }
}