import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';

class ScheduleScreen extends ConsumerStatefulWidget {
  const ScheduleScreen({super.key});

  @override
  ConsumerState<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends ConsumerState<ScheduleScreen> {
  int _selectedDayIndex = DateTime.now().weekday - 1; // 0 = Monday

  final List<String> _days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  // Sample schedule data
  final Map<int, List<Map<String, dynamic>>> _scheduleData = {
    0: [ // Monday
      {
        'subject': 'Mathematics',
        'teacher': 'Mr. Silva',
        'time': '10:00 AM - 12:00 PM',
        'room': 'Room 101',
        'color': Colors.blue,
      },
      {
        'subject': 'Physics',
        'teacher': 'Mrs. Fernando',
        'time': '2:00 PM - 4:00 PM',
        'room': 'Room 203',
        'color': Colors.purple,
      },
    ],
    2: [ // Wednesday
      {
        'subject': 'Mathematics',
        'teacher': 'Mr. Silva',
        'time': '10:00 AM - 12:00 PM',
        'room': 'Room 101',
        'color': Colors.blue,
      },
      {
        'subject': 'Chemistry',
        'teacher': 'Dr. Perera',
        'time': '3:00 PM - 5:00 PM',
        'room': 'Lab 1',
        'color': Colors.green,
      },
    ],
    4: [ // Friday
      {
        'subject': 'Physics',
        'teacher': 'Mrs. Fernando',
        'time': '2:00 PM - 4:00 PM',
        'room': 'Room 203',
        'color': Colors.purple,
      },
    ],
    5: [ // Saturday
      {
        'subject': 'Mathematics',
        'teacher': 'Mr. Silva',
        'time': '9:00 AM - 11:00 AM',
        'room': 'Room 101',
        'color': Colors.blue,
      },
      {
        'subject': 'English',
        'teacher': 'Ms. Jayawardena',
        'time': '1:00 PM - 3:00 PM',
        'room': 'Room 105',
        'color': Colors.orange,
      },
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Class Schedule'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () {
              // TODO: Show calendar view
            },
            tooltip: 'Calendar View',
          ),
        ],
      ),
      body: Column(
        children: [
          // Day Selector
          Container(
            height: 60,
            color: AppTheme.cardColor,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _days.length,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              itemBuilder: (context, index) {
                final isSelected = _selectedDayIndex == index;
                final isToday = index == DateTime.now().weekday - 1;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FilterChip(
                    selected: isSelected,
                    label: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _days[index].substring(0, 3),
                          style: TextStyle(
                            color: isSelected ? Colors.white : AppTheme.textPrimaryColor,
                            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        if (isToday)
                          Container(
                            width: 4,
                            height: 4,
                            margin: const EdgeInsets.only(top: 4),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.white : AppTheme.primaryColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    selectedColor: AppTheme.primaryColor,
                    backgroundColor: Colors.transparent,
                    onSelected: (selected) {
                      setState(() {
                        _selectedDayIndex = index;
                      });
                    },
                  ),
                );
              },
            ),
          ),

          // Schedule Content
          Expanded(
            child: _buildScheduleContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleContent() {
    final classes = _scheduleData[_selectedDayIndex] ?? [];

    if (classes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No classes scheduled',
              style: AppTheme.headingMedium.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Enjoy your day off!',
              style: AppTheme.bodyMedium.copyWith(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Day Header
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              Text(
                _days[_selectedDayIndex],
                style: AppTheme.headingMedium,
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${classes.length} ${classes.length == 1 ? 'Class' : 'Classes'}',
                  style: const TextStyle(
                    color: AppTheme.primaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Class Cards
        ...classes.asMap().entries.map((entry) {
          final index = entry.key;
          final classData = entry.value;
          return Padding(
            padding: EdgeInsets.only(bottom: index < classes.length - 1 ? 12 : 0),
            child: _buildClassCard(
              subject: classData['subject'] as String,
              teacher: classData['teacher'] as String,
              time: classData['time'] as String,
              room: classData['room'] as String,
              color: classData['color'] as Color,
            ),
          );
        }),
      ],
    );
  }

  Widget _buildClassCard({
    required String subject,
    required String teacher,
    required String time,
    required String room,
    required Color color,
  }) {
    return Card(
      child: InkWell(
        onTap: () {
          // TODO: Show class details
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Color Indicator
              Container(
                width: 4,
                height: 80,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 16),

              // Class Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subject,
                      style: AppTheme.titleLarge.copyWith(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.person,
                          size: 16,
                          color: AppTheme.textSecondaryColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          teacher,
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: AppTheme.textSecondaryColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          time,
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 16,
                          color: AppTheme.textSecondaryColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          room,
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Arrow Icon
              Icon(
                Icons.chevron_right,
                color: AppTheme.textSecondaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
