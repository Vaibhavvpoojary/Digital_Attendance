import 'package:flutter/material.dart';
import '../../database/database_helper.dart';
import '../../models/subject.dart';

class AddSubjectScreen extends StatefulWidget {
  const AddSubjectScreen({super.key});

  @override
  State<AddSubjectScreen> createState() => _AddSubjectScreenState();
}

class _AddSubjectScreenState extends State<AddSubjectScreen> {
  final TextEditingController subjectNameController = TextEditingController();
  final TextEditingController subjectCodeController = TextEditingController();
  final TextEditingController roomController = TextEditingController();
  final TextEditingController contactHoursController = TextEditingController();
  final TextEditingController classesPerWeekController = TextEditingController();
  final TextEditingController sectionController = TextEditingController();
  final TextEditingController yearController = TextEditingController();

  String? selectedSemester;
  String? selectedSection;
  String? selectedYear;

  final List<String> semesters = [
    "1",
    "2",
    "3",
    "4",
    "5",
    "6",
    "7",
    "8",
  ];

  void updateYear(String semester) {
    if (semester == "1" || semester == "2") {
      yearController.text = "1st Year";
    } else if (semester == "3" || semester == "4") {
      yearController.text = "2nd Year";
    } else if (semester == "5" || semester == "6") {
      yearController.text = "3rd Year";
    } else {
      yearController.text = "4th Year";
    }
  }

  @override
  void dispose() {
    subjectNameController.dispose();
    subjectCodeController.dispose();
    roomController.dispose();
    contactHoursController.dispose();
    classesPerWeekController.dispose();
    sectionController.dispose();
    yearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),

      appBar: AppBar(
        backgroundColor: const Color(0xFFD63384),
        foregroundColor: Colors.white,
        title: const Text("Register Subject"),
        centerTitle: true,
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
                  Icons.menu_book_rounded,
                  size: 80,
                  color: Color(0xFFD63384),
                ),

                const SizedBox(height: 15),

                const Center(
                  child: Text(
                    "Register Your Subject",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Subject Name

                TextField(
                  controller: subjectNameController,

                  decoration: InputDecoration(
                    labelText: "Subject Name",
                    prefixIcon: const Icon(Icons.book),

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Subject Code

                TextField(
                  controller: subjectCodeController,

                  decoration: InputDecoration(
                    labelText: "Subject Code",
                    prefixIcon: const Icon(Icons.code),

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Room Number

                TextField(
                  controller: roomController,

                  decoration: InputDecoration(
                    labelText: "Room Number",
                    prefixIcon: const Icon(Icons.meeting_room),

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                 const SizedBox(height: 20),

                // Total Contact Hours

                TextField(

                  controller: contactHoursController,

                  keyboardType: TextInputType.number,

                  decoration: InputDecoration(

                    labelText: "Total Contact Hours",

                    prefixIcon: const Icon(Icons.schedule),

                    border: OutlineInputBorder(

                      borderRadius: BorderRadius.circular(15),

                    ),

                  ),

                ),

                const SizedBox(height: 20),

                // Classes Per Week

                DropdownButtonFormField<int>(

                  decoration: InputDecoration(

                    labelText: "Classes Per Week",

                    prefixIcon: const Icon(Icons.calendar_view_week),

                    border: OutlineInputBorder(

                      borderRadius: BorderRadius.circular(15),

                    ),

                  ),

                  items: List.generate(7, (index) {

                    int value = index + 1;

                    return DropdownMenuItem(

                      value: value,

                      child: Text("$value Classes"),

                    );

                  }),

                  onChanged: (value) {

                    if (value != null) {

                      classesPerWeekController.text = value.toString();

                    }

                  },

                ),

                const SizedBox(height: 20),

                //section

                TextField(
                  controller: sectionController,

                  decoration: InputDecoration(
                    labelText: "Section",
                    prefixIcon: const Icon(Icons.group),

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),

                const SizedBox(height: 20),


                // Semester

                DropdownButtonFormField<String>(
                  value: selectedSemester,

                  decoration: InputDecoration(
                    labelText: "Semester",
                    prefixIcon: const Icon(Icons.school),

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),

                  items: semesters.map((semester) {
                    return DropdownMenuItem(
                      value: semester,
                      child: Text("Semester $semester"),
                    );
                  }).toList(),

                  onChanged: (value) {
                    setState(() {
                      selectedSemester = value;
                      if (value != null) {
                        updateYear(value);
                      }
                    });
                  },
                ),

                const SizedBox(height: 20),

                // Year

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

                const SizedBox(height: 35),

                SizedBox(
                  height: 55,

                  child: ElevatedButton.icon(

                    onPressed: () async {

  // Validation
  if (subjectNameController.text.isEmpty ||
      subjectCodeController.text.isEmpty ||
      roomController.text.isEmpty ||
      sectionController.text.isEmpty ||
      yearController.text.isEmpty) {

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Please fill all the fields"),
      ),
    );

    return;
  }

  Subject subject = Subject(
    subjectName: subjectNameController.text,
    subjectCode: subjectCodeController.text,
    section: sectionController.text,
    roomNo: roomController.text,
    year: yearController.text,
  );

  await DatabaseHelper.instance.insertSubject(subject);

ScaffoldMessenger.of(context).showSnackBar(
  const SnackBar(
    content: Text("Subject Registered Successfully"),
  ),
);

Navigator.pop(context);

},

                    icon: const Icon(
                      Icons.save,
                      color: Colors.white,
                    ),

                    label: const Text(
                      "REGISTER SUBJECT",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
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