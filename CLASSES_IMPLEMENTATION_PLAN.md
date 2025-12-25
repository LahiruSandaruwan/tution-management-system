# Classes Feature - Complete Implementation Plan

## Overview
This document outlines the complete implementation of the Classes feature with proper state management, full CRUD operations, student enrollment, and teacher assignment.

## ✅ Already Completed

1. **Models Created**
   - `lib/models/class_model.dart` - ClassModel, Subject models
   - `lib/models/class_model.g.dart` - Auto-generated JSON serialization
   - `lib/models/attendance.dart` - For future attendance integration

2. **Existing Components**
   - `lib/features/classes/screens/classes_screen.dart` - Basic screen (needs refactoring)
   - `lib/features/classes/widgets/class_form_dialog.dart` - Basic form dialog

## 📋 Implementation Tasks

### 1. Create Classes Provider (`lib/features/classes/providers/classes_provider.dart`)

```dart
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
    state = state.copyWith(selectedClass: classModel);
  }
}

final classesProvider = StateNotifierProvider<ClassesNotifier, ClassesState>((ref) {
  final apiService = ref.watch(apiProvider);
  return ClassesNotifier(apiService);
});
```

### 2. Add API Methods to ApiService (`lib/services/api_service.dart`)

Add these methods to the ApiService class:

```dart
// Classes
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

Future<void> enrollStudentInClass(int classId, int studentId) async {
  await _dio.post('/classes/$classId/enroll', data: {'student_id': studentId});
}

Future<void> removeStudentFromClass(int classId, int studentId) async {
  await _dio.delete('/classes/$classId/students/$studentId');
}

// Subjects
Future<List<Subject>> getSubjects() async {
  final response = await _dio.get('/subjects');
  return (response.data['data'] as List)
      .map((json) => Subject.fromJson(json))
      .toList();
}
```

### 3. Create Enrollment Dialog Widget (`lib/features/classes/widgets/enrollment_dialog.dart`)

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/class_model.dart';
import '../../../models/student.dart';
import '../../../providers/api_provider.dart';

class EnrollmentDialog extends ConsumerStatefulWidget {
  final ClassModel classModel;

  const EnrollmentDialog({super.key, required this.classModel});

  @override
  ConsumerState<EnrollmentDialog> createState() => _EnrollmentDialogState();
}

class _EnrollmentDialogState extends ConsumerState<EnrollmentDialog> {
  List<Student> _availableStudents = [];
  List<Student> _enrolledStudents = [];
  bool _isLoading = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    setState(() => _isLoading = true);
    try {
      final apiService = ref.read(apiProvider);
      final allStudents = await apiService.getStudents();
      final enrolledIds = widget.classModel.students?.map((s) => s.id).toSet() ?? {};

      setState(() {
        _enrolledStudents = allStudents.where((s) => enrolledIds.contains(s.id)).toList();
        _availableStudents = allStudents.where((s) => !enrolledIds.contains(s.id)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  List<Student> get filteredAvailable {
    if (_searchQuery.isEmpty) return _availableStudents;
    return _availableStudents.where((s) =>
      s.user.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      s.registrationNumber.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 800,
        height: 600,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Manage Enrollment - ${widget.classModel.name}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Search
            TextField(
              decoration: const InputDecoration(
                labelText: 'Search Students',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
            const SizedBox(height: 16),
            // Lists
            Expanded(
              child: Row(
                children: [
                  // Available Students
                  Expanded(
                    child: _buildStudentList(
                      title: 'Available (${filteredAvailable.length})',
                      students: filteredAvailable,
                      trailing: (student) => IconButton(
                        icon: const Icon(Icons.add_circle, color: Colors.green),
                        onPressed: () => _enrollStudent(student),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Enrolled Students
                  Expanded(
                    child: _buildStudentList(
                      title: 'Enrolled (${_enrolledStudents.length})',
                      students: _enrolledStudents,
                      trailing: (student) => IconButton(
                        icon: const Icon(Icons.remove_circle, color: Colors.red),
                        onPressed: () => _unenrollStudent(student),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentList({
    required String title,
    required List<Student> students,
    required Widget Function(Student) trailing,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: students.length,
                    itemBuilder: (context, index) {
                      final student = students[index];
                      return ListTile(
                        leading: CircleAvatar(
                          child: Text(student.user.name[0].toUpperCase()),
                        ),
                        title: Text(student.user.name),
                        subtitle: Text(student.registrationNumber),
                        trailing: trailing(student),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }

  Future<void> _enrollStudent(Student student) async {
    // Implementation will use provider
  }

  Future<void> _unenrollStudent(Student student) async {
    // Implementation will use provider
  }
}
```

### 4. Refactor Classes Screen

Update `lib/features/classes/screens/classes_screen.dart` to use the provider:

Key changes:
- Replace direct API calls with provider methods
- Add proper loading and error states
- Integrate enrollment dialog
- Add filters and search

### 5. Update Class Form Dialog

Enhance `lib/features/classes/widgets/class_form_dialog.dart`:
- Add subject selection dropdown
- Add teacher selection dropdown
- Add time pickers for start/end time
- Add day selection
- Proper validation

## Testing Checklist

- [ ] Load all classes on screen init
- [ ] Create new class with all fields
- [ ] Update existing class
- [ ] Delete class
- [ ] Enroll student in class
- [ ] Remove student from class
- [ ] Search and filter functionality
- [ ] Loading states display correctly
- [ ] Error handling works
- [ ] Navigation between screens

## Next Steps After Classes

1. **Attendance Feature** - Now that classes are ready
2. **Reports** - Generate class-specific reports
3. **Dashboard Enhancement** - Add class statistics

## Notes

- Backend APIs already exist in Laravel (routes/api.php)
- Models already have JSON serialization
- Focus on clean, maintainable code
- Follow existing patterns from Students/Teachers features
