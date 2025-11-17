import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/api_provider.dart';

final scheduleProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final apiService = ref.watch(apiProvider);
  try {
    final data = await apiService.getMySchedule();
    // Convert list to map if needed, otherwise return as is
    if (data is List) {
      return {};
    }
    return data as Map<String, dynamic>;
  } catch (e) {
    // Return empty map on error
    return {};
  }
});
