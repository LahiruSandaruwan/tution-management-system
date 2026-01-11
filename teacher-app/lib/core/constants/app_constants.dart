class AppConstants {
  // API Configuration
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000/api', // Android emulator localhost
  );

  // Storage Keys
  static const String keyAuthToken = 'auth_token';
  static const String keyUser = 'user';
  static const String keyTeacherId = 'teacher_id';

  // App Info
  static const String appName = 'Teacher App';
  static const String appVersion = '1.0.0';
}
