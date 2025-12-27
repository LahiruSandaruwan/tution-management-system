// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Payment _$PaymentFromJson(Map<String, dynamic> json) => Payment(
      id: (json['id'] as num).toInt(),
      instituteId: (json['institute_id'] as num).toInt(),
      studentId: (json['student_id'] as num).toInt(),
      amount: Payment._amountFromJson(json['amount']),
      paymentDate: json['payment_date'] == null
          ? null
          : DateTime.parse(json['payment_date'] as String),
      dueDate: json['due_date'] == null
          ? null
          : DateTime.parse(json['due_date'] as String),
      month: json['month'] as String,
      year: (json['year'] as num).toInt(),
      status: json['status'] as String,
      receiptNumber: json['receipt_number'] as String?,
      paymentMethod: json['payment_method'] as String?,
      notes: json['notes'] as String?,
      student: json['student'] == null
          ? null
          : Student.fromJson(json['student'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PaymentToJson(Payment instance) => <String, dynamic>{
      'id': instance.id,
      'institute_id': instance.instituteId,
      'student_id': instance.studentId,
      'amount': instance.amount,
      'payment_date': instance.paymentDate?.toIso8601String(),
      'due_date': instance.dueDate?.toIso8601String(),
      'month': instance.month,
      'year': instance.year,
      'status': instance.status,
      'receipt_number': instance.receiptNumber,
      'payment_method': instance.paymentMethod,
      'notes': instance.notes,
      'student': instance.student,
    };

PaymentStatistics _$PaymentStatisticsFromJson(Map<String, dynamic> json) =>
    PaymentStatistics(
      totalCollected:
          PaymentStatistics._amountFromJson(json['total_collected']),
      totalPending: PaymentStatistics._amountFromJson(json['total_pending']),
      totalOverdue: PaymentStatistics._amountFromJson(json['total_overdue']),
      paidCount: (json['paid_count'] as num).toInt(),
      pendingCount: (json['pending_count'] as num).toInt(),
      overdueCount: (json['overdue_count'] as num).toInt(),
    );

Map<String, dynamic> _$PaymentStatisticsToJson(PaymentStatistics instance) =>
    <String, dynamic>{
      'total_collected': instance.totalCollected,
      'total_pending': instance.totalPending,
      'total_overdue': instance.totalOverdue,
      'paid_count': instance.paidCount,
      'pending_count': instance.pendingCount,
      'overdue_count': instance.overdueCount,
    };
