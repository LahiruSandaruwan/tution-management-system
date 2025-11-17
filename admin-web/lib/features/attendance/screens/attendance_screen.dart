import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/api_provider.dart';
import '../../../models/student.dart';
import 'package:intl/intl.dart';

class AttendanceScreen extends ConsumerStatefulWidget {
  const AttendanceScreen({super.key});

  @override
  ConsumerState<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends ConsumerState<AttendanceScreen> {
  DateTime _selectedDate = DateTime.now();
  List<dynamic> _classes = [];
  dynamic _selectedClass;
  List<Student> _students = [];
  Map<int, String> _attendanceStatus = {}; // student_id -> status
  bool _isLoading = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadClasses();
  }

  Future<void> _loadClasses() async {
    setState(() => _isLoading = true);
    try {
      final apiService = ref.read(apiProvider);
      final classes = await apiService.getClasses();
      setState(() {
        _classes = classes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading classes: $e')),
        );
      }
    }
  }

  Future<void> _loadStudents() async {
    if (_selectedClass == null) return;

    setState(() => _isLoading = true);
    try {
      final apiService = ref.read(apiProvider);
      final response = await apiService.getStudents(page: 1, perPage: 1000);
      setState(() {
        _students = response.data?.data ?? [];
        // Initialize all as present by default
        for (var student in _students) {
          _attendanceStatus[student.id] = 'present';
        }
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

  Future<void> _submitAttendance() async {
    if (_students.isEmpty) return;

    setState(() => _isSubmitting = true);
    try {
      final apiService = ref.read(apiProvider);
      final attendanceRecords = _attendanceStatus.entries.map((entry) {
        return {
          'student_id': entry.key,
          'status': entry.value,
          'date': DateFormat('yyyy-MM-dd').format(_selectedDate),
        };
      }).toList();

      await apiService.markBulkAttendance({
        'date': DateFormat('yyyy-MM-dd').format(_selectedDate),
        'attendance': attendanceRecords,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Attendance marked successfully!')),
        );
        setState(() {
          _students = [];
          _attendanceStatus = {};
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error marking attendance: $e')),
        );
      }
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mark Attendance'),
        actions: [
          if (_students.isNotEmpty) ...[
            OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  for (var student in _students) {
                    _attendanceStatus[student.id] = 'present';
                  }
                });
              },
              icon: const Icon(Icons.check_circle),
              label: const Text('Mark All Present'),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  for (var student in _students) {
                    _attendanceStatus[student.id] = 'absent';
                  }
                });
              },
              icon: const Icon(Icons.cancel),
              label: const Text('Mark All Absent'),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: _isSubmitting ? null : _submitAttendance,
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              label: const Text('Submit Attendance'),
            ),
          ],
          const SizedBox(width: 16),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date and Class Selection
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setState(() => _selectedDate = date);
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Date',
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        DateFormat('yyyy-MM-dd').format(_selectedDate),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<dynamic>(
                    value: _selectedClass,
                    decoration: const InputDecoration(
                      labelText: 'Class',
                      prefixIcon: Icon(Icons.class_),
                    ),
                    items: _classes.map((cls) {
                      return DropdownMenuItem(
                        value: cls,
                        child: Text(cls['name'] ?? 'Unknown Class'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedClass = value;
                        _students = [];
                        _attendanceStatus = {};
                      });
                      _loadStudents();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Students List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _students.isEmpty
                      ? _buildEmptyState()
                      : _buildStudentsList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Card(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.how_to_reg_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _selectedClass == null
                  ? 'Select a class to mark attendance'
                  : 'No students found',
              style: AppTheme.headingMedium.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentsList() {
    return Card(
      child: ListView.builder(
        itemCount: _students.length,
        itemBuilder: (context, index) {
          final student = _students[index];
          final status = _attendanceStatus[student.id] ?? 'present';

          return ListTile(
            leading: CircleAvatar(
              backgroundColor: _getStatusColor(status),
              child: Text(
                student.displayName.substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(student.displayName),
            subtitle: Text('${student.studentIdNumber} - ${student.grade}'),
            trailing: SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'present',
                  label: Text('Present'),
                  icon: Icon(Icons.check_circle_outline, size: 16),
                ),
                ButtonSegment(
                  value: 'absent',
                  label: Text('Absent'),
                  icon: Icon(Icons.cancel_outlined, size: 16),
                ),
                ButtonSegment(
                  value: 'late',
                  label: Text('Late'),
                  icon: Icon(Icons.access_time, size: 16),
                ),
              ],
              selected: {status},
              onSelectionChanged: (Set<String> newSelection) {
                setState(() {
                  _attendanceStatus[student.id] = newSelection.first;
                });
              },
            ),
          );
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'present':
        return AppTheme.successColor;
      case 'absent':
        return AppTheme.errorColor;
      case 'late':
        return AppTheme.warningColor;
      default:
        return Colors.grey;
    }
  }
}
