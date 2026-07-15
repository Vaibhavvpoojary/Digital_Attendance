class Student {
  int? id;
  String studentName;
  String usn;
  int semester;
  String section;
  String year;

  Student({
    this.id,
    required this.studentName,
    required this.usn,
    required this.semester,
    required this.section,
    required this.year,
  });


  // Convert Student object into Map for SQLite
  Map<String, dynamic> toMap() {

    return {

      'id': id,

      'student_name': studentName,

      'usn': usn,

      'semester': semester,

      'section': section,

      'year': year,

    };
  }



  // Convert SQLite Map into Student object
  factory Student.fromMap(Map<String, dynamic> map) {

    return Student(

      id: map['id'],

      studentName: map['student_name'],

      usn: map['usn'],

      semester: map['semester'],

      section: map['section'],

      year: map['year'],

    );
  }
}