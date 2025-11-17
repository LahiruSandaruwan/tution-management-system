import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/api_provider.dart';

final gradeProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final apiService = ref.watch(apiProvider);
  try {
    final data = await apiService.getMyGrades();
    return data as Map<String, dynamic>;
  } catch (e) {
    // Return empty data structure on error
    return {
      'overall_stats': {
        'overall_average': 0.0,
        'highest': 0.0,
        'lowest': 0.0,
        'total_exams': 0,
      },
      'subject_summaries': [],
    };
  }
});
