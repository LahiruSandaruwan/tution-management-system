import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';

class MarkAttendanceScreen extends ConsumerStatefulWidget {
  const MarkAttendanceScreen({super.key});

  @override
  ConsumerState<MarkAttendanceScreen> createState() => _MarkAttendanceScreenState();
}

class _MarkAttendanceScreenState extends ConsumerState<MarkAttendanceScreen> {
  DateTime _selectedDate = DateTime.now();
  int _selectedClassId = 1;

  // Sample student attendance data
  final Map<int, String> _attendanceStatus = {
    1: 'present',
    2: 'present',
    3: 'absent',
    4: 'late',
    5: 'present',
  };

  final List<Map<String, dynamic>> _students = [
    {'id': 1, 'name': 'Kasun Rajapaksa', 'studentId': 'STU001'},
    {'id': 2, 'name': 'Nimal Perera', 'studentId': 'STU002'},
    {'id': 3, 'name': 'Saman Silva', 'studentId': 'STU003'},
    {'id': 4, 'name': 'Dilini Fernando', 'studentId': 'STU004'},
    {'id': 5, 'name': 'Hasini Kumari', 'studentId': 'STU005'},
  ];

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
        _attendanceStatus[student['id'] as int] = 'present';
      }
    });
  }

  void _saveAttendance() {
    // TODO: Save attendance to API
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Attendance saved successfully'),
        backgroundColor: AppTheme.successColor,
      ),
    );
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
          TextButton(
            onPressed: _markAllPresent,
            child: const Text('Mark All Present'),
          ),
        ],
      ),
      body: Column(
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
                                '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
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
                      Text(
                        'Grade 10 - Mathematics',
                        style: AppTheme.titleMedium,
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
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _students.length,
              itemBuilder: (context, index) {
                final student = _students[index];
                final studentId = student['id'] as int;
                final status = _attendanceStatus[studentId] ?? 'absent';

                return _buildStudentTile(
                  studentId: studentId,
                  name: student['name'] as String,
                  studentIdNumber: student['studentId'] as String,
                  status: status,
                  onTap: () => _toggleAttendance(studentId),
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
                onPressed: _saveAttendance,
                icon: const Icon(Icons.save),
                label: const Text('Save Attendance'),
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
