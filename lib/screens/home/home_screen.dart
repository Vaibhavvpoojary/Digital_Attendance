import 'package:flutter/material.dart';
import '../subject/add_subject_screen.dart';
import '../student/add_student_screen.dart';
import '../subject/subject_details_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [

              //================ HEADER =================//

              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(
                  top: 25,
                  left: 20,
                  right: 20,
                  bottom: 30,
                ),

                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFFFF5FA2),
                      Color(0xFFD63384),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),

                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(35),
                    bottomRight: Radius.circular(35),
                  ),
                ),

                child: Row(
                  children: [

                    CircleAvatar(
                      radius: 35,
                      backgroundColor: Colors.white,
                      child: Text(
                        "VP",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFD63384),
                        ),
                      ),
                    ),

                    const SizedBox(width: 15),

                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          Text(
                            "Welcome 👋",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 15,
                            ),
                          ),

                          SizedBox(height: 5),

                          Text(
                            "Vaibhav Poojary",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          SizedBox(height: 5),

                          Text(
                            "vaibhav@gmail.com",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              //================ SUBJECT TITLE =================//

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Your Subjects",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              //================ EMPTY STATE =================//

              //Padding(
                //padding: const EdgeInsets.symmetric(horizontal: 20),

                //child: Card(
                  //elevation: 5,
                  //shape: RoundedRectangleBorder(
                    //borderRadius: BorderRadius.circular(20),
                  //),

                 // child: Padding(
                   // padding: const EdgeInsets.all(30),

                   // child: Column(
                     // children: [

                       // Icon(
                         // Icons.menu_book_rounded,
                         // size: 90,
                         // color: Colors.grey.shade400,
                       // ),

                        //const SizedBox(height: 20),

                        //const Text(
                         // "No Registered Subjects",
                          //style: TextStyle(
                           // fontSize: 22,
                          //  fontWeight: FontWeight.bold,
                          //),
                       // ),

                       // const SizedBox(height: 12),

                       // const Text(
                         // "Register your first subject\nand start taking attendance.",
                         // textAlign: TextAlign.center,
                          //style: TextStyle(
                           // fontSize: 16,
                          //  color: Colors.grey,
                         // ),
                       // ),
                     // ],
                    //),
                 // ),
               // ),
            //  ),

             // const SizedBox(height: 35),

              //================ TEST SUBJECT =================//

Padding(
  padding: const EdgeInsets.symmetric(horizontal: 20),

  child: GestureDetector(

    onTap: () {

      Navigator.push(
        context,

        MaterialPageRoute(

          builder: (context) => SubjectDetailsScreen(
            subjectName: "Machine Learning",

            subjectCode: "21AIML402",

            section: "A",

            roomNo: "302",

            year: "3rd Year",

          ),

        ),
      );

    },


    child: Card(

      elevation: 5,

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),


      child: Padding(

        padding: const EdgeInsets.all(20),


        child: Column(

          crossAxisAlignment: CrossAxisAlignment.start,


          children: [

            const Text(

              "Machine Learning",

              style: TextStyle(

                fontSize: 22,

                fontWeight: FontWeight.bold,

              ),

            ),


            const SizedBox(height: 12),


            const Text(
              "Code : 21AIML402",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),


            const SizedBox(height: 8),


            const Text(
              "Section : A",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),


            const SizedBox(height: 8),


            const Text(
              "Room No : 302",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),

          ],
        ),
      ),
    ),
  ),
),

              //================ QUICK ACTIONS =================//

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Quick Actions",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),

                child: SizedBox(
                  width: double.infinity,
                  height: 55,

                  child: ElevatedButton.icon(

                    onPressed: () {
                     Navigator.push(context,MaterialPageRoute(
                     builder: (context) => const AddSubjectScreen(),),
                     );
                     },

                    icon: const Icon(
                      Icons.add,
                      color: Colors.white,
                    ),

                    label: const Text(
                      "Add Subject",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
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
              ),

              const SizedBox(height: 18),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),

                child: SizedBox(
                  width: double.infinity,
                  height: 55,

                  child: OutlinedButton.icon(

                    onPressed: () {
Navigator.push( context,MaterialPageRoute(builder: (context) => const AddStudentScreen(),),
);
                    },

                    icon: const Icon(
                      Icons.person_add,
                      color: Color(0xFFD63384),
                    ),

                    label: const Text(
                      "Add Student",
                      style: TextStyle(
                        color: Color(0xFFD63384),
                        fontSize: 18,
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
              ),

              const SizedBox(height: 35),

            ],
          ),
        ),
      ),
    );
  }
}