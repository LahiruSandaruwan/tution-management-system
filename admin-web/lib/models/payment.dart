import 'package:json_annotation/json_annotation.dart';
import 'student.dart';

part 'payment.g.dart';

@JsonSerializable()
class Payment {
  final int id;
  @JsonKey(name: 'institute_id')
  final int instituteId;
  @JsonKey(name: 'student_id')
  final int studentId;
  final double amount;
  @JsonKey(name: 'payment_date')
  final DateTime? paymentDate;
  @JsonKey(name: 'due_date')
  final DateTime? dueDate;
  final String month;
  final int year;
  final String status;
  @JsonKey(name: 'receipt_number')
  final String? receiptNumber;
  @JsonKey(name: 'payment_method')
  final String? paymentMethod;
  final String? notes;
  final Student? student;

  Payment({
    required this.id,
    required this.instituteId,
    required this.studentId,
    required this.amount,
    this.paymentDate,
    this.dueDate,
    required this.month,
    required this.year,
    required this.status,
    this.receiptNumber,
    this.paymentMethod,
    this.notes,
    this.student,
  });

  factory Payment.fromJson(Map<String, dynamic> json) =>
      _$PaymentFromJson(json);
  Map<String, dynamic> toJson() => _$PaymentToJson(this);

  bool get isPaid => status == 'paid';
  bool get isPending => status == 'pending';
  bool get isOverdue => status == 'overdue';
}

@JsonSerializable()
class PaymentStatistics {
  @JsonKey(name: 'total_collected')
  final double totalCollected;
  @JsonKey(name: 'total_pending')
  final double totalPending;
  @JsonKey(name: 'total_overdue')
  final double totalOverdue;
  @JsonKey(name: 'paid_count')
  final int paidCount;
  @JsonKey(name: 'pending_count')
  final int pendingCount;
  @JsonKey(name: 'overdue_count')
  final int overdueCount;

  PaymentStatistics({
    required this.totalCollected,
    required this.totalPending,
    required this.totalOverdue,
    required this.paidCount,
    required this.pendingCount,
    required this.overdueCount,
  });

  factory PaymentStatistics.fromJson(Map<String, dynamic> json) =>
      _$PaymentStatisticsFromJson(json);
  Map<String, dynamic> toJson() => _$PaymentStatisticsToJson(this);
}
