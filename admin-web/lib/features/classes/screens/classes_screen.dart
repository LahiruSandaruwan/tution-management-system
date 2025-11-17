import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/api_provider.dart';

class ClassesScreen extends ConsumerStatefulWidget {
  const ClassesScreen({super.key});

  @override
  ConsumerState<ClassesScreen> createState() => _ClassesScreenState();
}

class _ClassesScreenState extends ConsumerState<ClassesScreen> {
  List<dynamic> _classes = [];
  bool _isLoading = false;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Class Management'),
        actions: [
          IconButton(
            onPressed: _loadClasses,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: () => _showAddClassDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Add Class'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _classes.isEmpty
              ? _buildEmptyState()
              : Padding(
                  padding: const EdgeInsets.all(24),
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.3,
                    ),
                    itemCount: _classes.length,
                    itemBuilder: (context, index) {
                      final classItem = _classes[index];
                      return _buildClassCard(classItem);
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.class_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No classes found',
            style: AppTheme.headingMedium.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first class to get started',
            style: AppTheme.bodyMedium.copyWith(
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddClassDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Add Class'),
          ),
        ],
      ),
    );
  }

  Widget _buildClassCard(dynamic classItem) {
    final name = classItem['name'] ?? 'Unnamed Class';
    final subject = classItem['subject'] ?? 'N/A';
    final grade = classItem['grade'] ?? 'N/A';
    final teacherName = classItem['teacher']?['user']?['name'] ?? 'No Teacher';
    final studentCount = classItem['students_count'] ?? 0;

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => _showClassDetails(classItem),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.class_,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const Spacer(),
                  PopupMenuButton(
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 18),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 18, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'edit') {
                        _showEditClassDialog(classItem);
                      } else if (value == 'delete') {
                        _showDeleteConfirmation(classItem);
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                name,
                style: AppTheme.titleLarge,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                subject,
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              const Divider(),
              Row(
                children: [
                  const Icon(Icons.school, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(grade, style: AppTheme.bodySmall),
                  const Spacer(),
                  const Icon(Icons.person, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text('$studentCount', style: AppTheme.bodySmall),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Teacher: $teacherName',
                style: AppTheme.bodySmall.copyWith(color: Colors.grey[600]),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showClassDetails(dynamic classItem) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(classItem['name'] ?? 'Class Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Subject:', classItem['subject'] ?? 'N/A'),
            _buildDetailRow('Grade:', classItem['grade'] ?? 'N/A'),
            _buildDetailRow('Teacher:',
                classItem['teacher']?['user']?['name'] ?? 'No Teacher'),
            _buildDetailRow(
                'Students:', '${classItem['students_count'] ?? 0}'),
            if (classItem['schedule'] != null)
              _buildDetailRow('Schedule:', classItem['schedule']),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showAddClassDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Class creation dialog - Feature coming soon'),
      ),
    );
  }

  void _showEditClassDialog(dynamic classItem) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Class editing - Feature coming soon'),
      ),
    );
  }

  void _showDeleteConfirmation(dynamic classItem) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Class'),
        content: Text(
          'Are you sure you want to delete ${classItem['name']}? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final apiService = ref.read(apiProvider);
              try {
                await apiService.deleteClass(classItem['id']);
                _loadClasses();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Class deleted successfully')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error deleting class: $e')),
                  );
                }
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
}
