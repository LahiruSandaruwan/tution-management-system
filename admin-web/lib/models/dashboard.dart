import 'package:json_annotation/json_annotation.dart';
import 'payment.dart';

part 'dashboard.g.dart';

@JsonSerializable()
class DashboardStats {
  final StudentStats students;
  final TeacherStats teachers;
  final ClassStats classes;
  final PaymentStatistics payments;
  final AttendanceStats attendance;
  final GateStats gate;
  @JsonKey(name: 'defaulters_count')
  final int defaultersCount;

  DashboardStats({
    required this.students,
    required this.teachers,
    required this.classes,
    required this.payments,
    required this.attendance,
    required this.gate,
    required this.defaultersCount,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) =>
      _$DashboardStatsFromJson(json);
  Map<String, dynamic> toJson() => _$DashboardStatsToJson(this);
}

@JsonSerializable()
class StudentStats {
  final int total;
  final int active;
  final int inactive;

  StudentStats({
    required this.total,
    required this.active,
    required this.inactive,
  });

  factory StudentStats.fromJson(Map<String, dynamic> json) =>
      _$StudentStatsFromJson(json);
  Map<String, dynamic> toJson() => _$StudentStatsToJson(this);
}

@JsonSerializable()
class TeacherStats {
  final int total;
  final int active;
  final int inactive;

  TeacherStats({
    required this.total,
    required this.active,
    required this.inactive,
  });

  factory TeacherStats.fromJson(Map<String, dynamic> json) =>
      _$TeacherStatsFromJson(json);
  Map<String, dynamic> toJson() => _$TeacherStatsToJson(this);
}

@JsonSerializable()
class ClassStats {
  final int total;

  ClassStats({
    required this.total,
  });

  factory ClassStats.fromJson(Map<String, dynamic> json) =>
      _$ClassStatsFromJson(json);
  Map<String, dynamic> toJson() => _$ClassStatsToJson(this);
}

@JsonSerializable()
class AttendanceStats {
  @JsonKey(name: 'total_marked')
  final int totalMarked;
  final int present;
  final int absent;
  final int late;

  AttendanceStats({
    required this.totalMarked,
    required this.present,
    required this.absent,
    required this.late,
  });

  factory AttendanceStats.fromJson(Map<String, dynamic> json) =>
      _$AttendanceStatsFromJson(json);
  Map<String, dynamic> toJson() => _$AttendanceStatsToJson(this);
}

@JsonSerializable()
class GateStats {
  @JsonKey(name: 'today_entries')
  final int todayEntries;
  @JsonKey(name: 'today_exits')
  final int todayExits;
  @JsonKey(name: 'today_denied')
  final int todayDenied;
  @JsonKey(name: 'currently_inside')
  final int currentlyInside;

  GateStats({
    required this.todayEntries,
    required this.todayExits,
    required this.todayDenied,
    required this.currentlyInside,
  });

  factory GateStats.fromJson(Map<String, dynamic> json) =>
      _$GateStatsFromJson(json);
  Map<String, dynamic> toJson() => _$GateStatsToJson(this);
}

@JsonSerializable()
class DashboardResponse {
  final bool success;
  final DashboardStats? data;

  DashboardResponse({
    required this.success,
    this.data,
  });

  factory DashboardResponse.fromJson(Map<String, dynamic> json) =>
      _$DashboardResponseFromJson(json);
  Map<String, dynamic> toJson() => _$DashboardResponseToJson(this);
}
