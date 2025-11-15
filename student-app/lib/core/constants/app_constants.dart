class AppConstants {
  // API Configuration
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000/api', // Android emulator localhost
  );

  static const String apiTimeout = '30000';

  // Storage Keys
  static const String keyAuthToken = 'auth_token';
  static const String keyUser = 'user_data';
  static const String keyStudentId = 'student_id';

  // App Info
  static const String appName = 'Tuition Student';
  static const String appVersion = '1.0.0';

  // Pagination
  static const int defaultPageSize = 20;

  // Date Formats
  static const String dateFormat = 'yyyy-MM-dd';
  static const String displayDateFormat = 'MMM dd, yyyy';
  static const String displayTimeFormat = 'hh:mm a';

  // Attendance Status
  static const String statusPresent = 'present';
  static const String statusAbsent = 'absent';
  static const String statusLate = 'late';

  // Payment Status
  static const String statusPaid = 'paid';
  static const String statusPending = 'pending';
  static const String statusOverdue = 'overdue';

  // Notification Types
  static const String notifPaymentReminder = 'payment_reminder';
  static const String notifAnnouncement = 'announcement';
  static const String notifGradeUpdate = 'grade_update';
}
