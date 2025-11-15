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
class TeacherProfile {
  final int id;
  @JsonKey(name: 'user_id')
  final int userId;
  @JsonKey(name: 'institute_id')
  final int instituteId;
  @JsonKey(name: 'employee_id')
  final String employeeId;
  final String specialization;
  final String? qualification;
  @JsonKey(name: 'date_of_joining')
  final String? dateOfJoining;
  final String? photo;
  @JsonKey(name: 'is_active')
  final bool isActive;
  final User? user;

  TeacherProfile({
    required this.id,
    required this.userId,
    required this.instituteId,
    required this.employeeId,
    required this.specialization,
    this.qualification,
    this.dateOfJoining,
    this.photo,
    required this.isActive,
    this.user,
  });

  factory TeacherProfile.fromJson(Map<String, dynamic> json) =>
      _$TeacherProfileFromJson(json);
  Map<String, dynamic> toJson() => _$TeacherProfileToJson(this);
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
  final TeacherProfile? teacher;

  AuthData({
    required this.user,
    required this.token,
    this.teacher,
  });

  factory AuthData.fromJson(Map<String, dynamic> json) =>
      _$AuthDataFromJson(json);
  Map<String, dynamic> toJson() => _$AuthDataToJson(this);
}
