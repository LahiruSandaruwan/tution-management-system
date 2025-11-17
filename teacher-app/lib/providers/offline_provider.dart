import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/connectivity_service.dart';
import '../services/cache_service.dart';

// Connectivity Service Provider
final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  final service = ConnectivityService();
  ref.onDispose(() => service.dispose());
  return service;
});

// Connectivity Status Provider
final connectivityStatusProvider = StreamProvider<bool>((ref) {
  final service = ref.watch(connectivityServiceProvider);
  return service.connectivityStream;
});

// Is Online Provider (synchronous)
final isOnlineProvider = Provider<bool>((ref) {
  final connectivityAsync = ref.watch(connectivityStatusProvider);
  return connectivityAsync.when(
    data: (isOnline) => isOnline,
    loading: () => true, // Assume online while checking
    error: (_, __) => true, // Assume online on error
  );
});

// Cache Service Provider
final cacheServiceProvider = Provider<CacheService>((ref) {
  final service = CacheService();
  service.init();
  ref.onDispose(() => service.dispose());
  return service;
});

// Offline Queue Count Provider
final offlineQueueCountProvider = Provider<int>((ref) {
  final cacheService = ref.watch(cacheServiceProvider);
  return cacheService.queueLength;
});
