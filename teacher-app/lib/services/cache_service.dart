import 'package:hive_flutter/hive_flutter.dart';

class CacheService {
  static const String _apiCacheBox = 'api_cache';
  static const String _offlineQueueBox = 'offline_queue';

  Box<dynamic>? _cacheBox;
  Box<Map<dynamic, dynamic>>? _queueBox;

  Future<void> init() async {
    await Hive.initFlutter();
    _cacheBox = await Hive.openBox(_apiCacheBox);
    _queueBox = await Hive.openBox<Map<dynamic, dynamic>>(_offlineQueueBox);
  }

  // ====================== CACHE OPERATIONS ======================

  Future<void> cacheData(String key, dynamic data) async {
    final cacheEntry = {
      'data': data,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    await _cacheBox?.put(key, cacheEntry);
  }

  dynamic getCachedData(String key, {int maxAgeMinutes = 60}) {
    final cacheEntry = _cacheBox?.get(key);

    if (cacheEntry == null) return null;

    final timestamp = cacheEntry['timestamp'] as int;
    final age = DateTime.now().millisecondsSinceEpoch - timestamp;
    final maxAge = maxAgeMinutes * 60 * 1000; // Convert to milliseconds

    // Return null if cache is too old
    if (age > maxAge) {
      _cacheBox?.delete(key);
      return null;
    }

    return cacheEntry['data'];
  }

  Future<void> clearCache() async {
    await _cacheBox?.clear();
  }

  Future<void> deleteCacheEntry(String key) async {
    await _cacheBox?.delete(key);
  }

  // ====================== OFFLINE QUEUE OPERATIONS ======================

  Future<void> queueRequest(Map<String, dynamic> request) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    await _queueBox?.put(id, request);
  }

  List<MapEntry<String, Map<dynamic, dynamic>>> getQueuedRequests() {
    return _queueBox?.toMap().entries.map((e) {
      return MapEntry(e.key.toString(), e.value);
    }).toList() ?? [];
  }

  Future<void> removeQueuedRequest(String id) async {
    await _queueBox?.delete(id);
  }

  Future<void> clearQueue() async {
    await _queueBox?.clear();
  }

  int get queueLength => _queueBox?.length ?? 0;

  // ====================== CLEANUP ======================

  Future<void> dispose() async {
    await _cacheBox?.close();
    await _queueBox?.close();
  }
}
