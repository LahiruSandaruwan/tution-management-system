import 'package:json_annotation/json_annotation.dart';

part 'payment.g.dart';

@JsonSerializable()
class Payment {
  final int id;
  @JsonKey(name: 'student_id')
  final int studentId;
  final double amount;
  @JsonKey(name: 'payment_date')
  final String? paymentDate;
  @JsonKey(name: 'due_date')
  final String? dueDate;
  final String month;
  final int year;
  final String status;
  @JsonKey(name: 'receipt_number')
  final String? receiptNumber;
  @JsonKey(name: 'payment_method')
  final String? paymentMethod;

  Payment({
    required this.id,
    required this.studentId,
    required this.amount,
    this.paymentDate,
    this.dueDate,
    required this.month,
    required this.year,
    required this.status,
    this.receiptNumber,
    this.paymentMethod,
  });

  factory Payment.fromJson(Map<String, dynamic> json) =>
      _$PaymentFromJson(json);
  Map<String, dynamic> toJson() => _$PaymentToJson(this);

  bool get isPaid => status == 'paid';
  bool get isPending => status == 'pending';
  bool get isOverdue => status == 'overdue';
}

@JsonSerializable()
class PaymentSummary {
  @JsonKey(name: 'total_paid')
  final double totalPaid;
  @JsonKey(name: 'total_pending')
  final double totalPending;
  @JsonKey(name: 'total_overdue')
  final double totalOverdue;
  @JsonKey(name: 'overdue_count')
  final int overdueCount;
  @JsonKey(name: 'last_payment')
  final Payment? lastPayment;

  PaymentSummary({
    required this.totalPaid,
    required this.totalPending,
    required this.totalOverdue,
    required this.overdueCount,
    this.lastPayment,
  });

  factory PaymentSummary.fromJson(Map<String, dynamic> json) =>
      _$PaymentSummaryFromJson(json);
  Map<String, dynamic> toJson() => _$PaymentSummaryToJson(this);
}
