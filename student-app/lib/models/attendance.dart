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

  Attendance({
    required this.id,
    required this.classId,
    required this.studentId,
    required this.date,
    required this.status,
    this.checkInTime,
    this.notes,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) =>
      _$AttendanceFromJson(json);
  Map<String, dynamic> toJson() => _$AttendanceToJson(this);

  bool get isPresent => status == 'present';
  bool get isAbsent => status == 'absent';
  bool get isLate => status == 'late';
}

@JsonSerializable()
class AttendanceSummary {
  @JsonKey(name: 'total_days')
  final int totalDays;
  final int present;
  final int absent;
  final int late;
  @JsonKey(name: 'attendance_percentage')
  final double attendancePercentage;

  AttendanceSummary({
    required this.totalDays,
    required this.present,
    required this.absent,
    required this.late,
    required this.attendancePercentage,
  });

  factory AttendanceSummary.fromJson(Map<String, dynamic> json) =>
      _$AttendanceSummaryFromJson(json);
  Map<String, dynamic> toJson() => _$AttendanceSummaryToJson(this);
}
