# Tuition Management System - Admin Web Dashboard

Flutter web application for managing tuition institutes - complete admin dashboard with real-time monitoring, student management, payment tracking, and analytics.

## Features

### ✅ Implemented
- **Authentication** - Login/Logout with Laravel Sanctum
- **Dashboard** - Real-time statistics and charts
  - Student & Teacher counts
  - Payment statistics (Paid, Pending, Overdue)
  - Today's attendance breakdown
  - Live gate activity monitoring
- **Responsive Layout** - Sidebar navigation with user profile
- **State Management** - Riverpod for clean state handling
- **API Integration** - Complete API service with Dio
- **Theme** - Modern Material Design 3 theme

### 🔜 To Be Implemented
- **Student Management** - CRUD operations, search, filters
- **Teacher Management** - Teacher profiles and assignments
- **Payment Management** - Record payments, track defaulters, generate monthly invoices
- **Attendance System** - Mark attendance (individual/bulk), view reports
- **Class Management** - Create classes, manage enrollments
- **Reports & Analytics** - Comprehensive reporting system
- **Gate Monitoring** - Real-time RFID gate activity feed
- **Notifications** - In-app notifications and announcements

## Tech Stack

- **Framework**: Flutter 3.0+ (Web)
- **State Management**: Riverpod 2.4.9
- **Routing**: go_router 12.1.3
- **HTTP Client**: Dio 5.4.0
- **Charts**: FL Chart 0.65.0, Syncfusion Charts
- **Local Storage**: shared_preferences, flutter_secure_storage
- **UI Components**: Material Design 3

## Project Structure

```
lib/
├── core/
│   ├── constants/      # App constants and config
│   ├── theme/          # App theme and styles
│   ├── routes/         # Routing configuration
│   └── widgets/        # Shared widgets (MainLayout, etc.)
├── features/
│   ├── auth/           # Authentication (Login)
│   ├── dashboard/      # Dashboard with statistics
│   ├── students/       # Student management
│   ├── payments/       # Payment tracking
│   ├── attendance/     # Attendance system
│   ├── reports/        # Reports and analytics
│   └── gate/           # Gate monitoring
├── models/             # Data models
├── services/           # API services
├── providers/          # Riverpod providers
└── main.dart           # App entry point
```

## Getting Started

### Prerequisites

- Flutter SDK 3.0 or higher
- Dart SDK 3.0 or higher
- Laravel backend API running (see `/backend` directory)

### Installation

1. Install dependencies:
```bash
cd admin-web
flutter pub get
```

2. Configure API endpoint:
```bash
# Set API base URL (default: http://localhost:8000/api)
export API_BASE_URL=http://your-api-url/api
```

3. Run the app:
```bash
flutter run -d chrome
```

Or build for production:
```bash
flutter build web
```

## Configuration

### API Endpoint
Edit `lib/core/constants/app_constants.dart`:
```dart
static const String apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:8000/api',
);
```

### Theme Customization
Edit `lib/core/theme/app_theme.dart` to customize colors, fonts, and styles.

## Demo Credentials

After seeding the Laravel backend:
- **Email**: admin@royaltech.lk
- **Password**: password123

## API Integration

The app connects to the Laravel backend API with these key endpoints:

- `POST /api/auth/login` - User authentication
- `GET /api/dashboard/stats` - Dashboard statistics
- `GET /api/students` - Student list (paginated)
- `GET /api/payments` - Payment records
- `POST /api/attendance/mark-bulk` - Bulk attendance marking
- `GET /api/reports/*` - Various reports

See `lib/services/api_service.dart` for complete API documentation.

## Screenshots

_Screenshots will be added after full implementation_

## Development Roadmap

### Phase 1: Core Features (Current)
- [x] Authentication & Authorization
- [x] Dashboard with statistics
- [x] Basic navigation and layout
- [ ] Student CRUD operations
- [ ] Payment management
- [ ] Attendance marking

### Phase 2: Advanced Features
- [ ] Real-time gate monitoring with WebSocket
- [ ] Advanced reporting and analytics
- [ ] Bulk operations (import/export)
- [ ] Notification system
- [ ] User roles and permissions

### Phase 3: Polish & Optimization
- [ ] Responsive design improvements
- [ ] Performance optimization
- [ ] Offline support
- [ ] PWA capabilities
- [ ] Unit & widget tests

## Contributing

This is part of the Tuition Management System project. For the complete system, see the main repository.

## License

All rights reserved.
