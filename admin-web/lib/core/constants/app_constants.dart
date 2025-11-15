class AppConstants {
  // API Configuration
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000/api',
  );

  static const String apiTimeout = '30000'; // 30 seconds

  // Storage Keys
  static const String keyAuthToken = 'auth_token';
  static const String keyUser = 'user_data';
  static const String keyInstituteId = 'institute_id';

  // App Info
  static const String appName = 'Tuition Admin Dashboard';
  static const String appVersion = '1.0.0';

  // Pagination
  static const int defaultPageSize = 15;
  static const int maxPageSize = 100;

  // Date Formats
  static const String dateFormat = 'yyyy-MM-dd';
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm:ss';
  static const String displayDateFormat = 'MMM dd, yyyy';
  static const String displayTimeFormat = 'hh:mm a';

  // Validation
  static const int minPasswordLength = 8;
  static const int maxNameLength = 255;
  static const int maxPhoneLength = 20;

  // Colors (Hex values)
  static const String primaryColor = '#1976D2';
  static const String secondaryColor = '#FF9800';
  static const String errorColor = '#D32F2F';
  static const String successColor = '#388E3C';
  static const String warningColor = '#F57C00';

  // Grade Levels
  static const List<String> gradeLevels = [
    'Grade 10',
    'Grade 11',
    'Grade 12',
    'Grade 13',
  ];

  // Payment Status
  static const List<String> paymentStatuses = [
    'paid',
    'pending',
    'overdue',
  ];

  // Attendance Status
  static const List<String> attendanceStatuses = [
    'present',
    'absent',
    'late',
  ];

  // User Roles
  static const String roleAdmin = 'admin';
  static const String roleTeacher = 'teacher';
  static const String roleStudent = 'student';

  // Chart Colors
  static const List<String> chartColors = [
    '#2196F3',
    '#4CAF50',
    '#FF9800',
    '#F44336',
    '#9C27B0',
    '#00BCD4',
    '#FFEB3B',
    '#795548',
  ];
}
