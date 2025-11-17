import 'package:json_annotation/json_annotation.dart';
import 'user.dart';

part 'teacher.g.dart';

@JsonSerializable()
class Teacher {
  final int id;
  @JsonKey(name: 'user_id')
  final int userId;
  @JsonKey(name: 'institute_id')
  final int instituteId;
  @JsonKey(name: 'employee_id')
  final String employeeId;
  final String specialization;
  final String? qualification;
  @JsonKey(name: 'date_of_joining')
  final String? dateOfJoining;
  @JsonKey(name: 'is_active')
  final bool isActive;
  final User? user;

  Teacher({
    required this.id,
    required this.userId,
    required this.instituteId,
    required this.employeeId,
    required this.specialization,
    this.qualification,
    this.dateOfJoining,
    required this.isActive,
    this.user,
  });

  factory Teacher.fromJson(Map<String, dynamic> json) =>
      _$TeacherFromJson(json);
  Map<String, dynamic> toJson() => _$TeacherToJson(this);

  String get displayName => user?.name ?? 'Unknown';
  String get email => user?.email ?? 'N/A';
  String get phone => user?.phone ?? 'N/A';
}

@JsonSerializable()
class TeacherResponse {
  final bool success;
  final String? message;
  final Teacher? data;

  TeacherResponse({
    required this.success,
    this.message,
    this.data,
  });

  factory TeacherResponse.fromJson(Map<String, dynamic> json) =>
      _$TeacherResponseFromJson(json);
  Map<String, dynamic> toJson() => _$TeacherResponseToJson(this);
}

@JsonSerializable()
class TeacherListResponse {
  final bool success;
  final List<Teacher>? data;

  TeacherListResponse({
    required this.success,
    this.data,
  });

  factory TeacherListResponse.fromJson(Map<String, dynamic> json) =>
      _$TeacherListResponseFromJson(json);
  Map<String, dynamic> toJson() => _$TeacherListResponseToJson(this);
}
