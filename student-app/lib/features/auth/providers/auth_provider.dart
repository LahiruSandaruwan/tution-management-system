import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../models/user.dart';
import '../../../services/api_service.dart';
import '../../../providers/api_provider.dart';
import '../../../core/constants/app_constants.dart';

// Auth State
class AuthState {
  final User? user;
  final StudentProfile? student;
  final bool isLoading;
  final String? error;
  final bool isAuthenticated;

  AuthState({
    this.user,
    this.student,
    this.isLoading = false,
    this.error,
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    User? user,
    StudentProfile? student,
    bool? isLoading,
    String? error,
    bool? isAuthenticated,
  }) {
    return AuthState(
      user: user ?? this.user,
      student: student ?? this.student,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

// Auth Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final ApiService _apiService;

  AuthNotifier(this._apiService) : super(AuthState()) {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    state = state.copyWith(isLoading: true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.keyAuthToken);
      final userJson = prefs.getString(AppConstants.keyUser);

      if (token != null && userJson != null) {
        final user = User.fromJson(json.decode(userJson));

        // If user is student, get student profile
        StudentProfile? student;
        if (user.role == 'student') {
          final studentJson = userJson; // Student data is embedded in auth response
          final data = json.decode(studentJson);
          if (data['student'] != null) {
            student = StudentProfile.fromJson(data['student']);
          }
        }

        state = state.copyWith(
          user: user,
          student: student,
          isAuthenticated: true,
          isLoading: false,
        );
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _apiService.login(email, password);

      if (response.success && response.data != null) {
        final user = response.data!.user;
        final student = response.data!.student;

        // Only allow students to login
        if (user.role != 'student') {
          state = state.copyWith(
            error: 'This app is only for students. Please use the admin web dashboard or teacher app.',
            isLoading: false,
          );
          await _apiService.logout();
          return false;
        }

        // Save user and student data
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
          AppConstants.keyUser,
          json.encode({
            ...user.toJson(),
            'student': student?.toJson(),
          }),
        );
        if (student != null) {
          await prefs.setInt(AppConstants.keyStudentId, student.id);
        }

        state = state.copyWith(
          user: user,
          student: student,
          isAuthenticated: true,
          isLoading: false,
        );
        return true;
      } else {
        state = state.copyWith(
          error: response.message,
          isLoading: false,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _apiService.logout();
    } finally {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      state = AuthState();
    }
  }
}

// Auth Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return AuthNotifier(apiService);
});
