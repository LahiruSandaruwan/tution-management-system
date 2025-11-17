import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../services/offline_api_service.dart';
import '../services/cache_service.dart';
import '../services/connectivity_service.dart';
import 'offline_provider.dart';

// Base API service (without offline support)
final baseApiServiceProvider = Provider<ApiService>((ref) {
  final apiService = ApiService();
  apiService.init();
  return apiService;
});

// Main API provider with offline support
final apiProvider = Provider<OfflineApiService>((ref) {
  final apiService = ref.watch(baseApiServiceProvider);
  final cacheService = ref.watch(cacheServiceProvider);
  final connectivityService = ref.watch(connectivityServiceProvider);

  final offlineApiService = OfflineApiService(
    apiService,
    cacheService,
    connectivityService,
  );
  offlineApiService.init();
  return offlineApiService;
});

// Legacy alias for backward compatibility
final apiServiceProvider = apiProvider;
