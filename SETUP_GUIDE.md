# Complete Setup Guide

This guide will help you complete the setup and run the Tuition Management System.

## ✅ What's Already Complete

1. **Backend API** - Fully functional Laravel backend
2. **Admin Web Dashboard** - Complete Flutter web app
3. **Student Mobile App** - Complete Flutter mobile app
4. **Teacher Mobile App** - Complete Flutter mobile app
5. **ESP32 RFID System** - Hardware code ready
6. **Password Reset** - Full implementation (backend + frontend)

## 🔴 Critical Steps Before Running

### Step 1: Backend Setup

```bash
cd backend

# 1. Install dependencies
composer install

# 2. Configure environment
cp .env.example .env

# 3. Update .env file with your settings:
# - DB_DATABASE=tuition_management
# - DB_USERNAME=root
# - DB_PASSWORD=your_password
# - MAIL_* settings for password reset emails

# 4. Generate application key
php artisan key:generate

# 5. Run migrations (includes new password_reset_tokens table)
php artisan migrate:fresh --seed

# 6. Start the server
php artisan serve

# Server will run at: http://localhost:8000
```

### Step 2: Generate Flutter Model Files

**CRITICAL**: All Flutter apps require `.g.dart` files to be generated before they can run.

#### For Student App:

```bash
cd student-app

# 1. Get dependencies
flutter pub get

# 2. Generate model files
flutter pub run build_runner build --delete-conflicting-outputs

# This will generate:
# - lib/models/user.g.dart
# - lib/models/attendance.g.dart
# - lib/models/payment.g.dart
# - lib/models/grade.g.dart
# - lib/models/schedule.g.dart
# - lib/models/notification.g.dart

# 3. Update API URL in lib/core/constants/app_constants.dart:
# For Android Emulator: http://10.0.2.2:8000/api
# For Physical Device: http://YOUR_IP:8000/api
# For iOS Simulator: http://localhost:8000/api

# 4. Run the app
flutter run
```

#### For Teacher App:

```bash
cd teacher-app

# 1. Get dependencies
flutter pub get

# 2. Generate model files
flutter pub run build_runner build --delete-conflicting-outputs

# This will generate:
# - lib/models/user.g.dart
# - lib/models/class.g.dart
# - lib/models/attendance.g.dart

# 3. Update API URL in lib/core/constants/app_constants.dart

# 4. Run the app
flutter run
```

#### For Admin Web Dashboard:

```bash
cd admin-web

# 1. Get dependencies
flutter pub get

# 2. Generate model files
flutter pub run build_runner build --delete-conflicting-outputs

# 3. Update API URL to http://localhost:8000/api

# 4. Run on Chrome
flutter run -d chrome
```

### Step 3: Test Password Reset Feature

1. **Forgot Password Flow**:
   - Open Student/Teacher app
   - Click "Forgot Password?" on login screen
   - Enter email: kasun@example.com
   - System sends reset token (displayed in development mode)
   - Copy the token
   - Enter token and new password
   - Password reset successful
   - Login with new password

2. **Change Password (Authenticated)**:
   - Login to any app
   - Go to Profile/Settings
   - Click "Change Password"
   - Enter current password
   - Enter new password and confirmation
   - Password changed successfully

### Step 4: Configure Email (Optional for Production)

Update `.env` file in backend:

```env
MAIL_MAILER=smtp
MAIL_HOST=smtp.mailtrap.io
MAIL_PORT=2525
MAIL_USERNAME=your_username
MAIL_PASSWORD=your_password
MAIL_ENCRYPTION=tls
MAIL_FROM_ADDRESS="noreply@tuition.com"
MAIL_FROM_NAME="${APP_NAME}"
```

For production, use real SMTP provider (Gmail, SendGrid, etc.)

## 📋 Demo Credentials

All passwords: `password`

**Admin**:
- Email: admin@example.com

**Teachers**:
- Email: teacher1@example.com
- Email: teacher2@example.com

**Students**:
- Email: kasun@example.com
- Email: nimal@example.com
- Email: saman@example.com
- Email: dilini@example.com
- Email: hasini@example.com

**RFID Cards** (for gate system):
- RFID001 → Kasun Rajapaksa
- RFID002 → Nimal Perera
- RFID003 → Saman Silva
- RFID004 → Dilini Fernando
- RFID005 → Hasini Kumari

## 🐛 Common Issues & Solutions

### Issue: build_runner fails

**Solution**:
```bash
flutter clean
flutter pub get
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

### Issue: API connection failed

**Solutions**:
- Backend running? Check `php artisan serve`
- Correct API URL in app_constants.dart?
- For Android emulator, use `10.0.2.2:8000` not `localhost:8000`
- Check firewall settings

### Issue: Migration fails

**Solution**:
```bash
# Drop all tables and recreate
php artisan migrate:fresh --seed

# If database doesn't exist, create it first in MySQL
mysql -u root -p
CREATE DATABASE tuition_management;
exit;
```

### Issue: Password reset email not sending

**Solutions**:
- Check MAIL_* settings in .env
- In development, token is displayed in app UI
- Check laravel.log for errors
- Use Mailtrap.io for testing

## 🎯 Next Steps

### 1. Connect Real API Data to UI

Currently, most UI screens use placeholder data. To connect real data:

**Example: Student Dashboard**

```dart
// In home_screen.dart, create a provider:
final dashboardProvider = FutureProvider<DashboardData>((ref) async {
  final apiService = ref.watch(apiProvider);
  return await apiService.getDashboardStats();
});

// Then in build method:
final dashboardAsync = ref.watch(dashboardProvider);

return dashboardAsync.when(
  data: (data) => _buildDashboard(data),
  loading: () => CircularProgressIndicator(),
  error: (error, stack) => ErrorWidget(error),
);
```

Apply this pattern to:
- Dashboard stats
- Attendance data
- Payment data
- Grades data
- Schedule data

### 2. Add Pull-to-Refresh

```dart
RefreshIndicator(
  onRefresh: () async {
    ref.invalidate(dashboardProvider);
  },
  child: ListView(...),
)
```

### 3. Implement Real-time Features (Optional)

- Set up Laravel Reverb
- Create broadcasting events
- Connect WebSocket in Flutter apps
- Real-time gate monitoring
- Live notifications

### 4. Add File Upload (Profile Photos)

- Backend: Configure storage in config/filesystems.php
- Add upload endpoints to API
- Frontend: Use image_picker package
- Implement upload UI

### 5. Implement Push Notifications

- Set up Firebase Cloud Messaging
- Backend: Install firebase-admin
- Store FCM tokens in database
- Send notifications on events

## 📚 Project Structure

```
tution-management-system/
├── backend/                    # Laravel 11 API
│   ├── app/
│   │   ├── Http/Controllers/  # ✅ Complete
│   │   ├── Models/            # ✅ Complete
│   │   ├── Services/          # ✅ Complete
│   │   └── Middleware/        # ✅ Complete
│   ├── database/
│   │   ├── migrations/        # ✅ All 18 tables (+ password_reset_tokens)
│   │   └── seeders/           # ✅ Demo data
│   └── routes/api.php         # ✅ All endpoints including password reset
│
├── admin-web/                  # Flutter Web Dashboard
│   ├── lib/
│   │   ├── features/          # ✅ All screens complete
│   │   ├── models/            # ⚠️ Need .g.dart files
│   │   └── services/          # ✅ API integration complete
│   └── pubspec.yaml
│
├── student-app/                # Flutter Mobile App
│   ├── lib/
│   │   ├── features/
│   │   │   ├── auth/          # ✅ Login + Password Reset
│   │   │   ├── home/          # ✅ Dashboard
│   │   │   ├── attendance/    # ✅ Viewing
│   │   │   ├── payments/      # ✅ History
│   │   │   ├── grades/        # ✅ Results
│   │   │   ├── schedule/      # ✅ Timetable
│   │   │   ├── notifications/ # ✅ Announcements
│   │   │   └── profile/       # ✅ Profile + Change Password
│   │   ├── models/            # ⚠️ Need .g.dart files
│   │   └── services/          # ✅ API + Password Reset
│   └── pubspec.yaml
│
├── teacher-app/                # Flutter Mobile App
│   ├── lib/
│   │   ├── features/          # ✅ All core features
│   │   ├── models/            # ⚠️ Need .g.dart files
│   │   └── services/          # ✅ API integration
│   └── pubspec.yaml
│
├── rfid-gate-system/           # ESP32 Code
│   ├── rfid_gate_system.ino   # ✅ Main firmware
│   ├── config.h               # ⚠️ Configure WiFi & API
│   └── HARDWARE_SETUP.md      # ✅ Assembly guide
│
└── SETUP_GUIDE.md              # This file
```

## ✅ Feature Completion Status

| Feature | Backend | Frontend | Status |
|---------|---------|----------|--------|
| **Authentication** | ✅ | ✅ | Complete |
| **Password Reset** | ✅ | ✅ | Complete |
| **Student Management** | ✅ | ✅ | Complete |
| **Teacher Management** | ✅ | ✅ | Complete |
| **Class Management** | ✅ | ✅ | Complete |
| **Attendance** | ✅ | ⚠️ UI only | Needs API connection |
| **Payments** | ✅ | ⚠️ UI only | Needs API connection |
| **Grades** | ✅ | ⚠️ UI only | Needs API connection |
| **Schedules** | ✅ | ⚠️ UI only | Needs API connection |
| **Notifications** | ✅ | ⚠️ UI only | Needs API connection |
| **RFID Gate** | ✅ | ✅ | Complete |
| **Dashboard Stats** | ✅ | ⚠️ Placeholder | Needs API connection |
| **Real-time** | ⚠️ Package installed | ❌ | To implement |
| **File Upload** | ❌ | ❌ | To implement |
| **Push Notifications** | ❌ | ❌ | To implement |
| **Email Notifications** | ⚠️ Basic | ⚠️ Basic | Needs templates |
| **PDF Export** | ❌ | ❌ | To implement |
| **Offline Mode** | ❌ | ❌ | To implement |

## 🚀 Quick Start Commands

```bash
# Terminal 1: Backend
cd backend && php artisan serve

# Terminal 2: Student App
cd student-app && flutter pub run build_runner build --delete-conflicting-outputs && flutter run

# Terminal 3: Teacher App
cd teacher-app && flutter pub run build_runner build --delete-conflicting-outputs && flutter run

# Terminal 4: Admin Dashboard
cd admin-web && flutter pub run build_runner build --delete-conflicting-outputs && flutter run -d chrome
```

## 📞 Support

For issues:
1. Check this guide first
2. Review component-specific README files
3. Check error logs (laravel.log for backend)
4. Test with demo credentials
5. Verify API URLs are correct

## 🎉 You're Ready!

Once you've completed Steps 1-2 above:
1. Backend API will be running at http://localhost:8000
2. All Flutter apps will compile and run
3. Password reset will work end-to-end
4. You can login with demo credentials
5. System is ready for development/testing

**Next priority**: Connect real API data to UI screens (see Next Steps section above).
