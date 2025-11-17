import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../core/theme/app_theme.dart';
import '../providers/notification_provider.dart';
import '../../../providers/api_provider.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  IconData _getIconForType(String type) {
    switch (type) {
      case 'payment_reminder':
      case 'payment_overdue':
        return FontAwesomeIcons.moneyBill;
      case 'exam_notification':
      case 'grade_published':
        return FontAwesomeIcons.chartLine;
      case 'class_cancellation':
        return FontAwesomeIcons.circleXmark;
      case 'announcement':
        return FontAwesomeIcons.bullhorn;
      default:
        return FontAwesomeIcons.bell;
    }
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'payment_reminder':
      case 'payment_overdue':
        return Colors.orange;
      case 'exam_notification':
        return Colors.blue;
      case 'grade_published':
        return Colors.green;
      case 'class_cancellation':
        return Colors.red;
      case 'announcement':
        return Colors.indigo;
      default:
        return AppTheme.primaryColor;
    }
  }

  Future<void> _markAsRead(WidgetRef ref, int notificationId) async {
    final apiService = ref.read(apiProvider);
    try {
      await apiService.markNotificationAsRead(notificationId);
      // Refresh the notifications list
      ref.invalidate(notificationsProvider);
      ref.invalidate(unreadCountProvider);
    } catch (e) {
      // Handle error silently
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(filteredNotificationsProvider);
    final unreadCountAsync = ref.watch(unreadCountProvider);
    final allNotificationsAsync = ref.watch(notificationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          unreadCountAsync.when(
            data: (count) => count > 0
                ? TextButton(
                    onPressed: () {
                      // TODO: Mark all as read (requires backend endpoint)
                    },
                    child: const Text('Mark all read'),
                  )
                : const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
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
                  child: _buildFilterTab(
                    ref,
                    'All',
                    'all',
                    allNotificationsAsync.when(
                      data: (notifications) => notifications.length,
                      loading: () => 0,
                      error: (_, __) => 0,
                    ),
                  ),
                ),
                Expanded(
                  child: _buildFilterTab(
                    ref,
                    'Unread',
                    'unread',
                    unreadCountAsync.when(
                      data: (count) => count,
                      loading: () => 0,
                      error: (_, __) => 0,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Notifications List
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(notificationsProvider);
                ref.invalidate(unreadCountProvider);
              },
              child: notificationsAsync.when(
                data: (notifications) {
                  if (notifications.isEmpty) {
                    return _buildEmptyState();
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: notifications.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final notification = notifications[index] as Map<String, dynamic>;
                      final id = notification['id'] as int;
                      final title = notification['title'] as String? ?? 'Notification';
                      final message = notification['message'] as String? ?? '';
                      final type = notification['type'] as String? ?? '';
                      final readAt = notification['read_at'];
                      final isRead = readAt != null;
                      final createdAt = notification['created_at'] as String?;

                      // Format timestamp
                      String timestamp = '';
                      if (createdAt != null) {
                        try {
                          final dateTime = DateTime.parse(createdAt);
                          timestamp = timeago.format(dateTime);
                        } catch (e) {
                          timestamp = createdAt;
                        }
                      }

                      return _buildNotificationCard(
                        ref: ref,
                        id: id,
                        title: title,
                        message: message,
                        timestamp: timestamp,
                        isRead: isRead,
                        icon: _getIconForType(type),
                        color: _getColorForType(type),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: AppTheme.errorColor),
                      const SizedBox(height: 16),
                      Text('Failed to load notifications', style: AppTheme.titleMedium),
                      const SizedBox(height: 8),
                      Text(
                        error.toString(),
                        style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondaryColor),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          ref.invalidate(notificationsProvider);
                          ref.invalidate(unreadCountProvider);
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTab(WidgetRef ref, String label, String value, int count) {
    final selectedFilter = ref.watch(notificationFilterProvider);
    final isSelected = selectedFilter == value;

    return InkWell(
      onTap: () {
        ref.read(notificationFilterProvider.notifier).state = value;
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
    return ListView(
      children: [
        SizedBox(
          height: 400,
          child: Center(
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
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationCard({
    required WidgetRef ref,
    required int id,
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
        onTap: () async {
          if (!isRead) {
            await _markAsRead(ref, id);
          }
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
