// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'teacher.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Teacher _$TeacherFromJson(Map<String, dynamic> json) => Teacher(
      id: (json['id'] as num).toInt(),
      userId: (json['user_id'] as num).toInt(),
      instituteId: (json['institute_id'] as num).toInt(),
      employeeId: json['employee_id'] as String,
      specialization: json['specialization'] as String,
      qualification: json['qualification'] as String?,
      dateOfJoining: json['date_of_joining'] as String?,
      isActive: json['is_active'] as bool,
      user: json['user'] == null
          ? null
          : User.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$TeacherToJson(Teacher instance) => <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'institute_id': instance.instituteId,
      'employee_id': instance.employeeId,
      'specialization': instance.specialization,
      'qualification': instance.qualification,
      'date_of_joining': instance.dateOfJoining,
      'is_active': instance.isActive,
      'user': instance.user,
    };

TeacherResponse _$TeacherResponseFromJson(Map<String, dynamic> json) =>
    TeacherResponse(
      success: json['success'] as bool,
      message: json['message'] as String?,
      data: json['data'] == null
          ? null
          : Teacher.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$TeacherResponseToJson(TeacherResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
    };

TeacherListResponse _$TeacherListResponseFromJson(Map<String, dynamic> json) =>
    TeacherListResponse(
      success: json['success'] as bool,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => Teacher.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$TeacherListResponseToJson(
        TeacherListResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'data': instance.data,
    };
