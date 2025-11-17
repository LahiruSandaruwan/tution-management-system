import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/payment.dart';
import '../../../providers/api_provider.dart';

// Payment Summary Provider
final paymentSummaryProvider = FutureProvider<PaymentSummary>((ref) async {
  final apiService = ref.watch(apiProvider);

  try {
    return await apiService.getPaymentSummary();
  } catch (e) {
    return PaymentSummary(
      totalPaid: 0.0,
      totalPending: 0.0,
      totalOverdue: 0.0,
      overdueCount: 0,
      lastPayment: null,
    );
  }
});

// Payment History Provider
final paymentHistoryProvider = FutureProvider<List<Payment>>((ref) async {
  final apiService = ref.watch(apiProvider);

  try {
    return await apiService.getMyPayments();
  } catch (e) {
    return [];
  }
});

// Refresh trigger
final paymentRefreshProvider = StateProvider<int>((ref) => 0);
