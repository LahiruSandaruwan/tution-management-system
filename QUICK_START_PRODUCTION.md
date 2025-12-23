# Quick Start: Production Deployment

## 5-Minute Setup (Development Testing)

```bash
# 1. Install dependencies (if not already done)
cd backend
composer install

# 2. Setup environment
cp .env.example .env
# Edit .env with your database credentials

# 3. Generate key
php artisan key:generate

# 4. Run migrations with new indexes
php artisan migrate:fresh --seed

# 5. Run tests
php artisan test

# 6. Start server
php artisan serve
```

## Production Deployment (Full Guide)

See comprehensive guides:
- **Implementation Details**: [PHASE1_PRODUCTION_READINESS.md](PHASE1_PRODUCTION_READINESS.md)
- **Completion Summary**: [PHASE1_COMPLETED.md](PHASE1_COMPLETED.md)

## Critical Security Steps

1. **Update .env**:
```env
APP_ENV=production
APP_DEBUG=false
APP_KEY=base64:YOUR_GENERATED_KEY
GATE_API_KEY=your-super-secure-32-char-minimum-key
```

2. **Register Security Middleware**:
Edit `bootstrap/app.php`:
```php
->withMiddleware(function (Middleware $middleware) {
    $middleware->append(\App\Http\Middleware\SecurityHeadersMiddleware::class);
})
```

3. **Setup Backups**:
```bash
chmod +x backend/scripts/*.sh
./backend/scripts/backup-database.sh
```

4. **Add to Cron**:
```bash
crontab -e
# Add:
0 2 * * * /path/to/backend/scripts/backup-database.sh
```

## Quick Test Commands

```bash
# Run all tests
php artisan test

# Test specific feature
php artisan test --filter AuthenticationTest

# Check database indexes
php artisan tinker
>>> Schema::getIndexes('payments');

# Test backup
./scripts/backup-database.sh

# View logs
tail -f storage/logs/laravel.log
```

## Mobile App Quick Build

```bash
# Android
cd student-app
flutter build apk --release

# iOS
flutter build ios --release
```

## Troubleshooting

**Tests failing (SQLite error)**:
```bash
sudo apt-get install php-sqlite3
```

**Permission errors**:
```bash
sudo chown -R www-data:www-data storage bootstrap/cache
sudo chmod -R 775 storage bootstrap/cache
```

**Queue not processing**:
```bash
php artisan queue:work --daemon
```

## Production Checklist

- [ ] Tests pass: `php artisan test`
- [ ] Migrations run: `php artisan migrate`
- [ ] APP_ENV=production
- [ ] APP_DEBUG=false
- [ ] Strong APP_KEY set
- [ ] Strong GATE_API_KEY set
- [ ] Backups configured
- [ ] Security middleware registered
- [ ] SSL certificate installed
- [ ] Queue worker running
- [ ] Cron jobs configured

## Support

For detailed guides, see:
- [PHASE1_PRODUCTION_READINESS.md](PHASE1_PRODUCTION_READINESS.md) - Complete implementation guide
- [PHASE1_COMPLETED.md](PHASE1_COMPLETED.md) - What's been completed
- [SETUP_GUIDE.md](SETUP_GUIDE.md) - Development setup
- [README.md](README.md) - Project overview
