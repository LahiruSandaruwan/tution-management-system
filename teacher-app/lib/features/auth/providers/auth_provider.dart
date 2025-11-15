import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_constants.dart';
import '../../../models/user.dart';
import '../../../providers/api_provider.dart';

class AuthState {
  final User? user;
  final TeacherProfile? teacher;
  final bool isAuthenticated;
  final bool isLoading;
  final String? error;

  AuthState({
    this.user,
    this.teacher,
    this.isAuthenticated = false,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    User? user,
    TeacherProfile? teacher,
    bool? isAuthenticated,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      teacher: teacher ?? this.teacher,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

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
        await _apiService.setAuthToken(token);
        final userData = json.decode(userJson);
        final user = User.fromJson(userData);

        TeacherProfile? teacher;
        if (userData['teacher'] != null) {
          teacher = TeacherProfile.fromJson(userData['teacher']);
        }

        state = state.copyWith(
          user: user,
          teacher: teacher,
          isAuthenticated: true,
          isLoading: false,
        );
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiService.login(email, password);

      if (response.success && response.data != null) {
        final user = response.data!.user;

        // Only allow teachers to login
        if (user.role != 'teacher') {
          state = state.copyWith(
            error: 'This app is only for teachers. Please use the admin web dashboard or student app.',
            isLoading: false,
          );
          await _apiService.logout();
          return false;
        }

        final teacher = response.data!.teacher;

        // Save user and teacher data
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
          AppConstants.keyUser,
          json.encode({
            ...user.toJson(),
            'teacher': teacher?.toJson(),
          }),
        );

        if (teacher != null) {
          await prefs.setInt(AppConstants.keyTeacherId, teacher.id);
        }

        state = state.copyWith(
          user: user,
          teacher: teacher,
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
    await _apiService.logout();
    state = AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final apiService = ref.watch(apiProvider);
  return AuthNotifier(apiService);
});
