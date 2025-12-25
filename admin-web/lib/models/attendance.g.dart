// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Attendance _$AttendanceFromJson(Map<String, dynamic> json) => Attendance(
      id: (json['id'] as num).toInt(),
      studentId: (json['student_id'] as num).toInt(),
      classId: (json['class_id'] as num).toInt(),
      date: json['date'] as String,
      status: json['status'] as String,
      remarks: json['remarks'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      student: json['student'] == null
          ? null
          : Student.fromJson(json['student'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AttendanceToJson(Attendance instance) =>
    <String, dynamic>{
      'id': instance.id,
      'student_id': instance.studentId,
      'class_id': instance.classId,
      'date': instance.date,
      'status': instance.status,
      'remarks': instance.remarks,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
      'student': instance.student,
    };

AttendanceSummary _$AttendanceSummaryFromJson(Map<String, dynamic> json) =>
    AttendanceSummary(
      totalClasses: (json['total_classes'] as num).toInt(),
      presentCount: (json['present_count'] as num).toInt(),
      absentCount: (json['absent_count'] as num).toInt(),
      lateCount: (json['late_count'] as num).toInt(),
      attendancePercentage: (json['attendance_percentage'] as num).toDouble(),
    );

Map<String, dynamic> _$AttendanceSummaryToJson(AttendanceSummary instance) =>
    <String, dynamic>{
      'total_classes': instance.totalClasses,
      'present_count': instance.presentCount,
      'absent_count': instance.absentCount,
      'late_count': instance.lateCount,
      'attendance_percentage': instance.attendancePercentage,
    };

ClassAttendanceReport _$ClassAttendanceReportFromJson(
        Map<String, dynamic> json) =>
    ClassAttendanceReport(
      className: json['class_name'] as String,
      date: json['date'] as String,
      totalStudents: (json['total_students'] as num).toInt(),
      presentCount: (json['present_count'] as num).toInt(),
      absentCount: (json['absent_count'] as num).toInt(),
      lateCount: (json['late_count'] as num).toInt(),
      attendancePercentage: (json['attendance_percentage'] as num).toDouble(),
      attendances: (json['attendances'] as List<dynamic>)
          .map((e) => Attendance.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ClassAttendanceReportToJson(
        ClassAttendanceReport instance) =>
    <String, dynamic>{
      'class_name': instance.className,
      'date': instance.date,
      'total_students': instance.totalStudents,
      'present_count': instance.presentCount,
      'absent_count': instance.absentCount,
      'late_count': instance.lateCount,
      'attendance_percentage': instance.attendancePercentage,
      'attendances': instance.attendances,
    };
