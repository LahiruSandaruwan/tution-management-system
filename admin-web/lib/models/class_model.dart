import 'package:json_annotation/json_annotation.dart';
import 'teacher.dart';
import 'student.dart';

part 'class_model.g.dart';

@JsonSerializable()
class ClassModel {
  final int id;
  final String name;
  final String? description;
  @JsonKey(name: 'subject_id')
  final int? subjectId;
  @JsonKey(name: 'teacher_id')
  final int? teacherId;
  final String? grade;
  final String? day;
  @JsonKey(name: 'start_time')
  final String? startTime;
  @JsonKey(name: 'end_time')
  final String? endTime;
  @JsonKey(name: 'monthly_fee')
  final double? monthlyFee;
  @JsonKey(name: 'max_students')
  final int? maxStudents;
  @JsonKey(name: 'is_active')
  final bool isActive;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  // Relationships
  final Teacher? teacher;
  final List<Student>? students;
  @JsonKey(name: 'students_count')
  final int? studentsCount;
  final Subject? subject;

  ClassModel({
    required this.id,
    required this.name,
    this.description,
    this.subjectId,
    this.teacherId,
    this.grade,
    this.day,
    this.startTime,
    this.endTime,
    this.monthlyFee,
    this.maxStudents,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
    this.teacher,
    this.students,
    this.studentsCount,
    this.subject,
  });

  factory ClassModel.fromJson(Map<String, dynamic> json) =>
      _$ClassModelFromJson(json);

  Map<String, dynamic> toJson() => _$ClassModelToJson(this);
}

@JsonSerializable()
class Subject {
  final int id;
  final String name;
  final String? code;
  final String? description;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  Subject({
    required this.id,
    required this.name,
    this.code,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  factory Subject.fromJson(Map<String, dynamic> json) =>
      _$SubjectFromJson(json);

  Map<String, dynamic> toJson() => _$SubjectToJson(this);
}
