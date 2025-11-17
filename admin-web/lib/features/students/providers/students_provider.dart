import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/student.dart';
import '../../../services/api_service.dart';
import '../../../providers/api_provider.dart';

class StudentsState {
  final bool isLoading;
  final String? error;
  final StudentPaginatedData? paginatedData;
  final int currentPage;
  final String? searchQuery;
  final bool? activeFilter;
  final String? gradeFilter;

  StudentsState({
    this.isLoading = false,
    this.error,
    this.paginatedData,
    this.currentPage = 1,
    this.searchQuery,
    this.activeFilter,
    this.gradeFilter,
  });

  StudentsState copyWith({
    bool? isLoading,
    String? error,
    StudentPaginatedData? paginatedData,
    int? currentPage,
    String? searchQuery,
    bool? activeFilter,
    String? gradeFilter,
    bool clearError = false,
  }) {
    return StudentsState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      paginatedData: paginatedData ?? this.paginatedData,
      currentPage: currentPage ?? this.currentPage,
      searchQuery: searchQuery ?? this.searchQuery,
      activeFilter: activeFilter ?? this.activeFilter,
      gradeFilter: gradeFilter ?? this.gradeFilter,
    );
  }

  List<Student> get students => paginatedData?.data ?? [];
  int get totalPages => paginatedData?.lastPage ?? 1;
  int get totalStudents => paginatedData?.total ?? 0;
}

class StudentsNotifier extends StateNotifier<StudentsState> {
  final ApiService _apiService;

  StudentsNotifier(this._apiService) : super(StudentsState());

  Future<void> loadStudents({
    int? page,
    String? search,
    bool? isActive,
    String? grade,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final response = await _apiService.getStudents(
        page: page ?? state.currentPage,
        search: search ?? state.searchQuery,
        isActive: isActive ?? state.activeFilter,
        grade: grade ?? state.gradeFilter,
      );

      state = state.copyWith(
        isLoading: false,
        paginatedData: response.data,
        currentPage: page ?? state.currentPage,
        searchQuery: search,
        activeFilter: isActive,
        gradeFilter: grade,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refresh() async {
    await loadStudents(page: state.currentPage);
  }

  Future<void> nextPage() async {
    if (state.currentPage < state.totalPages) {
      await loadStudents(page: state.currentPage + 1);
    }
  }

  Future<void> previousPage() async {
    if (state.currentPage > 1) {
      await loadStudents(page: state.currentPage - 1);
    }
  }

  Future<void> goToPage(int page) async {
    if (page >= 1 && page <= state.totalPages) {
      await loadStudents(page: page);
    }
  }

  Future<void> setSearchQuery(String query) async {
    await loadStudents(page: 1, search: query.isEmpty ? null : query);
  }

  Future<void> setActiveFilter(bool? isActive) async {
    await loadStudents(page: 1, isActive: isActive);
  }

  Future<void> setGradeFilter(String? grade) async {
    await loadStudents(page: 1, grade: grade == 'All' ? null : grade);
  }

  Future<bool> createStudent(Map<String, dynamic> data) async {
    try {
      await _apiService.createStudent(data);
      await refresh();
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> updateStudent(int id, Map<String, dynamic> data) async {
    try {
      await _apiService.updateStudent(id, data);
      await refresh();
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> deleteStudent(int id) async {
    try {
      await _apiService.deleteStudent(id);
      await refresh();
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> toggleStudentStatus(int id) async {
    try {
      await _apiService.toggleStudentStatus(id);
      await refresh();
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }
}

final studentsProvider =
    StateNotifierProvider<StudentsNotifier, StudentsState>((ref) {
  final apiService = ref.watch(apiProvider);
  return StudentsNotifier(apiService);
});
