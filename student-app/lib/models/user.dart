import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String role;
  @JsonKey(name: 'institute_id')
  final int? instituteId;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.role,
    this.instituteId,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}

@JsonSerializable()
class StudentProfile {
  final int id;
  @JsonKey(name: 'user_id')
  final int userId;
  @JsonKey(name: 'institute_id')
  final int instituteId;
  @JsonKey(name: 'student_id_number')
  final String studentIdNumber;
  final String grade;
  @JsonKey(name: 'date_of_birth')
  final String? dateOfBirth;
  final String? address;
  @JsonKey(name: 'parent_name')
  final String? parentName;
  @JsonKey(name: 'parent_phone')
  final String? parentPhone;
  final String? photo;
  @JsonKey(name: 'is_active')
  final bool isActive;
  final User? user;

  StudentProfile({
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

  factory StudentProfile.fromJson(Map<String, dynamic> json) =>
      _$StudentProfileFromJson(json);
  Map<String, dynamic> toJson() => _$StudentProfileToJson(this);
}

@JsonSerializable()
class AuthResponse {
  final bool success;
  final String message;
  final AuthData? data;

  AuthResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);
  Map<String, dynamic> toJson() => _$AuthResponseToJson(this);
}

@JsonSerializable()
class AuthData {
  final User user;
  final String token;
  final StudentProfile? student;

  AuthData({
    required this.user,
    required this.token,
    this.student,
  });

  factory AuthData.fromJson(Map<String, dynamic> json) =>
      _$AuthDataFromJson(json);
  Map<String, dynamic> toJson() => _$AuthDataToJson(this);
}
