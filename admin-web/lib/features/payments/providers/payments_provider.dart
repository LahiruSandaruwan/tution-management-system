import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/payment.dart';
import '../../../models/student.dart';
import '../../../services/api_service.dart';
import '../../../providers/api_provider.dart';

class PaymentsState {
  final bool isLoading;
  final String? error;
  final List<Payment> payments;
  final PaymentStatistics? statistics;
  final List<Student> defaulters;
  final String? statusFilter;
  final String? monthFilter;
  final int? yearFilter;

  PaymentsState({
    this.isLoading = false,
    this.error,
    this.payments = const [],
    this.statistics,
    this.defaulters = const [],
    this.statusFilter,
    this.monthFilter,
    this.yearFilter,
  });

  PaymentsState copyWith({
    bool? isLoading,
    String? error,
    List<Payment>? payments,
    PaymentStatistics? statistics,
    List<Student>? defaulters,
    String? statusFilter,
    String? monthFilter,
    int? yearFilter,
    bool clearError = false,
  }) {
    return PaymentsState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      payments: payments ?? this.payments,
      statistics: statistics ?? this.statistics,
      defaulters: defaulters ?? this.defaulters,
      statusFilter: statusFilter ?? this.statusFilter,
      monthFilter: monthFilter ?? this.monthFilter,
      yearFilter: yearFilter ?? this.yearFilter,
    );
  }
}

class PaymentsNotifier extends StateNotifier<PaymentsState> {
  final ApiService _apiService;

  PaymentsNotifier(this._apiService) : super(PaymentsState());

  Future<void> loadPayments({
    String? status,
    String? month,
    int? year,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final payments = await _apiService.getPayments(
        status: status ?? state.statusFilter,
        month: month ?? state.monthFilter,
        year: year ?? state.yearFilter,
      );

      state = state.copyWith(
        isLoading: false,
        payments: payments,
        statusFilter: status,
        monthFilter: month,
        yearFilter: year,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadStatistics({String? month, int? year}) async {
    try {
      final statistics = await _apiService.getPaymentStatistics(
        month: month ?? state.monthFilter,
        year: year ?? state.yearFilter,
      );

      state = state.copyWith(statistics: statistics);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> loadDefaulters() async {
    try {
      final defaulters = await _apiService.getDefaulters();
      state = state.copyWith(defaulters: defaulters);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> loadAll() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await Future.wait([
        loadPayments(),
        loadStatistics(),
        loadDefaulters(),
      ]);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refresh() async {
    await loadAll();
  }

  Future<void> setStatusFilter(String? status) async {
    await loadPayments(status: status == 'All' ? null : status);
  }

  Future<void> setMonthFilter(String? month) async {
    await loadPayments(month: month == 'All' ? null : month);
    await loadStatistics(month: month == 'All' ? null : month);
  }

  Future<void> setYearFilter(int? year) async {
    await loadPayments(year: year);
    await loadStatistics(year: year);
  }

  Future<bool> createPayment(Map<String, dynamic> data) async {
    try {
      await _apiService.createPayment(data);
      await refresh();
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> generateMonthlyPayments(String month, int year) async {
    try {
      await _apiService.generateMonthlyPayments(month, year);
      await refresh();
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }
}

final paymentsProvider =
    StateNotifierProvider<PaymentsNotifier, PaymentsState>((ref) {
  final apiService = ref.watch(apiProvider);
  return PaymentsNotifier(apiService);
});
