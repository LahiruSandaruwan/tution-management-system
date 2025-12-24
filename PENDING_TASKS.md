# Pending Tasks for Production Readiness

## ✅ Recently Completed
- **MySQL Test Configuration**: Tests now use MySQL instead of SQLite ✅
- **Test Database Setup Script**: Automated setup script created ✅
- **Testing Documentation**: Comprehensive TESTING_GUIDE.md created ✅

---

## 🔴 Critical - Must Do Before Production Deployment

### 1. Create .env File ⚠️
**Status**: Not Created
**Time**: 5 minutes

```bash
cd backend
cp .env.example .env
```

**Required Configuration**:
```env
# Application
APP_NAME="Tuition Management System"
APP_ENV=production
APP_DEBUG=false
APP_KEY=base64:GENERATE_WITH_ARTISAN
APP_TIMEZONE=Asia/Colombo
APP_URL=https://your-domain.com

# Security
GATE_API_KEY=generate-random-32-char-minimum-key-here

# Database
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=tuition_management
DB_USERNAME=tuition_user
DB_PASSWORD=your-secure-password

# Mail (Production SMTP)
MAIL_MAILER=smtp
MAIL_HOST=smtp.gmail.com
MAIL_PORT=587
MAIL_USERNAME=your-email@gmail.com
MAIL_PASSWORD=your-app-password
MAIL_ENCRYPTION=tls
MAIL_FROM_ADDRESS=noreply@your-domain.com
MAIL_FROM_NAME="${APP_NAME}"

# Sanctum
SANCTUM_STATEFUL_DOMAINS=your-frontend-domain.com
SESSION_DOMAIN=.your-domain.com
```

**Action**:
```bash
cd backend
cp .env.example .env
nano .env  # Edit with your values
php artisan key:generate  # Generate APP_KEY
```

---

### 2. Create Test Database ⚠️
**Status**: Script Ready, Not Executed
**Time**: 1 minute

```bash
cd backend
./scripts/setup-test-database.sh
```

**OR** manually:
```bash
mysql -u root -p
CREATE DATABASE tuition_management_test;
EXIT;
```

---

### 3. Run Database Migrations ⚠️
**Status**: Migration Files Ready, Not Executed
**Time**: 1 minute

```bash
cd backend
php artisan migrate
```

This will:
- Create all 17+ database tables
- Add 30+ performance indexes
- Set up foreign keys and constraints

---

### 4. Register SecurityHeadersMiddleware ⚠️
**Status**: Middleware Created, Not Registered
**Time**: 2 minutes

**File to Edit**: `backend/bootstrap/app.php`

Add the middleware to the application:

```php
<?php

use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;

return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        web: __DIR__.'/../routes/web.php',
        api: __DIR__.'/../routes/api.php',
        commands: __DIR__.'/../routes/console.php',
        health: '/up',
    )
    ->withMiddleware(function (Middleware $middleware) {
        // Add this line ⬇️
        $middleware->append(\App\Http\Middleware\SecurityHeadersMiddleware::class);

        $middleware->alias([
            'role' => \App\Http\Middleware\RoleMiddleware::class,
            'gate.api.key' => \App\Http\Middleware\GateApiKeyMiddleware::class,
            'institute' => \App\Http\Middleware\InstituteMiddleware::class,
        ]);
    })
    ->withExceptions(function (Exceptions $exceptions) {
        //
    })->create();
```

---

### 5. Run Tests ⚠️
**Status**: Tests Ready, Database Setup Needed
**Time**: 2 minutes

```bash
# 1. Setup test database
cd backend
./scripts/setup-test-database.sh

# 2. Run tests
php artisan test

# Expected: All 28 tests should pass
```

---

## 🟡 Important - Should Do Before Production

### 6. Configure Rate Limiting ⚠️
**Status**: Configuration Needed
**Time**: 10 minutes

**Option A: Using Route Middleware** (Recommended)

Edit `backend/routes/api.php`:

```php
// Add rate limiting to authentication routes
Route::middleware('throttle:5,1')->group(function () {
    Route::post('/auth/login', [AuthController::class, 'login']);
    Route::post('/auth/forgot-password', [AuthController::class, 'forgotPassword']);
});

// RFID gate already has throttle via GateApiKeyMiddleware
// API routes already have default throttle:api middleware
```

**Option B: Custom Rate Limiters** (Advanced)

Create `app/Providers/RouteServiceProvider.php`:

```php
<?php

namespace App\Providers;

use Illuminate\Cache\RateLimiting\Limit;
use Illuminate\Foundation\Support\Providers\RouteServiceProvider as ServiceProvider;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\RateLimiter;

class RouteServiceProvider extends ServiceProvider
{
    public function boot(): void
    {
        RateLimiter::for('api', function (Request $request) {
            return Limit::perMinute(60)->by($request->user()?->id ?: $request->ip());
        });

        RateLimiter::for('login', function (Request $request) {
            return Limit::perMinute(5)->by($request->email . $request->ip());
        });

        RateLimiter::for('gate', function (Request $request) {
            return Limit::perMinute(120)->by($request->header('X-Gate-API-Key'));
        });
    }
}
```

---

### 7. Setup Automated Backups ⚠️
**Status**: Scripts Ready, Cron Not Configured
**Time**: 10 minutes

**Step 1: Configure Environment Variables**

Edit backup scripts or set environment variables:

```bash
export DB_NAME="tuition_management"
export DB_USER="tuition_user"
export DB_PASS="your_password"
export BACKUP_DIR="/var/backups/tuition-system"
```

**Step 2: Test Backup Scripts**

```bash
cd backend

# Test database backup
./scripts/backup-database.sh

# Test storage backup
./scripts/backup-storage.sh

# Verify backups created
ls -lh /var/backups/tuition-system/database/
ls -lh /var/backups/tuition-system/storage/
```

**Step 3: Schedule with Cron**

```bash
sudo crontab -e

# Add these lines:
# Database backup - Daily at 2 AM
0 2 * * * /path/to/backend/scripts/backup-database.sh >> /var/log/tuition-backup.log 2>&1

# Storage backup - Daily at 3 AM
0 3 * * * /path/to/backend/scripts/backup-storage.sh >> /var/log/tuition-backup.log 2>&1

# Laravel Scheduler - Every minute
* * * * * cd /path/to/backend && php artisan schedule:run >> /dev/null 2>&1
```

---

### 8. Install Error Monitoring (Sentry) ⚠️
**Status**: Not Installed (Optional but Recommended)
**Time**: 15 minutes

```bash
cd backend
composer require sentry/sentry-laravel
php artisan sentry:publish --dsn=YOUR_SENTRY_DSN
```

Add to `.env`:
```env
SENTRY_LARAVEL_DSN=https://your-key@sentry.io/your-project
SENTRY_TRACES_SAMPLE_RATE=0.2
SENTRY_ENVIRONMENT=production
```

**Get Sentry DSN**:
1. Sign up at https://sentry.io
2. Create new project (PHP/Laravel)
3. Copy the DSN key

---

## 🟢 Optional - Nice to Have

### 9. Production Server Setup ⚠️
**Status**: Documentation Ready
**Time**: 4-6 hours

Follow the complete guide in **PHASE1_PRODUCTION_READINESS.md** for:
- Ubuntu server setup
- PHP 8.2+ installation
- MySQL 8.0+ configuration
- Nginx with SSL (Let's Encrypt)
- Queue worker setup (systemd)
- Laravel scheduler (cron)

---

### 10. Mobile App Builds ⚠️
**Status**: Documentation Provided
**Time**: 1 hour per platform

**Android**:
```bash
cd student-app

# Update API URL in lib/core/constants/app_constants.dart
# static const String apiBaseUrl = 'https://api.your-domain.com/api';

# Generate keystore (one-time)
keytool -genkey -v -keystore upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias upload

# Build release
flutter build appbundle --release
```

**iOS**:
```bash
cd student-app

# Update API URL
# Configure in Xcode (Team, Bundle ID, Signing)

# Build release
flutter build ios --release
```

---

### 11. CI/CD Pipeline ⚠️
**Status**: Not Implemented
**Time**: 2-3 hours

Consider implementing:
- GitHub Actions for automated testing
- Automated deployment on merge to production
- Code quality checks (PHPStan, Laravel Pint)
- Automated security scanning

See **TESTING_GUIDE.md** for GitHub Actions example.

---

## 📋 Quick Start Checklist

### Development/Testing (15 minutes):

- [ ] Create `.env` file: `cp .env.example .env`
- [ ] Generate APP_KEY: `php artisan key:generate`
- [ ] Set database credentials in `.env`
- [ ] Create test database: `./scripts/setup-test-database.sh`
- [ ] Run migrations: `php artisan migrate`
- [ ] Register SecurityHeadersMiddleware in `bootstrap/app.php`
- [ ] Run tests: `php artisan test`
- [ ] Start dev server: `php artisan serve`

### Before Production (1-2 hours):

- [ ] Set `APP_ENV=production` in `.env`
- [ ] Set `APP_DEBUG=false` in `.env`
- [ ] Generate strong `GATE_API_KEY` (32+ chars)
- [ ] Configure production database
- [ ] Configure SMTP email settings
- [ ] Setup rate limiting
- [ ] Configure backup automation
- [ ] Install Sentry (error monitoring)
- [ ] Test all API endpoints
- [ ] Build mobile app releases

### Production Deployment (4-6 hours):

- [ ] Setup production server (Ubuntu + PHP + MySQL + Nginx)
- [ ] Configure SSL certificate (Let's Encrypt)
- [ ] Deploy application code
- [ ] Setup queue workers (systemd)
- [ ] Configure cron jobs (scheduler + backups)
- [ ] Verify backups are running
- [ ] Load test the API
- [ ] Security audit
- [ ] Monitor error logs (Sentry)

---

## 📊 Summary

### What's Complete ✅
- Test suite configured for MySQL (28 tests)
- Security middleware created
- Database optimization migrations ready
- Backup/restore scripts ready
- Comprehensive documentation
- Git branching strategy
- All code implementation done

### What Needs Action ⚠️
1. **Create .env file** (5 min)
2. **Setup test database** (1 min)
3. **Run migrations** (1 min)
4. **Register SecurityHeadersMiddleware** (2 min)
5. **Run tests** (2 min)
6. **Configure rate limiting** (10 min)
7. **Setup backup automation** (10 min)

### Total Time for Critical Items: ~30 minutes

**After these critical items, your system will be fully functional for development and testing!**

For production deployment, follow the comprehensive guides in:
- **PHASE1_PRODUCTION_READINESS.md** - Complete deployment guide
- **TESTING_GUIDE.md** - Testing with MySQL
- **QUICK_START_PRODUCTION.md** - Quick reference

---

## 🎯 Immediate Next Steps

Run these commands to get started:

```bash
# 1. Create environment file
cd backend
cp .env.example .env
nano .env  # Edit database credentials

# 2. Generate application key
php artisan key:generate

# 3. Setup test database
./scripts/setup-test-database.sh

# 4. Run migrations
php artisan migrate

# 5. Register SecurityHeadersMiddleware
# Edit bootstrap/app.php (see section 4 above)

# 6. Run tests to verify everything works
php artisan test

# 7. Start development server
php artisan serve
```

**You're almost there! Just configuration and setup remaining - no more code to write!** 🎉
