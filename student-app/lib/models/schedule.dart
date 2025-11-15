import 'package:json_annotation/json_annotation.dart';

part 'schedule.g.dart';

@JsonSerializable()
class ClassSchedule {
  final int id;
  @JsonKey(name: 'class_id')
  final int classId;
  @JsonKey(name: 'day_of_week')
  final String dayOfWeek;
  @JsonKey(name: 'start_time')
  final String startTime;
  @JsonKey(name: 'end_time')
  final String endTime;
  final String? room;
  @JsonKey(name: 'class_name')
  final String? className;
  @JsonKey(name: 'subject_name')
  final String? subjectName;
  @JsonKey(name: 'teacher_name')
  final String? teacherName;

  ClassSchedule({
    required this.id,
    required this.classId,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    this.room,
    this.className,
    this.subjectName,
    this.teacherName,
  });

  factory ClassSchedule.fromJson(Map<String, dynamic> json) =>
      _$ClassScheduleFromJson(json);
  Map<String, dynamic> toJson() => _$ClassScheduleToJson(this);

  String get timeRange => '$startTime - $endTime';

  int get dayIndex {
    switch (dayOfWeek.toLowerCase()) {
      case 'monday':
        return 0;
      case 'tuesday':
        return 1;
      case 'wednesday':
        return 2;
      case 'thursday':
        return 3;
      case 'friday':
        return 4;
      case 'saturday':
        return 5;
      case 'sunday':
        return 6;
      default:
        return 0;
    }
  }
}

@JsonSerializable()
class WeeklySchedule {
  final List<ClassSchedule> monday;
  final List<ClassSchedule> tuesday;
  final List<ClassSchedule> wednesday;
  final List<ClassSchedule> thursday;
  final List<ClassSchedule> friday;
  final List<ClassSchedule> saturday;
  final List<ClassSchedule> sunday;

  WeeklySchedule({
    required this.monday,
    required this.tuesday,
    required this.wednesday,
    required this.thursday,
    required this.friday,
    required this.saturday,
    required this.sunday,
  });

  factory WeeklySchedule.fromJson(Map<String, dynamic> json) =>
      _$WeeklyScheduleFromJson(json);
  Map<String, dynamic> toJson() => _$WeeklyScheduleToJson(this);

  List<ClassSchedule> getScheduleForDay(int dayIndex) {
    switch (dayIndex) {
      case 0:
        return monday;
      case 1:
        return tuesday;
      case 2:
        return wednesday;
      case 3:
        return thursday;
      case 4:
        return friday;
      case 5:
        return saturday;
      case 6:
        return sunday;
      default:
        return [];
    }
  }
}
