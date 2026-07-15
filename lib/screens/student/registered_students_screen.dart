import 'package:flutter/material.dart';
import '../../database/database_helper.dart';
import '../../models/student.dart';


class RegisteredStudentsScreen extends StatefulWidget {

  const RegisteredStudentsScreen({super.key});


  @override
  State<RegisteredStudentsScreen> createState() =>
      _RegisteredStudentsScreenState();

}



class _RegisteredStudentsScreenState
    extends State<RegisteredStudentsScreen> {


  List<Student> students = [];


  @override
  void initState() {

    super.initState();

    loadStudents();

  }



  Future<void> loadStudents() async {

    final data =
        await DatabaseHelper.instance.getAllStudents();


    setState(() {

      students = data;

    });

  }



  @override
  Widget build(BuildContext context) {


    return Scaffold(

      backgroundColor: const Color(0xFFF7F7F7),


      appBar: AppBar(

        title: const Text(
          "Registered Students",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        backgroundColor: const Color(0xFFD63384),

        foregroundColor: Colors.white,

        centerTitle: true,

      ),



      body: students.isEmpty

          ? const Center(

              child: Text(
                "No Students Added",
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.grey,
                ),
              ),

            )


          : ListView.builder(

              padding: const EdgeInsets.all(20),

              itemCount: students.length,


              itemBuilder: (context,index){


                final student = students[index];


                return Card(

                  elevation: 4,

                  margin: const EdgeInsets.only(
                    bottom:15,
                  ),


                  shape: RoundedRectangleBorder(

                    borderRadius:
                    BorderRadius.circular(18),

                  ),



                  child: Padding(

                    padding:
                    const EdgeInsets.all(18),



                    child: Column(

                      crossAxisAlignment:
                      CrossAxisAlignment.start,


                      children: [


                        Text(

                          student.studentName,

                          style: const TextStyle(

                            fontSize:22,

                            fontWeight:
                            FontWeight.bold,

                          ),

                        ),


                        const SizedBox(height:10),



                        Text(
                          "USN : ${student.usn}",
                        ),


                        Text(
                          "Semester : ${student.semester}",
                        ),


                        Text(
                          "Section : ${student.section}",
                        ),


                        Text(
                          "Year : ${student.year}",
                        ),


                      ],

                    ),

                  ),

                );


              },

            ),


    );

  }

}