import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/payment.dart';
import '../../../providers/api_provider.dart';

// Payment Summary Provider
final paymentSummaryProvider = FutureProvider<PaymentSummary>((ref) async {
  final apiService = ref.watch(apiProvider);

  try {
    return await apiService.getPaymentSummary();
  } catch (e) {
    // Let Riverpod handle error state naturally - UI will show error
    rethrow;
  }
});

// Payment History Provider
final paymentHistoryProvider = FutureProvider<List<Payment>>((ref) async {
  final apiService = ref.watch(apiProvider);

  try {
    return await apiService.getMyPayments();
  } catch (e) {
    // Let Riverpod handle error state naturally - UI will show error
    rethrow;
  }
});

// Refresh trigger
final paymentRefreshProvider = StateProvider<int>((ref) => 0);
