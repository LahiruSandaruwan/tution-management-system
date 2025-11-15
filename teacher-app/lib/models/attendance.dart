import 'package:json_annotation/json_annotation.dart';

part 'attendance.g.dart';

@JsonSerializable()
class Attendance {
  final int id;
  @JsonKey(name: 'class_id')
  final int classId;
  @JsonKey(name: 'student_id')
  final int studentId;
  final String date;
  final String status;
  @JsonKey(name: 'check_in_time')
  final String? checkInTime;
  final String? notes;
  @JsonKey(name: 'student_name')
  final String? studentName;
  @JsonKey(name: 'student_id_number')
  final String? studentIdNumber;

  Attendance({
    required this.id,
    required this.classId,
    required this.studentId,
    required this.date,
    required this.status,
    this.checkInTime,
    this.notes,
    this.studentName,
    this.studentIdNumber,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) =>
      _$AttendanceFromJson(json);
  Map<String, dynamic> toJson() => _$AttendanceToJson(this);

  bool get isPresent => status == 'present';
  bool get isAbsent => status == 'absent';
  bool get isLate => status == 'late';
}

@JsonSerializable()
class AttendanceStats {
  @JsonKey(name: 'total_students')
  final int totalStudents;
  final int present;
  final int absent;
  final int late;
  @JsonKey(name: 'attendance_percentage')
  final double attendancePercentage;

  AttendanceStats({
    required this.totalStudents,
    required this.present,
    required this.absent,
    required this.late,
    required this.attendancePercentage,
  });

  factory AttendanceStats.fromJson(Map<String, dynamic> json) =>
      _$AttendanceStatsFromJson(json);
  Map<String, dynamic> toJson() => _$AttendanceStatsToJson(this);
}
