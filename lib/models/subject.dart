class Subject {
  int? id;
  String subjectName;
  String subjectCode;
  String section;
  String roomNo;
  String year;
  int? lecturerId;

  Subject({
    this.id,
    required this.subjectName,
    required this.subjectCode,
    required this.section,
    required this.roomNo,
    required this.year,
    required this.lecturerId,
  });

  // Convert Subject object to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subject_name': subjectName,
      'subject_code': subjectCode,
      'section': section,
      'room_no': roomNo,
      'year': year,
      'lecturer_id': lecturerId,

    };
  }

  // Convert Map to Subject object
  factory Subject.fromMap(Map<String, dynamic> map) {
    return Subject(
      id: map['id'],
      subjectName: map['subject_name'],
      subjectCode: map['subject_code'],
      section: map['section'],
      roomNo: map['room_no'],
      year: map['year'],
      lecturerId: map['lecturer_id'],
    );
  }
}