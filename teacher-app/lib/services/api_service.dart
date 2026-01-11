import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';
import '../models/user.dart';
import '../models/class.dart';
import '../models/attendance.dart';

class ApiService {
  late final Dio _dio;
  String? _authToken;

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.apiBaseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors for token and logging
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (_authToken != null) {
            options.headers['Authorization'] = 'Bearer $_authToken';
          }
          return handler.next(options);
        },
        onError: (error, handler) {
          if (error.response?.statusCode == 401) {
            // Token expired, logout
            logout();
          }
          return handler.next(error);
        },
      ),
    );
  }

  // ====================== AUTH ENDPOINTS ======================

  Future<AuthResponse> login(String email, String password) async {
    final response = await _dio.post(
      '/auth/login',
      data: {
        'email': email,
        'password': password,
      },
    );

    final authResponse = AuthResponse.fromJson(response.data);

    if (authResponse.success && authResponse.data?.token != null) {
      await setAuthToken(authResponse.data!.token);
    }

    return authResponse;
  }

  Future<void> logout() async {
    try {
      await _dio.post('/auth/logout');
    } catch (e) {
      // Continue with logout even if API call fails
    } finally {
      _authToken = null;
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.keyAuthToken);
      await prefs.remove(AppConstants.keyUser);
      await prefs.remove(AppConstants.keyTeacherId);
    }
  }

  Future<void> setAuthToken(String token) async {
    _authToken = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyAuthToken, token);
  }

  Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString(AppConstants.keyAuthToken);
    return _authToken;
  }

  // ====================== FCM TOKEN ENDPOINTS ======================

  Future<Map<String, dynamic>> registerFcmToken({
    required String token,
    String? deviceType,
    String? deviceId,
  }) async {
    final response = await _dio.post('/fcm-tokens', data: {
      'token': token,
      if (deviceType != null) 'device_type': deviceType,
      if (deviceId != null) 'device_id': deviceId,
    });
    return response.data;
  }

  // ====================== CLASS ENDPOINTS ======================

  Future<List<TeacherClass>> getMyClasses() async {
    final prefs = await SharedPreferences.getInstance();
    final teacherId = prefs.getInt(AppConstants.keyTeacherId);

    final response = await _dio.get('/teachers/$teacherId/classes');
    final List classes = response.data['data'];
    return classes.map((json) => TeacherClass.fromJson(json)).toList();
  }

  Future<TeacherClass> getClassDetails(int classId) async {
    final response = await _dio.get('/classes/$classId');
    return TeacherClass.fromJson(response.data['data']);
  }

  Future<List<ClassStudent>> getClassStudents(int classId) async {
    final response = await _dio.get('/classes/$classId/students');
    final List students = response.data['data'];
    return students.map((json) => ClassStudent.fromJson(json)).toList();
  }

  // ====================== ATTENDANCE ENDPOINTS ======================

  Future<List<Attendance>> getClassAttendance(int classId, String date) async {
    final response = await _dio.get(
      '/attendance/class/$classId',
      queryParameters: {'date': date},
    );
    final List attendance = response.data['data'];
    return attendance.map((json) => Attendance.fromJson(json)).toList();
  }

  Future<AttendanceStats> getAttendanceStats(int classId, {String? month, int? year}) async {
    final response = await _dio.get(
      '/attendance/class/$classId/stats',
      queryParameters: {
        if (month != null) 'month': month,
        if (year != null) 'year': year,
      },
    );
    return AttendanceStats.fromJson(response.data['data']);
  }

  Future<void> markAttendance({
    required int classId,
    required int studentId,
    required String date,
    required String status,
    String? checkInTime,
    String? notes,
  }) async {
    await _dio.post(
      '/attendance',
      data: {
        'class_id': classId,
        'student_id': studentId,
        'date': date,
        'status': status,
        if (checkInTime != null) 'check_in_time': checkInTime,
        if (notes != null) 'notes': notes,
      },
    );
  }

  Future<void> bulkMarkAttendance({
    required int classId,
    required String date,
    required List<Map<String, dynamic>> attendanceData,
  }) async {
    await _dio.post(
      '/attendance/mark-bulk',
      data: {
        'class_id': classId,
        'date': date,
        'attendances': attendanceData,
      },
    );
  }

  // ====================== GRADE ENDPOINTS ======================

  Future<void> addGrade({
    required int studentId,
    required int classId,
    required String examType,
    required String examName,
    required String examDate,
    required double marks,
    required double maxMarks,
    String? grade,
    String? remarks,
  }) async {
    await _dio.post(
      '/grades',
      data: {
        'student_id': studentId,
        'class_id': classId,
        'exam_type': examType,
        'exam_name': examName,
        'exam_date': examDate,
        'marks': marks,
        'max_marks': maxMarks,
        if (grade != null) 'grade': grade,
        if (remarks != null) 'remarks': remarks,
      },
    );
  }

  Future<List<dynamic>> getClassGrades(int classId, {String? examType}) async {
    final response = await _dio.get(
      '/grades/class/$classId',
      queryParameters: {
        if (examType != null) 'exam_type': examType,
      },
    );
    return response.data['data'];
  }

  // ====================== DASHBOARD ENDPOINTS ======================

  Future<Map<String, dynamic>> getTeacherDashboard() async {
    final prefs = await SharedPreferences.getInstance();
    final teacherId = prefs.getInt(AppConstants.keyTeacherId);

    final response = await _dio.get('/teachers/$teacherId/dashboard');
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
