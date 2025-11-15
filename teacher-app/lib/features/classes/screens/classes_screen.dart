import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/theme/app_theme.dart';

class ClassesScreen extends ConsumerWidget {
  const ClassesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Sample classes data
    final classes = [
      {
        'id': 1,
        'name': 'Grade 10 - Mathematics',
        'grade': 'Grade 10',
        'subject': 'Mathematics',
        'studentCount': 25,
        'schedule': 'Mon, Wed, Sat - 10:00 AM',
        'room': 'Room 101',
        'color': Colors.blue,
      },
      {
        'id': 2,
        'name': 'Grade 11 - Mathematics',
        'grade': 'Grade 11',
        'subject': 'Mathematics',
        'studentCount': 20,
        'schedule': 'Tue, Thu, Sun - 2:00 PM',
        'room': 'Room 101',
        'color': Colors.purple,
      },
      {
        'id': 3,
        'name': 'Grade 12 - Mathematics',
        'grade': 'Grade 12',
        'subject': 'Mathematics',
        'studentCount': 18,
        'schedule': 'Mon, Fri - 4:00 PM',
        'room': 'Room 102',
        'color': Colors.green,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Classes'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // TODO: Refresh classes
        },
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: classes.length,
          itemBuilder: (context, index) {
            final classData = classes[index];
            return Padding(
              padding: EdgeInsets.only(bottom: index < classes.length - 1 ? 12 : 0),
              child: _buildClassCard(
                context,
                name: classData['name'] as String,
                grade: classData['grade'] as String,
                subject: classData['subject'] as String,
                studentCount: classData['studentCount'] as int,
                schedule: classData['schedule'] as String,
                room: classData['room'] as String,
                color: classData['color'] as Color,
                onTap: () {
                  // TODO: Navigate to class details
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildClassCard(
    BuildContext context, {
    required String name,
    required String grade,
    required String subject,
    required int studentCount,
    required String schedule,
    required String room,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 60,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: AppTheme.titleLarge.copyWith(
                            color: color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            FaIcon(
                              FontAwesomeIcons.users,
                              size: 14,
                              color: AppTheme.textSecondaryColor,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '$studentCount Students',
                              style: AppTheme.bodyMedium.copyWith(
                                color: AppTheme.textSecondaryColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: AppTheme.textSecondaryColor,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(Icons.access_time, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            schedule,
                            style: AppTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(room, style: AppTheme.bodySmall),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
