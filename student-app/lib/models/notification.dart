import 'package:json_annotation/json_annotation.dart';

part 'notification.g.dart';

@JsonSerializable()
class AppNotification {
  final int id;
  @JsonKey(name: 'institute_id')
  final int instituteId;
  final String title;
  final String message;
  final String type;
  @JsonKey(name: 'target_audience')
  final String targetAudience;
  @JsonKey(name: 'sent_at')
  final String sentAt;
  @JsonKey(name: 'is_read')
  final bool? isRead;
  final Map<String, dynamic>? metadata;

  AppNotification({
    required this.id,
    required this.instituteId,
    required this.title,
    required this.message,
    required this.type,
    required this.targetAudience,
    required this.sentAt,
    this.isRead,
    this.metadata,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      _$AppNotificationFromJson(json);
  Map<String, dynamic> toJson() => _$AppNotificationToJson(this);

  String get typeLabel {
    switch (type) {
      case 'announcement':
        return 'Announcement';
      case 'payment_reminder':
        return 'Payment Reminder';
      case 'class_cancellation':
        return 'Class Cancellation';
      case 'exam_notification':
        return 'Exam Notification';
      case 'grade_published':
        return 'Grades Published';
      default:
        return 'Notification';
    }
  }
}
