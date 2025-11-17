import 'dart:convert';
import 'api_service.dart';
import 'cache_service.dart';
import 'connectivity_service.dart';

class OfflineApiService {
  final ApiService _apiService;
  final CacheService _cacheService;
  final ConnectivityService _connectivityService;

  OfflineApiService(
    this._apiService,
    this._cacheService,
    this._connectivityService,
  ) {
    // Listen to connectivity changes to sync queued requests
    _connectivityService.connectivityStream.listen((isOnline) {
      if (isOnline) {
        _syncQueuedRequests();
      }
    });
  }

  Future<void> init() async {
    await _apiService.init();
    await _cacheService.init();
  }

  // ====================== DASHBOARD ======================

  Future<Map<String, dynamic>> getDashboardStats() async {
    const cacheKey = 'dashboard_stats';

    if (_connectivityService.isOnline) {
      try {
        final data = await _apiService.getDashboardStats();
        await _cacheService.cacheData(cacheKey, data);
        return data;
      } catch (e) {
        // If online request fails, try cache
        final cached = _cacheService.getCachedData(cacheKey, maxAgeMinutes: 1440);
        if (cached != null) return cached;
        rethrow;
      }
    } else {
      // Offline: return cached data
      final cached = _cacheService.getCachedData(cacheKey, maxAgeMinutes: 1440);
      if (cached != null) return cached;
      throw Exception('No cached data available and device is offline');
    }
  }

  Future<Map<String, dynamic>> getRecentActivities() async {
    const cacheKey = 'recent_activities';

    if (_connectivityService.isOnline) {
      try {
        final data = await _apiService.getRecentActivities();
        await _cacheService.cacheData(cacheKey, data);
        return data;
      } catch (e) {
        final cached = _cacheService.getCachedData(cacheKey, maxAgeMinutes: 1440);
        if (cached != null) return cached;
        rethrow;
      }
    } else {
      final cached = _cacheService.getCachedData(cacheKey, maxAgeMinutes: 1440);
      if (cached != null) return cached;
      throw Exception('No cached data available and device is offline');
    }
  }

  // ====================== ATTENDANCE ======================

  Future<dynamic> getAttendanceSummary({String? month, int? year}) async {
    final cacheKey = 'attendance_summary_${month ?? ''}_${year ?? ''}';

    if (_connectivityService.isOnline) {
      try {
        final data = await _apiService.getAttendanceSummary(month: month, year: year);
        await _cacheService.cacheData(cacheKey, {
          'summary': {
            'total_classes': data.totalClasses,
            'attended': data.attended,
            'absent': data.absent,
            'late': data.late,
          }
        });
        return data;
      } catch (e) {
        final cached = _cacheService.getCachedData(cacheKey, maxAgeMinutes: 1440);
        if (cached != null) return cached;
        rethrow;
      }
    } else {
      final cached = _cacheService.getCachedData(cacheKey, maxAgeMinutes: 1440);
      if (cached != null) return cached;
      throw Exception('No cached data available and device is offline');
    }
  }

  Future<List<dynamic>> getAttendanceHistory({String? month, int? year}) async {
    final cacheKey = 'attendance_history_${month ?? ''}_${year ?? ''}';

    if (_connectivityService.isOnline) {
      try {
        final data = await _apiService.getAttendanceHistory(month: month, year: year);
        await _cacheService.cacheData(cacheKey, data.map((e) => e.toJson()).toList());
        return data;
      } catch (e) {
        final cached = _cacheService.getCachedData(cacheKey, maxAgeMinutes: 1440);
        if (cached != null) return cached;
        rethrow;
      }
    } else {
      final cached = _cacheService.getCachedData(cacheKey, maxAgeMinutes: 1440);
      if (cached != null) return cached;
      throw Exception('No cached data available and device is offline');
    }
  }

  // ====================== PAYMENTS ======================

  Future<List<dynamic>> getMyPayments() async {
    const cacheKey = 'my_payments';

    if (_connectivityService.isOnline) {
      try {
        final data = await _apiService.getMyPayments();
        await _cacheService.cacheData(cacheKey, data.map((e) => e.toJson()).toList());
        return data;
      } catch (e) {
        final cached = _cacheService.getCachedData(cacheKey, maxAgeMinutes: 1440);
        if (cached != null) return cached;
        rethrow;
      }
    } else {
      final cached = _cacheService.getCachedData(cacheKey, maxAgeMinutes: 1440);
      if (cached != null) return cached;
      throw Exception('No cached data available and device is offline');
    }
  }

  Future<dynamic> getPaymentSummary() async {
    const cacheKey = 'payment_summary';

    if (_connectivityService.isOnline) {
      try {
        final data = await _apiService.getPaymentSummary();
        await _cacheService.cacheData(cacheKey, {
          'total_amount': data.totalAmount,
          'paid_amount': data.paidAmount,
          'pending_amount': data.pendingAmount,
        });
        return data;
      } catch (e) {
        final cached = _cacheService.getCachedData(cacheKey, maxAgeMinutes: 1440);
        if (cached != null) return cached;
        rethrow;
      }
    } else {
      final cached = _cacheService.getCachedData(cacheKey, maxAgeMinutes: 1440);
      if (cached != null) return cached;
      throw Exception('No cached data available and device is offline');
    }
  }

  // ====================== SCHEDULE ======================

  Future<List<dynamic>> getMySchedule() async {
    const cacheKey = 'my_schedule';

    if (_connectivityService.isOnline) {
      try {
        final data = await _apiService.getMySchedule();
        await _cacheService.cacheData(cacheKey, data);
        return data;
      } catch (e) {
        final cached = _cacheService.getCachedData(cacheKey, maxAgeMinutes: 1440);
        if (cached != null) return cached;
        rethrow;
      }
    } else {
      final cached = _cacheService.getCachedData(cacheKey, maxAgeMinutes: 1440);
      if (cached != null) return cached;
      throw Exception('No cached data available and device is offline');
    }
  }

  // ====================== GRADES ======================

  Future<List<dynamic>> getMyGrades() async {
    const cacheKey = 'my_grades';

    if (_connectivityService.isOnline) {
      try {
        final data = await _apiService.getMyGrades();
        await _cacheService.cacheData(cacheKey, data);
        return data;
      } catch (e) {
        final cached = _cacheService.getCachedData(cacheKey, maxAgeMinutes: 1440);
        if (cached != null) return cached;
        rethrow;
      }
    } else {
      final cached = _cacheService.getCachedData(cacheKey, maxAgeMinutes: 1440);
      if (cached != null) return cached;
      throw Exception('No cached data available and device is offline');
    }
  }

  // ====================== NOTIFICATIONS ======================

  Future<List<dynamic>> getNotifications() async {
    const cacheKey = 'notifications';

    if (_connectivityService.isOnline) {
      try {
        final data = await _apiService.getNotifications();
        await _cacheService.cacheData(cacheKey, data);
        return data;
      } catch (e) {
        final cached = _cacheService.getCachedData(cacheKey, maxAgeMinutes: 60);
        if (cached != null) return cached;
        rethrow;
      }
    } else {
      final cached = _cacheService.getCachedData(cacheKey, maxAgeMinutes: 60);
      if (cached != null) return cached;
      throw Exception('No cached data available and device is offline');
    }
  }

  Future<int> getUnreadCount() async {
    const cacheKey = 'unread_count';

    if (_connectivityService.isOnline) {
      try {
        final data = await _apiService.getUnreadCount();
        await _cacheService.cacheData(cacheKey, data);
        return data;
      } catch (e) {
        final cached = _cacheService.getCachedData(cacheKey, maxAgeMinutes: 60);
        if (cached != null) return cached;
        rethrow;
      }
    } else {
      final cached = _cacheService.getCachedData(cacheKey, maxAgeMinutes: 60);
      if (cached != null) return cached;
      return 0;
    }
  }

  Future<void> markNotificationAsRead(int notificationId) async {
    if (_connectivityService.isOnline) {
      await _apiService.markNotificationAsRead(notificationId);
      // Invalidate cache
      await _cacheService.deleteCacheEntry('notifications');
      await _cacheService.deleteCacheEntry('unread_count');
    } else {
      // Queue for later
      await _cacheService.queueRequest({
        'method': 'POST',
        'endpoint': '/notifications/$notificationId/read',
        'data': null,
      });
    }
  }

  // ====================== AUTH (pass-through, no caching) ======================

  Future<dynamic> login(String email, String password) async {
    return await _apiService.login(email, password);
  }

  Future<void> logout() async {
    await _apiService.logout();
    await _cacheService.clearCache();
  }

  Future<dynamic> getCurrentUser() async {
    return await _apiService.getCurrentUser();
  }

  Future<Map<String, dynamic>> uploadProfilePhoto(String filePath) async {
    if (_connectivityService.isOnline) {
      return await _apiService.uploadProfilePhoto(filePath);
    } else {
      throw Exception('Cannot upload photo while offline');
    }
  }

  Future<Map<String, dynamic>> deleteProfilePhoto() async {
    if (_connectivityService.isOnline) {
      return await _apiService.deleteProfilePhoto();
    } else {
      throw Exception('Cannot delete photo while offline');
    }
  }

  // ====================== SYNC QUEUED REQUESTS ======================

  Future<void> _syncQueuedRequests() async {
    final queuedRequests = _cacheService.getQueuedRequests();

    for (var entry in queuedRequests) {
      try {
        final request = entry.value;
        final method = request['method'] as String;
        final endpoint = request['endpoint'] as String;

        // Execute the queued request
        if (method == 'POST') {
          // Execute POST request
          // Note: This is simplified - in production you'd need to handle different endpoints
          await _apiService.markNotificationAsRead(
            int.parse(endpoint.split('/')[2])
          );
        }

        // Remove from queue if successful
        await _cacheService.removeQueuedRequest(entry.key);
      } catch (e) {
        // Keep in queue if failed
        continue;
      }
    }
  }

  Future<void> syncNow() async {
    if (_connectivityService.isOnline) {
      await _syncQueuedRequests();
    }
  }
}
