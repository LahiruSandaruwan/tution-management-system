import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/class.dart';
import '../../../providers/api_provider.dart';

class MarkAttendanceScreen extends ConsumerStatefulWidget {
  final TeacherClass teacherClass;

  const MarkAttendanceScreen({
    super.key,
    required this.teacherClass,
  });

  @override
  ConsumerState<MarkAttendanceScreen> createState() => _MarkAttendanceScreenState();
}

class _MarkAttendanceScreenState extends ConsumerState<MarkAttendanceScreen> {
  DateTime _selectedDate = DateTime.now();
  List<ClassStudent> _students = [];
  Map<int, String> _attendanceStatus = {};
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final apiService = ref.read(apiProvider);
      final students = await apiService.getClassStudents(widget.teacherClass.id);

      setState(() {
        _students = students;
        // Initialize all students as present by default
        _attendanceStatus = {
          for (var student in students) student.id: 'present'
        };
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load students: ${e.toString()}';
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_errorMessage!),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  void _toggleAttendance(int studentId) {
    setState(() {
      final currentStatus = _attendanceStatus[studentId] ?? 'absent';
      if (currentStatus == 'present') {
        _attendanceStatus[studentId] = 'absent';
      } else if (currentStatus == 'absent') {
        _attendanceStatus[studentId] = 'late';
      } else {
        _attendanceStatus[studentId] = 'present';
      }
    });
  }

  void _markAllPresent() {
    setState(() {
      for (var student in _students) {
        _attendanceStatus[student.id] = 'present';
      }
    });
  }

  Future<void> _saveAttendance() async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final apiService = ref.read(apiProvider);
      final dateString = DateFormat('yyyy-MM-dd').format(_selectedDate);

      // Prepare attendance data in the format expected by the API
      final attendanceData = _students.map((student) {
        final status = _attendanceStatus[student.id] ?? 'present';
        return {
          'student_id': student.id,
          'status': status,
          if (status == 'late') 'check_in_time': TimeOfDay.now().format(context),
        };
      }).toList();

      await apiService.bulkMarkAttendance(
        classId: widget.teacherClass.id,
        date: dateString,
        attendanceData: attendanceData,
      );

      setState(() {
        _isSaving = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Attendance saved successfully'),
            backgroundColor: AppTheme.successColor,
          ),
        );

        // Navigate back after successful save
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      setState(() {
        _isSaving = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save attendance: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final presentCount = _attendanceStatus.values.where((s) => s == 'present').length;
    final absentCount = _attendanceStatus.values.where((s) => s == 'absent').length;
    final lateCount = _attendanceStatus.values.where((s) => s == 'late').length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mark Attendance'),
        actions: [
          if (!_isLoading)
            TextButton(
              onPressed: _markAllPresent,
              child: const Text('Mark All Present'),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: AppTheme.errorColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: AppTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadStudents,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Date and Class Selector
                    Container(
                      padding: const EdgeInsets.all(16),
                      color: AppTheme.cardColor,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () async {
                                    final date = await showDatePicker(
                                      context: context,
                                      initialDate: _selectedDate,
                                      firstDate: DateTime.now().subtract(const Duration(days: 365)),
                                      lastDate: DateTime.now(),
                                    );
                                    if (date != null) {
                                      setState(() {
                                        _selectedDate = date;
                                      });
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey.shade300),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.calendar_today, size: 20),
                                        const SizedBox(width: 12),
                                        Text(
                                          DateFormat('dd/MM/yyyy').format(_selectedDate),
                                          style: AppTheme.titleMedium,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.class_, size: 20),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    '${widget.teacherClass.grade} - ${widget.teacherClass.subjectName ?? 'Class'}',
                                    style: AppTheme.titleMedium,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Summary Stats
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildStatChip('Present', presentCount, AppTheme.successColor),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildStatChip('Absent', absentCount, AppTheme.errorColor),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildStatChip('Late', lateCount, AppTheme.warningColor),
                          ),
                        ],
                      ),
                    ),

                    // Student List
                    Expanded(
                      child: _students.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.group_off,
                                    size: 64,
                                    color: Colors.grey.shade400,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No students enrolled in this class',
                                    style: AppTheme.bodyMedium.copyWith(
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: _students.length,
                              itemBuilder: (context, index) {
                                final student = _students[index];
                                final status = _attendanceStatus[student.id] ?? 'absent';

                                return _buildStudentTile(
                                  studentId: student.id,
                                  name: student.userName ?? 'Unknown Student',
                                  studentIdNumber: student.studentIdNumber,
                                  status: status,
                                  onTap: () => _toggleAttendance(student.id),
                                );
                              },
                            ),
                    ),

                    // Save Button
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _students.isEmpty || _isSaving ? null : _saveAttendance,
                          icon: _isSaving
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Icon(Icons.save),
                          label: Text(_isSaving ? 'Saving...' : 'Save Attendance'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildStatChip(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentTile({
    required int studentId,
    required String name,
    required String studentIdNumber,
    required String status,
    required VoidCallback onTap,
  }) {
    Color statusColor;
    IconData statusIcon;

    if (status == 'present') {
      statusColor = AppTheme.successColor;
      statusIcon = Icons.check_circle;
    } else if (status == 'late') {
      statusColor = AppTheme.warningColor;
      statusIcon = Icons.access_time;
    } else {
      statusColor = AppTheme.errorColor;
      statusIcon = Icons.cancel;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.1),
          child: Icon(statusIcon, color: statusColor),
        ),
        title: Text(name, style: AppTheme.titleMedium),
        subtitle: Text(studentIdNumber, style: AppTheme.bodySmall),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            status.toUpperCase(),
            style: TextStyle(
              color: statusColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
