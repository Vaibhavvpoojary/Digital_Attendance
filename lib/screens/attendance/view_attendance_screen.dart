import 'package:flutter/material.dart';

class ViewAttendanceScreen extends StatelessWidget {
  final String subjectName;

  const ViewAttendanceScreen({
    super.key,
    required this.subjectName,
  });

  final List<Map<String, dynamic>> students = const [
    {
      "name": "Vaibhav Poojary",
      "present": 18,
      "absent": 2,
    },
    {
      "name": "Rahul Kumar",
      "present": 15,
      "absent": 5,
    },
    {
      "name": "Akash Shetty",
      "present": 20,
      "absent": 0,
    },
    {
      "name": "Rohan",
      "present": 17,
      "absent": 3,
    },
    {
      "name": "Pranav",
      "present": 19,
      "absent": 1,
    },
  ];

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

            const SizedBox(height: 5),

            const Text(
              "Total Classes Conducted : 20",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: ListView.builder(
                itemCount: students.length,

                itemBuilder: (context, index) {

                  final student = students[index];

                  int present = student["present"];
                  int absent = student["absent"];

                  int total = present + absent;

                  double percentage =
                      (present / total) * 100;

                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.only(bottom: 15),

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),

                    child: Padding(
                      padding: const EdgeInsets.all(15),

                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,

                        children: [

                          Text(
                            student["name"],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 10),

                          LinearProgressIndicator(
                            value: percentage / 100,
                            minHeight: 8,
                            borderRadius:
                                BorderRadius.circular(20),
                            color: Colors.green,
                            backgroundColor:
                                Colors.grey.shade300,
                          ),

                          const SizedBox(height: 10),

                          Text(
                            "Attendance : ${percentage.toStringAsFixed(0)}%",
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          const SizedBox(height: 5),

                          Text("Present : $present"),

                          Text("Absent : $absent"),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}