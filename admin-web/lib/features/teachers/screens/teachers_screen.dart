import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/teachers_provider.dart';
import '../widgets/teacher_form_dialog.dart';

class TeachersScreen extends ConsumerStatefulWidget {
  const TeachersScreen({super.key});

  @override
  ConsumerState<TeachersScreen> createState() => _TeachersScreenState();
}

class _TeachersScreenState extends ConsumerState<TeachersScreen> {
  final _searchController = TextEditingController();
  String _selectedStatus = 'All';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(teachersProvider.notifier).loadTeachers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final teachersState = ref.watch(teachersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Teacher Management'),
        actions: [
          IconButton(
            onPressed: () {
              ref.read(teachersProvider.notifier).refresh();
            },
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: () => _showAddTeacherDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Add Teacher'),
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
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search teachers by name or employee ID...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                ref
                                    .read(teachersProvider.notifier)
                                    .setSearchQuery('');
                              },
                            )
                          : null,
                    ),
                    onChanged: (value) {
                      Future.delayed(const Duration(milliseconds: 500), () {
                        if (_searchController.text == value) {
                          ref
                              .read(teachersProvider.notifier)
                              .setSearchQuery(value);
                        }
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
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
                      DropdownMenuItem(
                          value: 'Inactive', child: Text('Inactive')),
                    ],
                    onChanged: (value) {
                      setState(() => _selectedStatus = value!);
                      final isActive = value == 'All'
                          ? null
                          : (value == 'Active' ? true : false);
                      ref
                          .read(teachersProvider.notifier)
                          .setActiveFilter(isActive);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Error Message
            if (teachersState.error != null)
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
                        teachersState.error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),

            // Teachers Table
            Expanded(
              child: teachersState.isLoading && teachersState.teachers.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : teachersState.teachers.isEmpty
                      ? _buildEmptyState()
                      : _buildTeachersTable(teachersState.teachers),
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
              Icons.person_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No teachers found',
              style: AppTheme.headingMedium.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first teacher to get started',
              style: AppTheme.bodyMedium.copyWith(
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showAddTeacherDialog(),
              icon: const Icon(Icons.add),
              label: const Text('Add Teacher'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeachersTable(List<dynamic> teachers) {
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
              DataColumn(
                  label: Text('ID',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text('Name',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text('Employee ID',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text('Specialization',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text('Email',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text('Phone',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text('Status',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text('Actions',
                      style: TextStyle(fontWeight: FontWeight.bold))),
            ],
            rows: teachers.map((teacher) {
              final isActive = teacher['is_active'] ?? true;
              final name = teacher['user']?['name'] ?? 'N/A';
              final email = teacher['user']?['email'] ?? 'N/A';
              final phone = teacher['user']?['phone'] ?? 'N/A';

              return DataRow(
                cells: [
                  DataCell(Text('#${teacher['id']}')),
                  DataCell(
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: AppTheme.primaryColor,
                          child: Text(
                            name.substring(0, 1).toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(name),
                      ],
                    ),
                  ),
                  DataCell(Text(teacher['employee_id'] ?? 'N/A')),
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
                        teacher['specialization'] ?? 'N/A',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  DataCell(Text(email)),
                  DataCell(Text(phone)),
                  DataCell(
                    Switch(
                      value: isActive,
                      onChanged: (_) => _toggleTeacherStatus(teacher),
                      activeColor: AppTheme.successColor,
                    ),
                  ),
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, size: 20),
                          onPressed: () => _showEditTeacherDialog(teacher),
                          tooltip: 'Edit',
                          color: AppTheme.primaryColor,
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, size: 20),
                          onPressed: () => _showDeleteConfirmation(teacher),
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

  void _showAddTeacherDialog() {
    showDialog(
      context: context,
      builder: (context) => TeacherFormDialog(
        onSubmit: (data) async {
          final success =
              await ref.read(teachersProvider.notifier).createTeacher(data);
          if (success && mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Teacher added successfully')),
            );
          }
        },
      ),
    );
  }

  void _showEditTeacherDialog(dynamic teacher) {
    showDialog(
      context: context,
      builder: (context) => TeacherFormDialog(
        teacher: teacher,
        onSubmit: (data) async {
          final success = await ref
              .read(teachersProvider.notifier)
              .updateTeacher(teacher['id'], data);
          if (success && mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Teacher updated successfully')),
            );
          }
        },
      ),
    );
  }

  void _showDeleteConfirmation(dynamic teacher) {
    final name = teacher['user']?['name'] ?? 'this teacher';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Teacher'),
        content: Text(
          'Are you sure you want to delete $name? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await ref
                  .read(teachersProvider.notifier)
                  .deleteTeacher(teacher['id']);
              if (success && mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Teacher deleted successfully')),
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

  void _toggleTeacherStatus(dynamic teacher) async {
    final success = await ref
        .read(teachersProvider.notifier)
        .toggleTeacherStatus(teacher['id']);
    if (success && mounted) {
      final isActive = teacher['is_active'] ?? true;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Teacher ${isActive ? "deactivated" : "activated"} successfully',
          ),
        ),
      );
    }
  }
}
