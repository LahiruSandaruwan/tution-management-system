import 'package:flutter/material.dart';
import '../../../models/student.dart';
import '../../../core/theme/app_theme.dart';
import 'package:intl/intl.dart';

class StudentTable extends StatelessWidget {
  final List<Student> students;
  final Function(Student) onEdit;
  final Function(Student) onDelete;
  final Function(Student) onToggleStatus;

  const StudentTable({
    super.key,
    required this.students,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          child: DataTable(
            columnSpacing: 24,
            headingRowColor: MaterialStateProperty.all(
              AppTheme.primaryColor.withOpacity(0.1),
            ),
            columns: const [
              DataColumn(label: Text('ID', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Name', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Student ID', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Grade', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Phone', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Parent Name', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Parent Phone', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Date of Birth', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
            ],
            rows: students.map((student) {
              return DataRow(
                cells: [
                  DataCell(Text('#${student.id}')),
                  DataCell(
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: AppTheme.primaryColor,
                          child: Text(
                            student.displayName.substring(0, 1).toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(student.displayName),
                      ],
                    ),
                  ),
                  DataCell(Text(student.studentIdNumber)),
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.secondaryColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        student.grade,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  DataCell(Text(student.user?.phone ?? 'N/A')),
                  DataCell(Text(student.parentName ?? 'N/A')),
                  DataCell(Text(student.parentPhone ?? 'N/A')),
                  DataCell(
                    Text(
                      student.dateOfBirth != null
                          ? DateFormat('yyyy-MM-dd').format(student.dateOfBirth!)
                          : 'N/A',
                    ),
                  ),
                  DataCell(
                    Switch(
                      value: student.isActive,
                      onChanged: (_) => onToggleStatus(student),
                      activeColor: AppTheme.successColor,
                    ),
                  ),
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, size: 20),
                          onPressed: () => onEdit(student),
                          tooltip: 'Edit',
                          color: AppTheme.primaryColor,
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, size: 20),
                          onPressed: () => onDelete(student),
                          tooltip: 'Delete',
                          color: AppTheme.errorColor,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
