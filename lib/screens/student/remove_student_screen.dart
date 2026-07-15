import 'package:flutter/material.dart';

class RemoveStudentScreen extends StatefulWidget {
  final String subjectName;

  const RemoveStudentScreen({
    super.key,
    required this.subjectName,
  });

  @override
  State<RemoveStudentScreen> createState() =>
      _RemoveStudentScreenState();
}

class _RemoveStudentScreenState extends State<RemoveStudentScreen> {

  List<String> students = [
    "Vaibhav Poojary",
    "Rahul Kumar",
    "Akash Shetty",
    "Rohan",
    "Pranav",
  ];

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),

      appBar: AppBar(
        title: const Text(
          "Remove Students",
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

            Expanded(
              child: ListView.builder(
                itemCount: students.length,

                itemBuilder: (context, index) {

                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.only(bottom: 12),

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),

                    child: ListTile(

                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFFD63384),
                        child: Icon(
                          Icons.person,
                          color: Colors.white,
                        ),
                      ),

                      title: Text(
                        students[index],
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      trailing: IconButton(

                        icon: const Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),

                        onPressed: () {

                          showDialog(
                            context: context,

                            builder: (context) {

                              return AlertDialog(

                                title: const Text("Remove Student"),

                                content: Text(
                                  "Remove ${students[index]} from this subject?",
                                ),

                                actions: [

                                  TextButton(

                                    onPressed: () {
                                      Navigator.pop(context);
                                    },

                                    child: const Text("Cancel"),

                                  ),

                                  ElevatedButton(

                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                    ),

                                    onPressed: () {

                                      setState(() {
                                        students.removeAt(index);
                                      });

                                      Navigator.pop(context);

                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(

                                        const SnackBar(
                                          content: Text(
                                            "Student Removed",
                                          ),
                                        ),

                                      );
                                    },

                                    child: const Text(
                                      "Remove",
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),

                                  ),

                                ],

                              );

                            },

                          );

                        },

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