# Tuition Management System 🎓

A comprehensive, production-ready SaaS platform for managing tuition institutes in Sri Lanka. This system includes RFID-based automated gate access, real-time monitoring, payment tracking, attendance management, and multi-institute support.

## 🚀 Project Overview

This is a complete monorepo containing:
- **Backend API** (Laravel 11 + MySQL)
- **Admin Web Dashboard** (Flutter Web)
- **Student Mobile App** (Flutter Android)
- **Teacher Mobile App** (Flutter Android)
- **RFID Gate System** (ESP32 + RFID-RC522)

## 📁 Project Structure

```
tution-management-system/
├── backend/                 # Laravel 11 API Backend
│   ├── app/
│   │   ├── Http/
│   │   │   ├── Controllers/
│   │   │   ├── Middleware/
│   │   │   ├── Requests/
│   │   │   └── Resources/
│   │   ├── Models/
│   │   ├── Services/
│   │   ├── Repositories/
│   │   ├── Events/
│   │   ├── Listeners/
│   │   ├── Jobs/
│   │   ├── Traits/
│   │   └── Enums/
│   ├── database/
│   │   ├── migrations/
│   │   ├── seeders/
│   │   └── factories/
│   ├── routes/
│   │   └── api.php
│   └── config/
│
├── admin-web/              # Flutter Web Admin Dashboard
├── student-app/            # Flutter Student Mobile App
├── teacher-app/            # Flutter Teacher Mobile App
├── gate-system/            # ESP32 RFID Code (Arduino)
└── docs/                   # Documentation

```

## 🗄️ Database Schema

### Core Tables (17 tables)

1. **institutes** - Institute/organization details
2. **users** - User authentication (admin/teacher/student)
3. **students** - Student profiles and details
4. **teachers** - Teacher profiles and details
5. **subjects** - Course subjects
6. **classes** - Class/batch management
7. **class_student** - Student-class enrollment (pivot)
8. **rfid_cards** - RFID card assignments
9. **gate_logs** - Entry/exit logs
10. **gate_devices** - RFID gate devices
11. **payments** - Fee payments tracking
12. **fee_structures** - Fee configuration by grade/subject
13. **attendances** - Attendance records
14. **schedules** - Class schedules
15. **grades** - Exam results and grades
16. **announcements** - Notices and announcements
17. **notifications** - User notifications
18. **activity_logs** - Audit trail

## ✨ Key Features

### 🔐 Multi-tenancy & Authentication
- Multi-institute support (single deployment, multiple clients)
- Laravel Sanctum API authentication
- Role-based access control (Admin/Teacher/Student)
- Secure API key authentication for RFID devices

### 💳 Payment Management
- Monthly fee tracking
- Payment status monitoring (paid/pending/overdue)
- Automated payment reminders
- Defaulters reporting
- Receipt generation
- Payment history

### 📡 RFID Gate System
- Automated entry/exit logging
- Real-time gate access verification
- Payment status validation before access
- Live gate monitoring dashboard
- Multiple device support
- Offline logging capability

### 📊 Attendance Management
- RFID-based automatic attendance
- Manual attendance backup
- Attendance reports and analytics
- Daily attendance summaries
- Late arrival tracking

### 📚 Academic Features
- Class and subject management
- Grade and exam result tracking
- Schedule management
- Student performance analytics
- Teacher assignment

### 🔔 Communication
- Announcements system
- Push notifications (Firebase FCM)
- Targeted messaging (all/students/teachers/class)
- Real-time updates via WebSockets

### 📈 Reporting & Analytics
- Financial reports
- Attendance reports
- Payment defaulters list
- Student performance reports
- Export to PDF/Excel

## 🛠️ Technology Stack

### Backend
- **Framework:** Laravel 11
- **Database:** MySQL 8.0
- **Authentication:** Laravel Sanctum
- **Real-time:** Laravel Reverb (WebSockets)
- **Queue:** Redis
- **Cache:** Redis
- **API Documentation:** Laravel Scribe

### Frontend
- **Admin Dashboard:** Flutter Web
- **Mobile Apps:** Flutter (Android)
- **State Management:** Riverpod
- **API Client:** Dio
- **Local Storage:** Hive
- **Push Notifications:** Firebase Cloud Messaging

### Hardware
- **Microcontroller:** ESP32
- **RFID Reader:** RFID-RC522
- **Communication:** HTTP/REST API

## 📦 Installation & Setup

### Backend Setup

1. **Clone the repository**
```bash
git clone <repository-url>
cd tution-management-system/backend
```

2. **Install dependencies**
```bash
composer install
```

3. **Configure environment**
```bash
cp .env.example .env
php artisan key:generate
```

4. **Configure database in .env**
```env
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=tuition_management
DB_USERNAME=root
DB_PASSWORD=your_password
```

5. **Run migrations**
```bash
php artisan migrate
```

6. **Seed database (optional)**
```bash
php artisan db:seed
```

7. **Start development server**
```bash
php artisan serve
```

8. **Start queue worker**
```bash
php artisan queue:work
```

9. **Start Reverb server (WebSockets)**
```bash
php artisan reverb:start
```

## 🔑 API Endpoints Overview

### Public Routes
- `POST /api/auth/login` - User login
- `POST /api/auth/register-institute` - Institute registration

### RFID Gate Routes (API Key Protected)
- `POST /api/gate/verify-card` - Verify RFID card access
- `POST /api/gate/log-entry` - Log entry/exit
- `POST /api/gate/heartbeat` - Device heartbeat

### Admin Routes (Sanctum Protected + Admin Role)
- Student Management (CRUD, bulk import, RFID assignment)
- Teacher Management (CRUD)
- Payment Management (record, track, defaulters)
- RFID Management (cards, gates, logs)
- Reports (attendance, payments, financial)

### Student Routes (Sanctum Protected + Student Role)
- Profile management
- View attendance
- View payments
- View schedule
- View grades

### Teacher Routes (Sanctum Protected + Teacher Role)
- View assigned classes
- Mark attendance
- Add grades
- View student list

## 🎯 Business Model

### Pricing Tiers
- **Starter:** Rs. 5,000/month (up to 100 students)
- **Growth:** Rs. 10,000/month (up to 300 students)
- **Professional:** Rs. 20,000/month (up to 1000 students)
- **Enterprise:** Custom pricing (multiple branches)

### Additional Revenue
- RFID hardware kit: Rs. 15,000 (one-time)
- RFID cards: Rs. 200-300 each
- Custom feature development
- Training and onboarding: Rs. 10,000
- Premium support: Rs. 2,000/month

## 🔒 Security Features
- HTTPS/SSL encryption
- SQL injection prevention (Laravel ORM)
- XSS protection
- CSRF protection
- Rate limiting
- API key authentication for devices
- Activity logging for audit trail
- Role-based permissions

## 📝 Development Status

### ✅ Completed
- [x] Project structure setup
- [x] Laravel backend installation
- [x] Database schema design
- [x] All 17 database migrations
- [x] Environment configuration
- [x] Package installation (Sanctum, Reverb, Permissions, Scribe)

### 🚧 In Progress
- [ ] Eloquent models with relationships
- [ ] Authentication setup
- [ ] Middleware implementation
- [ ] API controllers
- [ ] Services and business logic
- [ ] API routes
- [ ] Jobs and queues
- [ ] Broadcasting events
- [ ] Database seeders

### 📋 Upcoming
- [ ] Flutter Admin Web Dashboard
- [ ] Flutter Student Mobile App
- [ ] Flutter Teacher Mobile App
- [ ] ESP32 RFID Gate System
- [ ] API documentation
- [ ] Testing
- [ ] Deployment

## 👥 Target Audience
Sri Lankan tuition institutes looking for:
- Automated attendance tracking
- Payment management
- Student information management
- RFID-based access control
- Real-time monitoring and analytics

## 📞 Support & Documentation
- API Documentation: `/docs/api` (Laravel Scribe)
- User Manuals: `/docs/manuals`
- Setup Guides: `/docs/setup`

## 📄 License
Proprietary - Commercial Product

## 🙏 Credits
Built for Sri Lankan education sector with ❤️

---

**Version:** 1.0.0
**Last Updated:** November 15, 2025
