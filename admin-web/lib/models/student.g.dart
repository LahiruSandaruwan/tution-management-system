// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Student _$StudentFromJson(Map<String, dynamic> json) => Student(
      id: (json['id'] as num).toInt(),
      userId: (json['user_id'] as num).toInt(),
      instituteId: (json['institute_id'] as num).toInt(),
      studentIdNumber: json['student_id_number'] as String,
      grade: json['grade'] as String,
      dateOfBirth: json['date_of_birth'] == null
          ? null
          : DateTime.parse(json['date_of_birth'] as String),
      address: json['address'] as String?,
      parentName: json['parent_name'] as String?,
      parentPhone: json['parent_phone'] as String?,
      photo: json['photo'] as String?,
      isActive: json['is_active'] as bool,
      user: json['user'] == null
          ? null
          : User.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$StudentToJson(Student instance) => <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'institute_id': instance.instituteId,
      'student_id_number': instance.studentIdNumber,
      'grade': instance.grade,
      'date_of_birth': instance.dateOfBirth?.toIso8601String(),
      'address': instance.address,
      'parent_name': instance.parentName,
      'parent_phone': instance.parentPhone,
      'photo': instance.photo,
      'is_active': instance.isActive,
      'user': instance.user,
    };

StudentResponse _$StudentResponseFromJson(Map<String, dynamic> json) =>
    StudentResponse(
      success: json['success'] as bool,
      message: json['message'] as String?,
      data: json['data'] == null
          ? null
          : Student.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$StudentResponseToJson(StudentResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
    };

StudentListResponse _$StudentListResponseFromJson(Map<String, dynamic> json) =>
    StudentListResponse(
      success: json['success'] as bool,
      data: json['data'] == null
          ? null
          : StudentPaginatedData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$StudentListResponseToJson(
        StudentListResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'data': instance.data,
    };

StudentPaginatedData _$StudentPaginatedDataFromJson(
        Map<String, dynamic> json) =>
    StudentPaginatedData(
      currentPage: (json['current_page'] as num).toInt(),
      data: (json['data'] as List<dynamic>)
          .map((e) => Student.fromJson(e as Map<String, dynamic>))
          .toList(),
      lastPage: (json['last_page'] as num).toInt(),
      perPage: (json['per_page'] as num).toInt(),
      total: (json['total'] as num).toInt(),
    );

Map<String, dynamic> _$StudentPaginatedDataToJson(
        StudentPaginatedData instance) =>
    <String, dynamic>{
      'current_page': instance.currentPage,
      'data': instance.data,
      'last_page': instance.lastPage,
      'per_page': instance.perPage,
      'total': instance.total,
    };
