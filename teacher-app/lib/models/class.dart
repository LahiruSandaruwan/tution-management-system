import 'package:json_annotation/json_annotation.dart';

part 'class.g.dart';

@JsonSerializable()
class TeacherClass {
  final int id;
  @JsonKey(name: 'institute_id')
  final int instituteId;
  @JsonKey(name: 'teacher_id')
  final int teacherId;
  @JsonKey(name: 'subject_id')
  final int subjectId;
  final String name;
  final String grade;
  final String? description;
  @JsonKey(name: 'monthly_fee')
  final double monthlyFee;
  @JsonKey(name: 'is_active')
  final bool isActive;
  @JsonKey(name: 'subject_name')
  final String? subjectName;
  @JsonKey(name: 'teacher_name')
  final String? teacherName;
  @JsonKey(name: 'student_count')
  final int? studentCount;

  TeacherClass({
    required this.id,
    required this.instituteId,
    required this.teacherId,
    required this.subjectId,
    required this.name,
    required this.grade,
    this.description,
    required this.monthlyFee,
    required this.isActive,
    this.subjectName,
    this.teacherName,
    this.studentCount,
  });

  factory TeacherClass.fromJson(Map<String, dynamic> json) =>
      _$TeacherClassFromJson(json);
  Map<String, dynamic> toJson() => _$TeacherClassToJson(this);
}

@JsonSerializable()
class ClassStudent {
  final int id;
  @JsonKey(name: 'user_id')
  final int userId;
  @JsonKey(name: 'student_id_number')
  final String studentIdNumber;
  final String grade;
  @JsonKey(name: 'is_active')
  final bool isActive;
  @JsonKey(name: 'user_name')
  final String? userName;
  @JsonKey(name: 'user_email')
  final String? userEmail;
  @JsonKey(name: 'user_phone')
  final String? userPhone;

  ClassStudent({
    required this.id,
    required this.userId,
    required this.studentIdNumber,
    required this.grade,
    required this.isActive,
    this.userName,
    this.userEmail,
    this.userPhone,
  });

  factory ClassStudent.fromJson(Map<String, dynamic> json) =>
      _$ClassStudentFromJson(json);
  Map<String, dynamic> toJson() => _$ClassStudentToJson(this);
}
