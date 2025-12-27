import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/class_model.dart';
import '../../../models/student.dart';
import '../providers/classes_provider.dart';
import '../../students/providers/students_provider.dart';

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
      await ref.read(studentsProvider.notifier).loadStudents();
      final studentsState = ref.read(studentsProvider);
      final allStudents = studentsState.students;
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
          SnackBar(content: Text('Error loading students: $e')),
        );
      }
    }
  }

  List<Student> get filteredAvailable {
    if (_searchQuery.isEmpty) return _availableStudents;
    return _availableStudents.where((s) =>
      (s.user?.name ?? '').toLowerCase().contains(_searchQuery.toLowerCase()) ||
      s.studentIdNumber.toLowerCase().contains(_searchQuery.toLowerCase())
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
            TextField(
              decoration: const InputDecoration(
                labelText: 'Search Students',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Row(
                children: [
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
                : students.isEmpty
                    ? const Center(child: Text('No students'))
                    : ListView.builder(
                        itemCount: students.length,
                        itemBuilder: (context, index) {
                          final student = students[index];
                          return ListTile(
                            leading: CircleAvatar(
                              child: Text((student.user?.name ?? 'U')[0].toUpperCase()),
                            ),
                            title: Text(student.user?.name ?? 'Unknown'),
                            subtitle: Text(student.studentIdNumber),
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
    try {
      await ref.read(classesProvider.notifier).enrollStudent(
        widget.classModel.id,
        student.id,
      );

      setState(() {
        _availableStudents.remove(student);
        _enrolledStudents.add(student);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${student.user?.name ?? "Student"} enrolled successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error enrolling student: $e')),
        );
      }
    }
  }

  Future<void> _unenrollStudent(Student student) async {
    try {
      await ref.read(classesProvider.notifier).removeStudent(
        widget.classModel.id,
        student.id,
      );

      setState(() {
        _enrolledStudents.remove(student);
        _availableStudents.add(student);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${student.user?.name ?? "Student"} removed successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error removing student: $e')),
        );
      }
    }
  }
}
