import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';

final apiServiceProvider = Provider<ApiService>((ref) {
  final apiService = ApiService();
  apiService.init();
  return apiService;
});

// Alias for backward compatibility
final apiProvider = apiServiceProvider;
