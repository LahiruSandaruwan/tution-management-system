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

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await _dio.post('/auth/forgot-password', data: {
        'email': email,
      });
      return response.data;
    } catch (e) {
      if (e is DioException && e.response != null) {
        return e.response!.data;
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String token,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await _dio.post('/auth/reset-password', data: {
        'email': email,
        'token': token,
        'password': password,
        'password_confirmation': passwordConfirmation,
      });
      return response.data;
    } catch (e) {
      if (e is DioException && e.response != null) {
        return e.response!.data;
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await _dio.post('/auth/change-password', data: {
        'current_password': currentPassword,
        'password': password,
        'password_confirmation': passwordConfirmation,
      });
      return response.data;
    } catch (e) {
      if (e is DioException && e.response != null) {
        return e.response!.data;
      }
      rethrow;
    }
  }

  // ====================== FCM TOKEN ENDPOINTS ======================

  Future<Map<String, dynamic>> registerFcmToken({
    required String token,
    String? deviceType,
    String? deviceId,
  }) async {
    try {
      final response = await _dio.post('/fcm-tokens', data: {
        'token': token,
        if (deviceType != null) 'device_type': deviceType,
        if (deviceId != null) 'device_id': deviceId,
      });
      return response.data;
    } catch (e) {
      if (e is DioException && e.response != null) {
        return e.response!.data;
      }
      rethrow;
    }
  }

  // ====================== DASHBOARD ENDPOINTS ======================

  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final studentId = prefs.getInt(AppConstants.keyStudentId);

      final response = await _dio.get('/students/$studentId/dashboard');
      return response.data;
    } catch (e) {
      return {'data': {}};
    }
  }

  Future<Map<String, dynamic>> getRecentActivities() async {
    try {
      final response = await _dio.get('/dashboard/recent-activities');
      return response.data;
    } catch (e) {
      return {'data': []};
    }
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

  Future<List<Attendance>> getAttendanceHistory({
    String? month,
    int? year,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final studentId = prefs.getInt(AppConstants.keyStudentId);

    final response = await _dio.get(
      '/attendance/student/$studentId',
      queryParameters: {
        if (month != null) 'month': month,
        if (year != null) 'year': year,
      },
    );
    final List attendance = response.data['data'] ?? [];
    return attendance.map((json) => Attendance.fromJson(json)).toList();
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

  // ====================== PROFILE PHOTO ENDPOINTS ======================

  Future<Map<String, dynamic>> uploadProfilePhoto(String filePath) async {
    try {
      final fileName = filePath.split('/').last;
      final formData = FormData.fromMap({
        'profile_photo': await MultipartFile.fromFile(
          filePath,
          filename: fileName,
        ),
      });

      final response = await _dio.post('/auth/upload-profile-photo', data: formData);
      return response.data;
    } catch (e) {
      if (e is DioException && e.response != null) {
        return e.response!.data;
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> deleteProfilePhoto() async {
    try {
      final response = await _dio.delete('/auth/delete-profile-photo');
      return response.data;
    } catch (e) {
      if (e is DioException && e.response != null) {
        return e.response!.data;
      }
      rethrow;
    }
  }
}
