import 'package:flutter/material.dart';

class TakeAttendanceScreen extends StatefulWidget {

  final String subjectName;

  const TakeAttendanceScreen({
    super.key,
    required this.subjectName,
  });


  @override
  State<TakeAttendanceScreen> createState() => _TakeAttendanceScreenState();

}



class _TakeAttendanceScreenState extends State<TakeAttendanceScreen> {


  // Dummy students for testing

  List<String> students = [

    "Vaibhav Poojary",
    "Rahul Kumar",
    "Akash Shetty",
    "Rohan",
    "Pranav"

  ];


  // Attendance status

  Map<String,bool?> attendance = {};



  @override
  void initState(){

    super.initState();


    for(var student in students){

      attendance[student] = null;

    }

  }



  @override
  Widget build(BuildContext context) {


    return Scaffold(

      backgroundColor: const Color(0xFFF7F7F7),


      appBar: AppBar(

        title: const Text(
          "Take Attendance",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        backgroundColor: Colors.white,

        foregroundColor: Colors.black,

        elevation:0,

      ),



      body: Padding(

        padding: const EdgeInsets.all(20),


        child: Column(

          crossAxisAlignment: CrossAxisAlignment.start,


          children: [



            // Subject details

            Text(

              widget.subjectName,

              style: const TextStyle(

                fontSize:24,

                fontWeight:FontWeight.bold,

              ),

            ),



            const SizedBox(height:5),



            Text(

              "Total Students : ${students.length}",

              style: const TextStyle(

                color:Colors.grey,

                fontSize:16,

              ),

            ),



            const SizedBox(height:20),



            Expanded(

              child: ListView.builder(

                itemCount: students.length,


                itemBuilder:(context,index){


                  String student = students[index];



                  return Card(

                    elevation:3,

                    margin:const EdgeInsets.only(bottom:15),


                    shape:RoundedRectangleBorder(

                      borderRadius:BorderRadius.circular(15),

                    ),



                    child: Padding(

                      padding:const EdgeInsets.all(15),


                      child: Row(


                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,


                        children:[



                          Text(

                            student,

                            style:const TextStyle(

                              fontSize:17,

                              fontWeight:FontWeight.w600,

                            ),

                          ),



                          Row(

                            children:[



                              // Present Button

                              ChoiceChip(

                                label:const Text("P"),

                                selected:
                                attendance[student] == true,


                                onSelected:(value){

                                  setState((){

                                    attendance[student]=true;

                                  });

                                },

                              ),



                              const SizedBox(width:8),



                              // Absent Button

                              ChoiceChip(

                                label:const Text("A"),

                                selected:
                                attendance[student] == false,


                                onSelected:(value){

                                  setState((){

                                    attendance[student]=false;

                                  });

                                },

                              ),



                            ],

                          )

                        ],

                      ),

                    ),

                  );

                },

              ),

            ),



            SizedBox(

              width:double.infinity,

              height:55,


              child:ElevatedButton(

                onPressed:(){


                  print(attendance);


                  ScaffoldMessenger.of(context)
                  .showSnackBar(

                    const SnackBar(

                      content:Text(
                        "Attendance Saved Successfully"
                      ),

                    ),

                  );


                },


                style:ElevatedButton.styleFrom(

                  backgroundColor:
                  const Color(0xFFD63384),


                  shape:RoundedRectangleBorder(

                    borderRadius:BorderRadius.circular(15),

                  ),

                ),


                child:const Text(

                  "Save Attendance",

                  style:TextStyle(

                    color:Colors.white,

                    fontSize:18,

                    fontWeight:FontWeight.bold,

                  ),

                ),

              ),

            )


          ],

        ),

      ),

    );

  }

}