# Student Mobile App

A Flutter mobile application for students to manage their tuition activities, attendance, payments, and academic records.

## Features

- **Authentication**: Secure login for students only
- **Dashboard**: Overview of attendance, payments, classes, and grades
- **Attendance**: View attendance history and summary with charts
- **Payments**: Track payment history and status
- **Grades**: View exam results and performance metrics
- **Schedule**: Weekly class timetable
- **Notifications**: Receive announcements and updates
- **Profile**: Manage student profile and settings

## Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK (3.0.0 or higher)
- Android Studio / Xcode for mobile development
- Backend API running (Laravel backend)

## Setup Instructions

### 1. Install Dependencies

```bash
cd student-app
flutter pub get
```

### 2. Generate Model Files

The app uses `json_serializable` for JSON serialization. Generate the required `.g.dart` files:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 3. Configure API Endpoint

Update the API base URL in `lib/core/constants/app_constants.dart`:

```dart
static const String apiBaseUrl = 'http://YOUR_API_URL/api';
```

For Android emulator, use: `http://10.0.2.2:8000/api`
For iOS simulator, use: `http://localhost:8000/api`
For physical devices, use your computer's IP address: `http://192.168.x.x:8000/api`

### 4. Run the App

```bash
# For Android
flutter run

# For iOS
flutter run

# For specific device
flutter devices  # List all devices
flutter run -d <device_id>
```

## Demo Credentials

Use these credentials to test the app (requires seeded database):

```
Email: kasun@example.com
Password: password
```

Other demo student accounts:
- nimal@example.com
- saman@example.com
- dilini@example.com
- hasini@example.com

## Project Structure

```
lib/
├── core/
│   ├── constants/      # App constants and configuration
│   ├── routes/         # Navigation and routing
│   ├── theme/          # App theme and colors
│   └── widgets/        # Reusable widgets
├── features/
│   ├── auth/           # Authentication (login, logout)
│   ├── home/           # Dashboard screen
│   ├── attendance/     # Attendance viewing
│   ├── payments/       # Payment history
│   ├── grades/         # Grades and exam results
│   ├── schedule/       # Class timetable
│   ├── notifications/  # Notifications
│   └── profile/        # Student profile
├── models/             # Data models
├── services/           # API services
└── main.dart           # App entry point
```

## Key Dependencies

- **flutter_riverpod**: State management
- **go_router**: Navigation and routing
- **dio**: HTTP client for API calls
- **shared_preferences**: Local data storage
- **fl_chart**: Charts and graphs
- **font_awesome_flutter**: Icons
- **json_annotation**: JSON serialization

## API Integration

The app integrates with the Laravel backend API for:

- Authentication (Login/Logout)
- Student profile management
- Attendance tracking
- Payment history
- Grade viewing
- Class schedules
- Notifications

See `lib/services/api_service.dart` for all available API endpoints.

## Running Tests

```bash
flutter test
```

## Building for Production

### Android APK

```bash
flutter build apk --release
```

### Android App Bundle

```bash
flutter build appbundle --release
```

### iOS

```bash
flutter build ios --release
```

## Troubleshooting

### Build Runner Issues

If you encounter issues with build_runner:

```bash
flutter clean
flutter pub get
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

### API Connection Issues

- Ensure the Laravel backend is running
- Check the API URL in app_constants.dart
- For Android emulator, use 10.0.2.2 instead of localhost
- Check network permissions in AndroidManifest.xml

## Screenshots

(Add screenshots here after running the app)

## License

This project is part of the Tuition Management System.
