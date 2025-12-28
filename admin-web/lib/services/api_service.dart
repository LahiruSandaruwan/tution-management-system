import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';
import '../models/user.dart';
import '../models/student.dart';
import '../models/payment.dart';
import '../models/dashboard.dart';
import '../models/class_model.dart';
import '../models/teacher.dart';

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

    // Add interceptor for auth token
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (_authToken != null) {
          options.headers['Authorization'] = 'Bearer $_authToken';
        }
        return handler.next(options);
      },
      onError: (error, handler) {
        // Handle 401 Unauthorized
        if (error.response?.statusCode == 401) {
          // Clear token and redirect to login
          _clearAuth();
        }
        return handler.next(error);
      },
    ));
  }

  // Initialize auth token from storage
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString(AppConstants.keyAuthToken);
  }

  // Set auth token
  Future<void> setAuthToken(String token) async {
    _authToken = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyAuthToken, token);
  }

  // Clear auth
  Future<void> _clearAuth() async {
    _authToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.keyAuthToken);
    await prefs.remove(AppConstants.keyUser);
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

  // ====================== DASHBOARD ENDPOINTS ======================

  Future<DashboardStats> getDashboardStats() async {
    final response = await _dio.get('/dashboard/stats');
    return DashboardStats.fromJson(response.data['data']);
  }

  // ====================== STUDENT ENDPOINTS ======================

  Future<StudentListResponse> getStudents({
    int page = 1,
    int perPage = 15,
    String? search,
    bool? isActive,
    String? grade,
  }) async {
    final response = await _dio.get('/students', queryParameters: {
      'page': page,
      'per_page': perPage,
      if (search != null) 'search': search,
      if (isActive != null) 'is_active': isActive,
      if (grade != null) 'grade': grade,
    });
    return StudentListResponse.fromJson(response.data);
  }

  Future<Student> getStudent(int id) async {
    final response = await _dio.get('/students/$id');
    return Student.fromJson(response.data['data']);
  }

  Future<StudentResponse> createStudent(Map<String, dynamic> data) async {
    final response = await _dio.post('/students', data: data);
    return StudentResponse.fromJson(response.data);
  }

  Future<StudentResponse> updateStudent(
      int id, Map<String, dynamic> data) async {
    final response = await _dio.put('/students/$id', data: data);
    return StudentResponse.fromJson(response.data);
  }

  Future<void> deleteStudent(int id) async {
    await _dio.delete('/students/$id');
  }

  Future<void> toggleStudentStatus(int id) async {
    await _dio.post('/students/$id/toggle-status');
  }

  // ====================== PAYMENT ENDPOINTS ======================

  Future<List<Payment>> getPayments({
    String? status,
    String? month,
    int? year,
    int? studentId,
  }) async {
    final response = await _dio.get('/payments', queryParameters: {
      if (status != null) 'status': status,
      if (month != null) 'month': month,
      if (year != null) 'year': year,
      if (studentId != null) 'student_id': studentId,
    });
    final List data = response.data['data']['data'];
    return data.map((json) => Payment.fromJson(json)).toList();
  }

  Future<Payment> createPayment(Map<String, dynamic> data) async {
    final response = await _dio.post('/payments', data: data);
    return Payment.fromJson(response.data['data']);
  }

  Future<PaymentStatistics> getPaymentStatistics({
    String? month,
    int? year,
  }) async {
    final response = await _dio.get('/payments/statistics', queryParameters: {
      if (month != null) 'month': month,
      if (year != null) 'year': year,
    });
    return PaymentStatistics.fromJson(response.data['data']);
  }

  Future<List<Student>> getDefaulters() async {
    final response = await _dio.get('/payments/defaulters');
    final List data = response.data['data'];
    return data.map((json) => Student.fromJson(json)).toList();
  }

  Future<void> generateMonthlyPayments(String month, int year) async {
    await _dio.post('/payments/generate-monthly', data: {
      'month': month,
      'year': year,
    });
  }

  // ====================== ATTENDANCE ENDPOINTS ======================

  Future<void> markAttendance(Map<String, dynamic> data) async {
    await _dio.post('/attendance/mark', data: data);
  }

  Future<void> markBulkAttendance(Map<String, dynamic> data) async {
    await _dio.post('/attendance/mark-bulk', data: data);
  }

  // ====================== TEACHER ENDPOINTS ======================

  Future<List<dynamic>> getTeachers({
    bool? isActive,
    String? search,
  }) async {
    final response = await _dio.get('/teachers', queryParameters: {
      if (isActive != null) 'is_active': isActive,
      if (search != null) 'search': search,
    });
    return response.data['data']['data'];
  }

  Future<dynamic> getTeacher(int id) async {
    final response = await _dio.get('/teachers/$id');
    return response.data['data'];
  }

  Future<dynamic> createTeacher(Map<String, dynamic> data) async {
    final response = await _dio.post('/teachers', data: data);
    return response.data;
  }

  Future<dynamic> updateTeacher(int id, Map<String, dynamic> data) async {
    final response = await _dio.put('/teachers/$id', data: data);
    return response.data;
  }

  Future<void> deleteTeacher(int id) async {
    await _dio.delete('/teachers/$id');
  }

  Future<void> toggleTeacherStatus(int id) async {
    await _dio.post('/teachers/$id/toggle-status');
  }

  // ====================== SUBJECT ENDPOINTS ======================

  Future<List<Subject>> getSubjects() async {
    final response = await _dio.get('/subjects');
    return (response.data['data'] as List)
        .map((json) => Subject.fromJson(json))
        .toList();
  }

  // ====================== CLASS ENDPOINTS ======================

  Future<List<ClassModel>> getClasses() async {
    final response = await _dio.get('/classes');
    return (response.data['data'] as List)
        .map((json) => ClassModel.fromJson(json))
        .toList();
  }

  Future<ClassModel> getClass(int id) async {
    final response = await _dio.get('/classes/$id');
    return ClassModel.fromJson(response.data['data']);
  }

  Future<ClassModel> createClass(Map<String, dynamic> data) async {
    final response = await _dio.post('/classes', data: data);
    return ClassModel.fromJson(response.data['data']);
  }

  Future<ClassModel> updateClass(int id, Map<String, dynamic> data) async {
    final response = await _dio.put('/classes/$id', data: data);
    return ClassModel.fromJson(response.data['data']);
  }

  Future<void> deleteClass(int id) async {
    await _dio.delete('/classes/$id');
  }

  Future<List<Student>> getClassStudents(int classId) async {
    final response = await _dio.get('/classes/$classId/students');
    return (response.data['data'] as List)
        .map((json) => Student.fromJson(json))
        .toList();
  }

  Future<void> enrollStudentInClass(int classId, int studentId) async {
    await _dio.post('/classes/$classId/enroll', data: {
      'student_id': studentId,
    });
  }

  Future<void> removeStudentFromClass(int classId, int studentId) async {
    await _dio.delete('/classes/$classId/students/$studentId');
  }

  // ====================== NOTIFICATION/ANNOUNCEMENT ENDPOINTS ======================

  Future<List<dynamic>> getNotifications() async {
    final response = await _dio.get('/announcements');
    final data = response.data['data'];
    // Handle Laravel pagination - extract the 'data' array from paginated response
    if (data is Map && data.containsKey('data')) {
      return data['data'] as List<dynamic>;
    }
    if (data is List) {
      return data;
    }
    return [];
  }

  Future<dynamic> createNotification(Map<String, dynamic> data) async {
    final response = await _dio.post('/announcements', data: data);
    return response.data;
  }

  Future<void> deleteNotification(int id) async {
    await _dio.delete('/announcements/$id');
  }

  // ====================== REPORTS ENDPOINTS ======================

  Future<Map<String, dynamic>> getAttendanceReport({
    required String startDate,
    required String endDate,
    int? classId,
    int? studentId,
  }) async {
    final response = await _dio.get('/reports/attendance', queryParameters: {
      'start_date': startDate,
      'end_date': endDate,
      if (classId != null) 'class_id': classId,
      if (studentId != null) 'student_id': studentId,
    });
    return response.data['data'];
  }

  Future<Map<String, dynamic>> getPaymentReport({
    String? startDate,
    String? endDate,
    String? month,
    int? year,
    String? status,
  }) async {
    final response = await _dio.get('/reports/payments', queryParameters: {
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (month != null) 'month': month,
      if (year != null) 'year': year,
      if (status != null) 'status': status,
    });
    return response.data['data'];
  }

  Future<Map<String, dynamic>> getGateLogsReport({
    String? startDate,
    String? endDate,
    String? action,
    int? studentId,
  }) async {
    final response = await _dio.get('/reports/gate-logs', queryParameters: {
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (action != null) 'action': action,
      if (studentId != null) 'student_id': studentId,
    });
    return response.data['data'];
  }
}
