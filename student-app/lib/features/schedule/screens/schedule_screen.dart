import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/schedule_provider.dart';

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

  final List<Color> _subjectColors = [
    Colors.blue,
    Colors.purple,
    Colors.green,
    Colors.orange,
    Colors.red,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
  ];

  @override
  Widget build(BuildContext context) {
    final scheduleAsync = ref.watch(scheduleProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Class Schedule'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: _showCalendarView,
            tooltip: 'Calendar View',
          ),
        ],
      ),
      body: scheduleAsync.when(
        data: (scheduleData) => Column(
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
              child: RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(scheduleProvider);
                },
                child: _buildScheduleContent(scheduleData),
              ),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppTheme.errorColor),
              const SizedBox(height: 16),
              Text('Failed to load schedule', style: AppTheme.titleMedium),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondaryColor),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => ref.invalidate(scheduleProvider),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScheduleContent(Map<String, dynamic> scheduleData) {
    // Get the day name from the index
    final selectedDayName = _days[_selectedDayIndex];

    // Get classes for the selected day from API data
    final daySchedule = scheduleData[selectedDayName] as List<dynamic>? ?? [];

    // Convert API data to UI format
    final classes = daySchedule.map((schedule) {
      final scheduleMap = schedule as Map<String, dynamic>;
      final classModel = scheduleMap['class_model'] as Map<String, dynamic>? ?? {};
      final teacher = classModel['teacher'] as Map<String, dynamic>? ?? {};
      final teacherUser = teacher['user'] as Map<String, dynamic>? ?? {};
      final subject = classModel['subject'] as Map<String, dynamic>? ?? {};

      final startTime = scheduleMap['start_time'] as String? ?? '';
      final endTime = scheduleMap['end_time'] as String? ?? '';
      final subjectName = subject['name'] as String? ?? 'Unknown Subject';

      // Assign color based on subject name hash
      final colorIndex = subjectName.hashCode.abs() % _subjectColors.length;

      return {
        'subject': subjectName,
        'teacher': teacherUser['name'] as String? ?? 'Unknown Teacher',
        'time': '$startTime - $endTime',
        'room': scheduleMap['room_number'] as String? ?? 'N/A',
        'color': _subjectColors[colorIndex],
      };
    }).toList();

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

  void _showCalendarView() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: double.maxFinite,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Calendar View',
                    style: AppTheme.headingMedium,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Calendar
              TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: DateTime.now(),
                calendarFormat: CalendarFormat.month,
                startingDayOfWeek: StartingDayOfWeek.monday,
                selectedDayPredicate: (day) {
                  // Highlight selected day
                  return isSameDay(day, _getDateFromDayIndex(_selectedDayIndex));
                },
                onDaySelected: (selectedDay, focusedDay) {
                  // Update selected day
                  setState(() {
                    _selectedDayIndex = selectedDay.weekday - 1;
                  });
                  Navigator.pop(context);
                },
                calendarStyle: CalendarStyle(
                  selectedDecoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  weekendTextStyle: TextStyle(color: Colors.red[400]),
                ),
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  DateTime _getDateFromDayIndex(int dayIndex) {
    final now = DateTime.now();
    final currentWeekday = now.weekday - 1; // 0 = Monday
    final difference = dayIndex - currentWeekday;
    return now.add(Duration(days: difference));
  }
}
