import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';
import '../models/user.dart';
import '../models/attendance.dart';
import '../models/payment.dart';

class ApiService {
  late final Dio _dio;
  String? _authToken;

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.apiBaseUrl,
      connectTimeout: const Duration(milliseconds: 30000),
      receiveTimeout: const Duration(milliseconds: 30000),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (_authToken != null) {
          options.headers['Authorization'] = 'Bearer $_authToken';
        }
        return handler.next(options);
      },
      onError: (error, handler) {
        if (error.response?.statusCode == 401) {
          _clearAuth();
        }
        return handler.next(error);
      },
    ));
  }

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString(AppConstants.keyAuthToken);
  }

  Future<void> setAuthToken(String token) async {
    _authToken = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyAuthToken, token);
  }

  Future<void> _clearAuth() async {
    _authToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.keyAuthToken);
    await prefs.remove(AppConstants.keyUser);
    await prefs.remove(AppConstants.keyStudentId);
  }

  // ====================== AUTH ENDPOINTS ======================

  Future<AuthResponse> login(String email, String password) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      final authResponse = AuthResponse.fromJson(response.data);
      if (authResponse.success && authResponse.data?.token != null) {
        await setAuthToken(authResponse.data!.token);
      }
      return authResponse;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post('/auth/logout');
    } finally {
      await _clearAuth();
    }
  }

  Future<User> getCurrentUser() async {
    final response = await _dio.get('/auth/me');
    return User.fromJson(response.data['data']);
  }

  // ====================== ATTENDANCE ENDPOINTS ======================

  Future<AttendanceSummary> getAttendanceSummary({
    String? month,
    int? year,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final studentId = prefs.getInt(AppConstants.keyStudentId);

    final response = await _dio.get(
      '/attendance/student/$studentId/summary',
      queryParameters: {
        if (month != null) 'month': month,
        if (year != null) 'year': year,
      },
    );
    return AttendanceSummary.fromJson(response.data['data']);
  }

  // ====================== PAYMENT ENDPOINTS ======================

  Future<List<Payment>> getMyPayments() async {
    final prefs = await SharedPreferences.getInstance();
    final studentId = prefs.getInt(AppConstants.keyStudentId);

    final response = await _dio.get('/payments/student/$studentId');
    final List payments = response.data['data']['payments'];
    return payments.map((json) => Payment.fromJson(json)).toList();
  }

  Future<PaymentSummary> getPaymentSummary() async {
    final prefs = await SharedPreferences.getInstance();
    final studentId = prefs.getInt(AppConstants.keyStudentId);

    final response = await _dio.get('/students/$studentId/payment-summary');
    return PaymentSummary.fromJson(response.data['data']);
  }

  // ====================== SCHEDULE ENDPOINTS ======================

  Future<List<dynamic>> getMySchedule() async {
    final prefs = await SharedPreferences.getInstance();
    final studentId = prefs.getInt(AppConstants.keyStudentId);

    final response = await _dio.get('/schedules/student/$studentId');
    return response.data['data'];
  }

  // ====================== GRADES ENDPOINTS ======================

  Future<List<dynamic>> getMyGrades() async {
    final prefs = await SharedPreferences.getInstance();
    final studentId = prefs.getInt(AppConstants.keyStudentId);

    final response = await _dio.get('/grades/student/$studentId');
    return response.data['data'];
  }

  // ====================== NOTIFICATION ENDPOINTS ======================

  Future<List<dynamic>> getNotifications() async {
    final response = await _dio.get('/notifications');
    return response.data['data']['data'];
  }

  Future<int> getUnreadCount() async {
    final response = await _dio.get('/notifications/unread-count');
    return response.data['data']['count'];
  }

  Future<void> markNotificationAsRead(int notificationId) async {
    await _dio.post('/notifications/$notificationId/read');
  }
}
