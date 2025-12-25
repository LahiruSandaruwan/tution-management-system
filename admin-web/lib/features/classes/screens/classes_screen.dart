import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/api_provider.dart';
import '../widgets/class_form_dialog.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadClasses();
    });
  }

  Future<void> _loadClasses() async {
    if (!mounted) return;

    setState(() => _isLoading = true);
    try {
      final apiService = ref.read(apiProvider);
      final classes = await apiService.getClasses();
      print('Classes loaded: ${classes.length}');
      print('First class: ${classes.isNotEmpty ? classes[0] : 'empty'}');

      if (!mounted) return;

      setState(() {
        _classes = classes;
        _isLoading = false;
      });

      print('State updated. Classes count: ${_classes.length}');
    } catch (e) {
      print('Error loading classes: $e');
      print('Error stack trace: ${StackTrace.current}');

      if (!mounted) return;

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
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first class to get started',
            style: TextStyle(
              fontSize: 14,
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
    try {
      final name = classItem['name']?.toString() ?? 'Unnamed Class';
      final subject = classItem['subject']?['name']?.toString() ?? 'N/A';
      final grade = classItem['grade']?.toString() ?? 'N/A';
      final teacherName = classItem['teacher']?['user']?['name']?.toString() ?? 'No Teacher';
      final capacity = classItem['capacity']?.toString() ?? '0';

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
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.class_,
                        color: Theme.of(context).primaryColor,
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
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  subject,
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                const Divider(),
                Row(
                  children: [
                    const Icon(Icons.school, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(grade, style: const TextStyle(fontSize: 12)),
                    const Spacer(),
                    const Icon(Icons.person, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text('Cap: $capacity', style: const TextStyle(fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Teacher: $teacherName',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      print('Error building class card: $e');
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Error rendering class: $e'),
        ),
      );
    }
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
            _buildDetailRow('Subject:', classItem['subject']?['name'] ?? 'N/A'),
            _buildDetailRow('Grade:', classItem['grade'] ?? 'N/A'),
            _buildDetailRow('Teacher:',
                classItem['teacher']?['user']?['name'] ?? 'No Teacher'),
            _buildDetailRow(
                'Capacity:', '${classItem['capacity'] ?? 0}'),
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

  Future<void> _showAddClassDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => const ClassFormDialog(),
    );

    if (result == true) {
      _loadClasses();
    }
  }

  Future<void> _showEditClassDialog(dynamic classItem) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => ClassFormDialog(classData: classItem),
    );

    if (result == true) {
      _loadClasses();
    }
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
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
