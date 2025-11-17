import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/api_provider.dart';

// Provider for all notifications
final notificationsProvider = FutureProvider<List<dynamic>>((ref) async {
  final apiService = ref.watch(apiProvider);
  try {
    final data = await apiService.getNotifications();
    return data;
  } catch (e) {
    return [];
  }
});

// Provider for unread count
final unreadCountProvider = FutureProvider<int>((ref) async {
  final apiService = ref.watch(apiProvider);
  try {
    return await apiService.getUnreadCount();
  } catch (e) {
    return 0;
  }
});

// Provider for filtering notifications (all vs unread)
final notificationFilterProvider = StateProvider<String>((ref) => 'all');

// Provider for filtered notifications based on filter selection
final filteredNotificationsProvider = Provider<AsyncValue<List<dynamic>>>((ref) {
  final notificationsAsync = ref.watch(notificationsProvider);
  final filter = ref.watch(notificationFilterProvider);

  return notificationsAsync.when(
    data: (notifications) {
      if (filter == 'unread') {
        final unread = notifications.where((n) {
          final notification = n as Map<String, dynamic>;
          return notification['read_at'] == null;
        }).toList();
        return AsyncValue.data(unread);
      }
      return AsyncValue.data(notifications);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});
