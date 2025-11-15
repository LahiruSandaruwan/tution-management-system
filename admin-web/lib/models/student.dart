import 'package:json_annotation/json_annotation.dart';
import 'user.dart';

part 'student.g.dart';

@JsonSerializable()
class Student {
  final int id;
  @JsonKey(name: 'user_id')
  final int userId;
  @JsonKey(name: 'institute_id')
  final int instituteId;
  @JsonKey(name: 'student_id_number')
  final String studentIdNumber;
  final String grade;
  @JsonKey(name: 'date_of_birth')
  final DateTime? dateOfBirth;
  final String? address;
  @JsonKey(name: 'parent_name')
  final String? parentName;
  @JsonKey(name: 'parent_phone')
  final String? parentPhone;
  final String? photo;
  @JsonKey(name: 'is_active')
  final bool isActive;
  final User? user;

  Student({
    required this.id,
    required this.userId,
    required this.instituteId,
    required this.studentIdNumber,
    required this.grade,
    this.dateOfBirth,
    this.address,
    this.parentName,
    this.parentPhone,
    this.photo,
    required this.isActive,
    this.user,
  });

  factory Student.fromJson(Map<String, dynamic> json) =>
      _$StudentFromJson(json);
  Map<String, dynamic> toJson() => _$StudentToJson(this);

  String get displayName => user?.name ?? 'Unknown';
}

@JsonSerializable()
class StudentResponse {
  final bool success;
  final String? message;
  final Student? data;

  StudentResponse({
    required this.success,
    this.message,
    this.data,
  });

  factory StudentResponse.fromJson(Map<String, dynamic> json) =>
      _$StudentResponseFromJson(json);
  Map<String, dynamic> toJson() => _$StudentResponseToJson(this);
}

@JsonSerializable()
class StudentListResponse {
  final bool success;
  final StudentPaginatedData? data;

  StudentListResponse({
    required this.success,
    this.data,
  });

  factory StudentListResponse.fromJson(Map<String, dynamic> json) =>
      _$StudentListResponseFromJson(json);
  Map<String, dynamic> toJson() => _$StudentListResponseToJson(this);
}

@JsonSerializable()
class StudentPaginatedData {
  @JsonKey(name: 'current_page')
  final int currentPage;
  final List<Student> data;
  @JsonKey(name: 'last_page')
  final int lastPage;
  @JsonKey(name: 'per_page')
  final int perPage;
  final int total;

  StudentPaginatedData({
    required this.currentPage,
    required this.data,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory StudentPaginatedData.fromJson(Map<String, dynamic> json) =>
      _$StudentPaginatedDataFromJson(json);
  Map<String, dynamic> toJson() => _$StudentPaginatedDataToJson(this);
}
