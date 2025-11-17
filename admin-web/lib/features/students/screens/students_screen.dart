import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/export_utils.dart';
import '../providers/students_provider.dart';
import '../widgets/student_form_dialog.dart';
import '../widgets/student_table.dart';

class StudentsScreen extends ConsumerStatefulWidget {
  const StudentsScreen({super.key});

  @override
  ConsumerState<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends ConsumerState<StudentsScreen> {
  final _searchController = TextEditingController();
  String _selectedGrade = 'All';
  String _selectedStatus = 'All';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(studentsProvider.notifier).loadStudents();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final studentsState = ref.watch(studentsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Students Management'),
        actions: [
          IconButton(
            onPressed: () {
              ref.read(studentsProvider.notifier).refresh();
            },
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            icon: const Icon(Icons.download),
            tooltip: 'Export Data',
            onSelected: (value) => _handleExport(value, studentsState.students),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'csv',
                child: Row(
                  children: [
                    Icon(Icons.table_chart, size: 18),
                    SizedBox(width: 8),
                    Text('Export as CSV'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'excel',
                child: Row(
                  children: [
                    Icon(Icons.grid_on, size: 18),
                    SizedBox(width: 8),
                    Text('Export as Excel'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'json',
                child: Row(
                  children: [
                    Icon(Icons.code, size: 18),
                    SizedBox(width: 8),
                    Text('Export as JSON'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: () => _showAddStudentDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Add Student'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search and Filters
            _buildFilters(),
            const SizedBox(height: 24),

            // Error Message
            if (studentsState.error != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        studentsState.error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),

            // Students Table
            Expanded(
              child: studentsState.isLoading && studentsState.students.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : studentsState.students.isEmpty
                      ? _buildEmptyState()
                      : StudentTable(
                          students: studentsState.students,
                          onEdit: (student) => _showEditStudentDialog(student),
                          onDelete: (student) =>
                              _showDeleteConfirmation(student),
                          onToggleStatus: (student) =>
                              _toggleStudentStatus(student),
                        ),
            ),

            // Pagination
            if (studentsState.totalPages > 1) ...[
              const SizedBox(height: 16),
              _buildPagination(studentsState),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Row(
      children: [
        // Search
        Expanded(
          flex: 2,
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search by name, ID, or phone...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        ref
                            .read(studentsProvider.notifier)
                            .setSearchQuery('');
                      },
                    )
                  : null,
            ),
            onChanged: (value) {
              // Debounce search
              Future.delayed(const Duration(milliseconds: 500), () {
                if (_searchController.text == value) {
                  ref.read(studentsProvider.notifier).setSearchQuery(value);
                }
              });
            },
          ),
        ),
        const SizedBox(width: 16),

        // Grade Filter
        Expanded(
          child: DropdownButtonFormField<String>(
            value: _selectedGrade,
            decoration: const InputDecoration(
              labelText: 'Grade',
              prefixIcon: Icon(Icons.school),
            ),
            items: [
              'All',
              'Grade 6',
              'Grade 7',
              'Grade 8',
              'Grade 9',
              'Grade 10',
              'Grade 11',
              'Grade 12',
              'Grade 13'
            ].map((grade) {
              return DropdownMenuItem(
                value: grade,
                child: Text(grade),
              );
            }).toList(),
            onChanged: (value) {
              setState(() => _selectedGrade = value!);
              ref.read(studentsProvider.notifier).setGradeFilter(value);
            },
          ),
        ),
        const SizedBox(width: 16),

        // Status Filter
        Expanded(
          child: DropdownButtonFormField<String>(
            value: _selectedStatus,
            decoration: const InputDecoration(
              labelText: 'Status',
              prefixIcon: Icon(Icons.toggle_on),
            ),
            items: const [
              DropdownMenuItem(value: 'All', child: Text('All')),
              DropdownMenuItem(value: 'Active', child: Text('Active')),
              DropdownMenuItem(value: 'Inactive', child: Text('Inactive')),
            ],
            onChanged: (value) {
              setState(() => _selectedStatus = value!);
              final isActive =
                  value == 'All' ? null : (value == 'Active' ? true : false);
              ref.read(studentsProvider.notifier).setActiveFilter(isActive);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Card(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No students found',
              style: AppTheme.headingMedium.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first student to get started',
              style: AppTheme.bodyMedium.copyWith(
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showAddStudentDialog(),
              icon: const Icon(Icons.add),
              label: const Text('Add Student'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPagination(StudentsState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Showing ${((state.currentPage - 1) * 15) + 1} - ${(state.currentPage * 15 > state.totalStudents) ? state.totalStudents : (state.currentPage * 15)} of ${state.totalStudents} students',
              style: AppTheme.bodyMedium,
            ),
            Row(
              children: [
                IconButton(
                  onPressed: state.currentPage > 1
                      ? () => ref.read(studentsProvider.notifier).previousPage()
                      : null,
                  icon: const Icon(Icons.chevron_left),
                  tooltip: 'Previous',
                ),
                ...List.generate(
                  state.totalPages > 5 ? 5 : state.totalPages,
                  (index) {
                    int pageNumber;
                    if (state.totalPages <= 5) {
                      pageNumber = index + 1;
                    } else if (state.currentPage <= 3) {
                      pageNumber = index + 1;
                    } else if (state.currentPage >= state.totalPages - 2) {
                      pageNumber = state.totalPages - 4 + index;
                    } else {
                      pageNumber = state.currentPage - 2 + index;
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: TextButton(
                        onPressed: () => ref
                            .read(studentsProvider.notifier)
                            .goToPage(pageNumber),
                        style: TextButton.styleFrom(
                          backgroundColor: state.currentPage == pageNumber
                              ? AppTheme.primaryColor
                              : Colors.transparent,
                          foregroundColor: state.currentPage == pageNumber
                              ? Colors.white
                              : AppTheme.textPrimaryColor,
                        ),
                        child: Text('$pageNumber'),
                      ),
                    );
                  },
                ),
                IconButton(
                  onPressed: state.currentPage < state.totalPages
                      ? () => ref.read(studentsProvider.notifier).nextPage()
                      : null,
                  icon: const Icon(Icons.chevron_right),
                  tooltip: 'Next',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddStudentDialog() {
    showDialog(
      context: context,
      builder: (context) => StudentFormDialog(
        onSubmit: (data) async {
          final success =
              await ref.read(studentsProvider.notifier).createStudent(data);
          if (success && mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Student added successfully')),
            );
          }
        },
      ),
    );
  }

  void _showEditStudentDialog(student) {
    showDialog(
      context: context,
      builder: (context) => StudentFormDialog(
        student: student,
        onSubmit: (data) async {
          final success = await ref
              .read(studentsProvider.notifier)
              .updateStudent(student.id, data);
          if (success && mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Student updated successfully')),
            );
          }
        },
      ),
    );
  }

  void _showDeleteConfirmation(student) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Student'),
        content: Text(
          'Are you sure you want to delete ${student.displayName}? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await ref
                  .read(studentsProvider.notifier)
                  .deleteStudent(student.id);
              if (success && mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Student deleted successfully')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _toggleStudentStatus(student) async {
    final success = await ref
        .read(studentsProvider.notifier)
        .toggleStudentStatus(student.id);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Student ${student.isActive ? "deactivated" : "activated"} successfully',
          ),
        ),
      );
    }
  }

  void _handleExport(String format, List<dynamic> students) {
    if (students.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No data to export')),
      );
      return;
    }

    final filename = 'students_${DateTime.now().millisecondsSinceEpoch}';

    // Convert students to Map if they are model objects
    final studentsData = students.map((s) {
      if (s is Map<String, dynamic>) {
        return s;
      } else {
        // If it's a model object, convert to Map
        return {
          'id': s.id,
          'user': {
            'name': s.user?.name,
            'email': s.user?.email,
            'phone': s.user?.phone,
          },
          'student_id': s.studentId,
          'grade': s.grade,
          'date_of_birth': s.dateOfBirth,
          'guardian_name': s.guardianName,
          'guardian_phone': s.guardianPhone,
          'is_active': s.isActive,
        };
      }
    }).toList();

    switch (format) {
      case 'csv':
        ExportUtils.exportToCSV(
          data: studentsData.cast<Map<String, dynamic>>(),
          headers: [
            'ID',
            'Name',
            'Student ID',
            'Email',
            'Phone',
            'Grade',
            'Guardian Name',
            'Guardian Phone',
            'Status'
          ],
          keys: [
            'id',
            'user.name',
            'student_id',
            'user.email',
            'user.phone',
            'grade',
            'guardian_name',
            'guardian_phone',
            'is_active'
          ],
          filename: filename,
        );
        break;
      case 'excel':
        ExportUtils.exportToExcel(
          data: studentsData.cast<Map<String, dynamic>>(),
          headers: [
            'ID',
            'Name',
            'Student ID',
            'Email',
            'Phone',
            'Grade',
            'Guardian Name',
            'Guardian Phone',
            'Status'
          ],
          keys: [
            'id',
            'user.name',
            'student_id',
            'user.email',
            'user.phone',
            'grade',
            'guardian_name',
            'guardian_phone',
            'is_active'
          ],
          filename: filename,
        );
        break;
      case 'json':
        ExportUtils.exportToJSON(
          data: studentsData.cast<Map<String, dynamic>>(),
          filename: filename,
        );
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Exported as ${format.toUpperCase()}')),
    );
  }
}
