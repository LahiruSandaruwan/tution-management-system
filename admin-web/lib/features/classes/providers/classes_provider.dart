import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/class_model.dart';
import '../../../services/api_service.dart';
import '../../../providers/api_provider.dart';

class ClassesState {
  final List<ClassModel> classes;
  final bool isLoading;
  final String? error;
  final ClassModel? selectedClass;

  ClassesState({
    this.classes = const [],
    this.isLoading = false,
    this.error,
    this.selectedClass,
  });

  ClassesState copyWith({
    List<ClassModel>? classes,
    bool? isLoading,
    String? error,
    ClassModel? selectedClass,
    bool clearError = false,
    bool clearSelected = false,
  }) {
    return ClassesState(
      classes: classes ?? this.classes,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      selectedClass: clearSelected ? null : (selectedClass ?? this.selectedClass),
    );
  }
}

class ClassesNotifier extends StateNotifier<ClassesState> {
  final ApiService _apiService;

  ClassesNotifier(this._apiService) : super(ClassesState());

  Future<void> loadClasses() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final classes = await _apiService.getClasses();
      state = state.copyWith(
        classes: classes,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refresh() async {
    await loadClasses();
  }

  Future<void> createClass(Map<String, dynamic> data) async {
    try {
      final newClass = await _apiService.createClass(data);
      state = state.copyWith(
        classes: [...state.classes, newClass],
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<void> updateClass(int id, Map<String, dynamic> data) async {
    try {
      final updatedClass = await _apiService.updateClass(id, data);
      state = state.copyWith(
        classes: state.classes.map((c) => c.id == id ? updatedClass : c).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<void> deleteClass(int id) async {
    try {
      await _apiService.deleteClass(id);
      state = state.copyWith(
        classes: state.classes.where((c) => c.id != id).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<void> enrollStudent(int classId, int studentId) async {
    try {
      await _apiService.enrollStudentInClass(classId, studentId);
      await loadClasses(); // Refresh to get updated student count
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<void> removeStudent(int classId, int studentId) async {
    try {
      await _apiService.removeStudentFromClass(classId, studentId);
      await loadClasses(); // Refresh
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  void selectClass(ClassModel? classModel) {
    state = state.copyWith(
      selectedClass: classModel,
      clearSelected: classModel == null,
    );
  }
}

final classesProvider = StateNotifierProvider<ClassesNotifier, ClassesState>((ref) {
  final apiService = ref.watch(apiProvider);
  return ClassesNotifier(apiService);
});
