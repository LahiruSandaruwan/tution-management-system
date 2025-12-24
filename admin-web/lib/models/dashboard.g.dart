// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DashboardStats _$DashboardStatsFromJson(Map<String, dynamic> json) =>
    DashboardStats(
      students: StudentStats.fromJson(json['students'] as Map<String, dynamic>),
      teachers: TeacherStats.fromJson(json['teachers'] as Map<String, dynamic>),
      classes: ClassStats.fromJson(json['classes'] as Map<String, dynamic>),
      payments:
          PaymentStatistics.fromJson(json['payments'] as Map<String, dynamic>),
      attendance:
          AttendanceStats.fromJson(json['attendance'] as Map<String, dynamic>),
      gate: GateStats.fromJson(json['gate'] as Map<String, dynamic>),
      defaultersCount: (json['defaulters_count'] as num).toInt(),
    );

Map<String, dynamic> _$DashboardStatsToJson(DashboardStats instance) =>
    <String, dynamic>{
      'students': instance.students,
      'teachers': instance.teachers,
      'classes': instance.classes,
      'payments': instance.payments,
      'attendance': instance.attendance,
      'gate': instance.gate,
      'defaulters_count': instance.defaultersCount,
    };

StudentStats _$StudentStatsFromJson(Map<String, dynamic> json) => StudentStats(
      total: (json['total'] as num).toInt(),
      active: (json['active'] as num).toInt(),
      inactive: (json['inactive'] as num).toInt(),
    );

Map<String, dynamic> _$StudentStatsToJson(StudentStats instance) =>
    <String, dynamic>{
      'total': instance.total,
      'active': instance.active,
      'inactive': instance.inactive,
    };

TeacherStats _$TeacherStatsFromJson(Map<String, dynamic> json) => TeacherStats(
      total: (json['total'] as num).toInt(),
      active: (json['active'] as num).toInt(),
      inactive: (json['inactive'] as num).toInt(),
    );

Map<String, dynamic> _$TeacherStatsToJson(TeacherStats instance) =>
    <String, dynamic>{
      'total': instance.total,
      'active': instance.active,
      'inactive': instance.inactive,
    };

ClassStats _$ClassStatsFromJson(Map<String, dynamic> json) => ClassStats(
      total: (json['total'] as num).toInt(),
    );

Map<String, dynamic> _$ClassStatsToJson(ClassStats instance) =>
    <String, dynamic>{
      'total': instance.total,
    };

AttendanceStats _$AttendanceStatsFromJson(Map<String, dynamic> json) =>
    AttendanceStats(
      totalMarked: (json['total_marked'] as num).toInt(),
      present: (json['present'] as num).toInt(),
      absent: (json['absent'] as num).toInt(),
      late: (json['late'] as num).toInt(),
    );

Map<String, dynamic> _$AttendanceStatsToJson(AttendanceStats instance) =>
    <String, dynamic>{
      'total_marked': instance.totalMarked,
      'present': instance.present,
      'absent': instance.absent,
      'late': instance.late,
    };

GateStats _$GateStatsFromJson(Map<String, dynamic> json) => GateStats(
      todayEntries: (json['today_entries'] as num).toInt(),
      todayExits: (json['today_exits'] as num).toInt(),
      todayDenied: (json['today_denied'] as num).toInt(),
      currentlyInside: (json['currently_inside'] as num).toInt(),
    );

Map<String, dynamic> _$GateStatsToJson(GateStats instance) => <String, dynamic>{
      'today_entries': instance.todayEntries,
      'today_exits': instance.todayExits,
      'today_denied': instance.todayDenied,
      'currently_inside': instance.currentlyInside,
    };

DashboardResponse _$DashboardResponseFromJson(Map<String, dynamic> json) =>
    DashboardResponse(
      success: json['success'] as bool,
      data: json['data'] == null
          ? null
          : DashboardStats.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$DashboardResponseToJson(DashboardResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'data': instance.data,
    };
