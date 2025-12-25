import 'package:json_annotation/json_annotation.dart';
import 'student.dart';

part 'attendance.g.dart';

@JsonSerializable()
class Attendance {
  final int id;
  @JsonKey(name: 'student_id')
  final int studentId;
  @JsonKey(name: 'class_id')
  final int classId;
  final String date;
  final String status; // present, absent, late
  final String? remarks;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  // Relationships
  final Student? student;

  Attendance({
    required this.id,
    required this.studentId,
    required this.classId,
    required this.date,
    required this.status,
    this.remarks,
    this.createdAt,
    this.updatedAt,
    this.student,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) =>
      _$AttendanceFromJson(json);

  Map<String, dynamic> toJson() => _$AttendanceToJson(this);
}

@JsonSerializable()
class AttendanceSummary {
  @JsonKey(name: 'total_classes')
  final int totalClasses;
  @JsonKey(name: 'present_count')
  final int presentCount;
  @JsonKey(name: 'absent_count')
  final int absentCount;
  @JsonKey(name: 'late_count')
  final int lateCount;
  @JsonKey(name: 'attendance_percentage')
  final double attendancePercentage;

  AttendanceSummary({
    required this.totalClasses,
    required this.presentCount,
    required this.absentCount,
    required this.lateCount,
    required this.attendancePercentage,
  });

  factory AttendanceSummary.fromJson(Map<String, dynamic> json) =>
      _$AttendanceSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$AttendanceSummaryToJson(this);
}

@JsonSerializable()
class ClassAttendanceReport {
  @JsonKey(name: 'class_name')
  final String className;
  final String date;
  @JsonKey(name: 'total_students')
  final int totalStudents;
  @JsonKey(name: 'present_count')
  final int presentCount;
  @JsonKey(name: 'absent_count')
  final int absentCount;
  @JsonKey(name: 'late_count')
  final int lateCount;
  @JsonKey(name: 'attendance_percentage')
  final double attendancePercentage;
  final List<Attendance> attendances;

  ClassAttendanceReport({
    required this.className,
    required this.date,
    required this.totalStudents,
    required this.presentCount,
    required this.absentCount,
    required this.lateCount,
    required this.attendancePercentage,
    required this.attendances,
  });

  factory ClassAttendanceReport.fromJson(Map<String, dynamic> json) =>
      _$ClassAttendanceReportFromJson(json);

  Map<String, dynamic> toJson() => _$ClassAttendanceReportToJson(this);
}
