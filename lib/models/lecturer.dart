class Lecturer {

  final int? id;
  final String name;
  final String email;
  final String phone;
  final String college;
  final String department;
  final String designation;
  final String employeeId;


  Lecturer({
    this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.college,
    required this.department,
    required this.designation,
    required this.employeeId,
  });


  Map<String, dynamic> toMap() {

    return {

      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'college': college,
      'department': department,
      'designation': designation,
      'employee_id': employeeId,

    };

  }


  factory Lecturer.fromMap(Map<String, dynamic> map) {

    return Lecturer(

      id: map['id'],

      name: map['name'],

      email: map['email'],

      phone: map['phone'],

      college: map['college'],

      department: map['department'],

      designation: map['designation'],

      employeeId: map['employee_id'],

    );

  }

}