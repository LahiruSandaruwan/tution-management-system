import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/theme/app_theme.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  String _selectedFilter = 'all';

  // Sample notifications data
  final List<Map<String, dynamic>> _notifications = [
    {
      'id': 1,
      'title': 'Payment Reminder',
      'message': 'Your monthly fee for November is due. Please make the payment before Nov 20, 2024.',
      'type': 'payment_reminder',
      'timestamp': '2 hours ago',
      'isRead': false,
      'icon': FontAwesomeIcons.moneyBill,
      'color': Colors.orange,
    },
    {
      'id': 2,
      'title': 'Exam Schedule Released',
      'message': 'Mid-term examination schedule has been published. Check your grades section for details.',
      'type': 'exam_notification',
      'timestamp': '5 hours ago',
      'isRead': false,
      'icon': FontAwesomeIcons.fileCircleCheck,
      'color': Colors.blue,
    },
    {
      'id': 3,
      'title': 'Class Cancellation',
      'message': 'Tomorrow\'s Physics class has been cancelled due to teacher unavailability. Make-up class will be scheduled.',
      'type': 'class_cancellation',
      'timestamp': '1 day ago',
      'isRead': true,
      'icon': FontAwesomeIcons.circleXmark,
      'color': Colors.red,
    },
    {
      'id': 4,
      'title': 'New Assignment Posted',
      'message': 'A new Mathematics assignment has been posted. Deadline: Nov 25, 2024.',
      'type': 'announcement',
      'timestamp': '2 days ago',
      'isRead': true,
      'icon': FontAwesomeIcons.bookOpen,
      'color': Colors.purple,
    },
    {
      'id': 5,
      'title': 'Grades Published',
      'message': 'Your grades for the recent Chemistry exam have been published.',
      'type': 'grade_published',
      'timestamp': '3 days ago',
      'isRead': true,
      'icon': FontAwesomeIcons.chartLine,
      'color': Colors.green,
    },
    {
      'id': 6,
      'title': 'Important Announcement',
      'message': 'Institute will be closed on Nov 22, 2024 for a public holiday. All classes are suspended.',
      'type': 'announcement',
      'timestamp': '4 days ago',
      'isRead': true,
      'icon': FontAwesomeIcons.bullhorn,
      'color': Colors.indigo,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filteredNotifications = _selectedFilter == 'all'
        ? _notifications
        : _notifications.where((n) => !n['isRead'] as bool).toList();

    final unreadCount = _notifications.where((n) => !n['isRead'] as bool).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: () {
                // TODO: Mark all as read
              },
              child: const Text('Mark all read'),
            ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: Notification settings
            },
            tooltip: 'Settings',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Tabs
          Container(
            color: AppTheme.cardColor,
            child: Row(
              children: [
                Expanded(
                  child: _buildFilterTab('All', 'all', _notifications.length),
                ),
                Expanded(
                  child: _buildFilterTab('Unread', 'unread', unreadCount),
                ),
              ],
            ),
          ),

          // Notifications List
          Expanded(
            child: filteredNotifications.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredNotifications.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final notification = filteredNotifications[index];
                      return _buildNotificationCard(
                        title: notification['title'] as String,
                        message: notification['message'] as String,
                        timestamp: notification['timestamp'] as String,
                        isRead: notification['isRead'] as bool,
                        icon: notification['icon'] as IconData,
                        color: notification['color'] as Color,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTab(String label, String value, int count) {
    final isSelected = _selectedFilter == value;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedFilter = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? AppTheme.primaryColor : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: AppTheme.titleMedium.copyWith(
                color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondaryColor,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primaryColor : Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[700],
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
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
            Icons.notifications_off,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No notifications',
            style: AppTheme.headingMedium.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You\'re all caught up!',
            style: AppTheme.bodyMedium.copyWith(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard({
    required String title,
    required String message,
    required String timestamp,
    required bool isRead,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: isRead ? 0 : 2,
      color: isRead ? AppTheme.cardColor : Colors.blue.shade50,
      child: InkWell(
        onTap: () {
          // TODO: Mark as read and show details
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: FaIcon(
                    icon,
                    color: color,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: AppTheme.titleMedium.copyWith(
                              fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                            ),
                          ),
                        ),
                        if (!isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppTheme.primaryColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      message,
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.textSecondaryColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          timestamp,
                          style: AppTheme.bodySmall.copyWith(
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
