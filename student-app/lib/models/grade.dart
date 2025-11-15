import 'package:json_annotation/json_annotation.dart';

part 'grade.g.dart';

@JsonSerializable()
class Grade {
  final int id;
  @JsonKey(name: 'student_id')
  final int studentId;
  @JsonKey(name: 'class_id')
  final int classId;
  @JsonKey(name: 'exam_type')
  final String examType;
  @JsonKey(name: 'exam_name')
  final String examName;
  @JsonKey(name: 'exam_date')
  final String examDate;
  final double marks;
  @JsonKey(name: 'max_marks')
  final double maxMarks;
  final String? grade;
  final String? remarks;
  @JsonKey(name: 'class_name')
  final String? className;
  @JsonKey(name: 'subject_name')
  final String? subjectName;

  Grade({
    required this.id,
    required this.studentId,
    required this.classId,
    required this.examType,
    required this.examName,
    required this.examDate,
    required this.marks,
    required this.maxMarks,
    this.grade,
    this.remarks,
    this.className,
    this.subjectName,
  });

  factory Grade.fromJson(Map<String, dynamic> json) => _$GradeFromJson(json);
  Map<String, dynamic> toJson() => _$GradeToJson(this);

  double get percentage => (marks / maxMarks) * 100;

  String get gradeLabel {
    if (grade != null) return grade!;

    final percent = percentage;
    if (percent >= 75) return 'A';
    if (percent >= 65) return 'B';
    if (percent >= 55) return 'C';
    if (percent >= 35) return 'S';
    return 'F';
  }
}

@JsonSerializable()
class SubjectGradeSummary {
  @JsonKey(name: 'subject_name')
  final String subjectName;
  @JsonKey(name: 'class_name')
  final String className;
  @JsonKey(name: 'total_exams')
  final int totalExams;
  final double average;
  @JsonKey(name: 'highest_marks')
  final double highestMarks;
  @JsonKey(name: 'lowest_marks')
  final double lowestMarks;

  SubjectGradeSummary({
    required this.subjectName,
    required this.className,
    required this.totalExams,
    required this.average,
    required this.highestMarks,
    required this.lowestMarks,
  });

  factory SubjectGradeSummary.fromJson(Map<String, dynamic> json) =>
      _$SubjectGradeSummaryFromJson(json);
  Map<String, dynamic> toJson() => _$SubjectGradeSummaryToJson(this);
}
