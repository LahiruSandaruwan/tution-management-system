import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/api_service.dart';
import '../../../providers/api_provider.dart';

class TeachersState {
  final bool isLoading;
  final String? error;
  final List<dynamic> teachers;
  final String? searchQuery;
  final bool? activeFilter;

  TeachersState({
    this.isLoading = false,
    this.error,
    this.teachers = const [],
    this.searchQuery,
    this.activeFilter,
  });

  TeachersState copyWith({
    bool? isLoading,
    String? error,
    List<dynamic>? teachers,
    String? searchQuery,
    bool? activeFilter,
    bool clearError = false,
  }) {
    return TeachersState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      teachers: teachers ?? this.teachers,
      searchQuery: searchQuery ?? this.searchQuery,
      activeFilter: activeFilter ?? this.activeFilter,
    );
  }
}

class TeachersNotifier extends StateNotifier<TeachersState> {
  final ApiService _apiService;

  TeachersNotifier(this._apiService) : super(TeachersState());

  Future<void> loadTeachers({String? search, bool? isActive}) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final teachers = await _apiService.getTeachers(
        search: search ?? state.searchQuery,
        isActive: isActive ?? state.activeFilter,
      );

      state = state.copyWith(
        isLoading: false,
        teachers: teachers,
        searchQuery: search,
        activeFilter: isActive,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refresh() async {
    await loadTeachers();
  }

  Future<void> setSearchQuery(String query) async {
    await loadTeachers(search: query.isEmpty ? null : query);
  }

  Future<void> setActiveFilter(bool? isActive) async {
    await loadTeachers(isActive: isActive);
  }

  Future<bool> createTeacher(Map<String, dynamic> data) async {
    try {
      await _apiService.createTeacher(data);
      await refresh();
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> updateTeacher(int id, Map<String, dynamic> data) async {
    try {
      await _apiService.updateTeacher(id, data);
      await refresh();
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> deleteTeacher(int id) async {
    try {
      await _apiService.deleteTeacher(id);
      await refresh();
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> toggleTeacherStatus(int id) async {
    try {
      await _apiService.toggleTeacherStatus(id);
      await refresh();
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }
}

final teachersProvider =
    StateNotifierProvider<TeachersNotifier, TeachersState>((ref) {
  final apiService = ref.watch(apiProvider);
  return TeachersNotifier(apiService);
});
