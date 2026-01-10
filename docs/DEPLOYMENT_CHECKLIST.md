# Production Deployment Checklist

**System:** Tuition Management System
**Version:** 1.0.0
**Security Score:** 95/100
**Deployment Date:** _____________
**Deployed By:** _____________

---

## Pre-Deployment Checklist

### 1. Code & Testing ✅

- [ ] **All tests passing** (82 tests)
  ```bash
  cd backend && php artisan test
  ```
  - Expected: All tests pass with 80%+ coverage

- [ ] **Code quality checks passed**
  ```bash
  cd backend && vendor/bin/phpstan analyse
  cd backend && vendor/bin/php-cs-fixer fix --dry-run
  ```

- [ ] **Security audit passed**
  ```bash
  cd backend && composer audit
  ```
  - No high or critical vulnerabilities

- [ ] **Git repository clean**
  ```bash
  git status
  ```
  - No uncommitted changes
  - All changes pushed to remote

- [ ] **Latest code pulled from main branch**
  ```bash
  git checkout main
  git pull origin main
  ```

---

### 2. Environment Configuration ⚙️

- [ ] **Production .env file configured**
  - [ ] `APP_ENV=production`
  - [ ] `APP_DEBUG=false`
  - [ ] `APP_URL` set to production domain
  - [ ] Strong `APP_KEY` generated
  - [ ] Database credentials configured
  - [ ] Redis credentials configured
  - [ ] Mail server configured (SMTP/SendGrid/SES)
  - [ ] Sentry DSN configured
  - [ ] CORS origins restricted to production domains

- [ ] **Database connection verified**
  ```bash
  php artisan db:show
  ```

- [ ] **Cache driver set to Redis**
  ```
  CACHE_DRIVER=redis
  SESSION_DRIVER=redis
  QUEUE_CONNECTION=redis
  ```

- [ ] **Backup encryption configured**
  - [ ] `BACKUP_GPG_PASSPHRASE` or `BACKUP_GPG_RECIPIENT` set
  - [ ] GPG keys installed on server

---

### 3. Security Configuration 🔒

- [ ] **HTTPS/TLS Certificate installed**
  - [ ] Valid SSL certificate from Let's Encrypt or commercial CA
  - [ ] Certificate auto-renewal configured
  - [ ] HTTPS redirect enabled in nginx/Apache

- [ ] **Security headers configured** (nginx/Apache)
  ```nginx
  add_header X-Frame-Options "SAMEORIGIN" always;
  add_header X-Content-Type-Options "nosniff" always;
  add_header X-XSS-Protection "1; mode=block" always;
  add_header Referrer-Policy "strict-origin-when-cross-origin" always;
  ```

- [ ] **Firewall rules configured**
  ```bash
  ufw status
  ```
  - Port 22 (SSH) - restricted to admin IPs
  - Port 80 (HTTP) - open (redirects to HTTPS)
  - Port 443 (HTTPS) - open
  - Port 3306 (MySQL) - closed to external
  - Port 6379 (Redis) - closed to external

- [ ] **SSH access secured**
  - [ ] Key-based authentication enabled
  - [ ] Password authentication disabled
  - [ ] Root login disabled
  - [ ] Fail2ban installed and configured

- [ ] **File permissions set correctly**
  ```bash
  chown -R www-data:www-data /var/www/tuition-ms
  chmod -R 755 /var/www/tuition-ms
  chmod -R 775 /var/www/tuition-ms/storage
  chmod -R 775 /var/www/tuition-ms/bootstrap/cache
  ```

---

### 4. Database Setup 🗄️

- [ ] **Production database created**
  ```sql
  CREATE DATABASE tuition_management CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
  ```

- [ ] **Database user created with limited privileges**
  ```sql
  CREATE USER 'tuition_user'@'localhost' IDENTIFIED BY 'STRONG_PASSWORD';
  GRANT SELECT, INSERT, UPDATE, DELETE ON tuition_management.* TO 'tuition_user'@'localhost';
  FLUSH PRIVILEGES;
  ```

- [ ] **Migrations run**
  ```bash
  php artisan migrate --force
  ```

- [ ] **Seed initial data (if applicable)**
  ```bash
  php artisan db:seed --class=ProductionSeeder
  ```

- [ ] **Database backup configured**
  - [ ] Automated backup script scheduled (cron)
  - [ ] Backup encryption working
  - [ ] Backup retention set to 30 days
  - [ ] Offsite backup storage configured

- [ ] **Database performance optimized**
  - [ ] All indexes created
  - [ ] Query cache enabled (if applicable)
  - [ ] Slow query log enabled

---

### 5. Performance Optimization ⚡

- [ ] **Application caching enabled**
  ```bash
  php artisan config:cache
  php artisan route:cache
  php artisan view:cache
  php artisan event:cache
  ```

- [ ] **OPcache enabled**
  - Check `php -i | grep opcache`
  - Verify `opcache.enable=1` in php.ini

- [ ] **Redis running and accessible**
  ```bash
  redis-cli ping
  ```
  - Expected response: `PONG`

- [ ] **Queue worker running**
  ```bash
  supervisorctl status
  ```
  - Laravel queue worker should be running

- [ ] **Scheduler configured**
  ```bash
  crontab -e
  ```
  - Add: `* * * * * cd /var/www/tuition-ms && php artisan schedule:run >> /dev/null 2>&1`

---

### 6. Monitoring & Logging 📊

- [ ] **Sentry configured and verified**
  - Test error reporting:
    ```bash
    php artisan tinker
    throw new \Exception('Sentry test');
    ```
  - Verify error appears in Sentry dashboard

- [ ] **Application logs configured**
  - Log channel set to `stack` or `daily`
  - Log level set to `error` or `warning` (not `debug`)
  - Log rotation configured

- [ ] **Server monitoring set up**
  - CPU usage monitoring
  - Memory usage monitoring
  - Disk space monitoring
  - Process monitoring

- [ ] **Uptime monitoring configured**
  - [ ] UptimeRobot/Better Uptime account created
  - [ ] Health check endpoints monitored:
    - `GET /api/health`
    - `GET /api/health/detailed`
    - `GET /api/health/database`
  - [ ] Alert channels configured (Email, SMS, Slack)
  - [ ] Public status page created

---

### 7. Backup & Recovery 💾

- [ ] **Automated database backups working**
  - [ ] Test backup creation:
    ```bash
    ./scripts/backup-database-encrypted.sh
    ```
  - [ ] Verify encrypted backup file created
  - [ ] Verify backup manifest created

- [ ] **Backup restoration tested**
  - [ ] Test on staging environment:
    ```bash
    ./scripts/restore-database-encrypted.sh /backups/database/backup_*.gpg
    ```
  - [ ] Verify data restored correctly

- [ ] **Disaster recovery plan documented**
  - [ ] Server rebuild procedure
  - [ ] Database restoration procedure
  - [ ] DNS failover procedure
  - [ ] Emergency contact list

---

### 8. Legal & Compliance 📜

- [ ] **Privacy Policy published**
  - [ ] Available at `/privacy-policy`
  - [ ] Last updated date current
  - [ ] GDPR compliance verified

- [ ] **Terms of Service published**
  - [ ] Available at `/terms-of-service`
  - [ ] Subscription tiers documented
  - [ ] Refund policy clear

- [ ] **Cookie Policy published**
  - [ ] Cookie consent banner implemented
  - [ ] Cookie management options available

- [ ] **Legal review completed**
  - [ ] Privacy Policy reviewed by legal counsel
  - [ ] Terms of Service reviewed by legal counsel
  - [ ] Data Processing Agreement available

- [ ] **GDPR compliance verified**
  - [ ] Data export functionality working (`GET /api/gdpr/export-data`)
  - [ ] Account deletion working (`DELETE /api/gdpr/delete-account`)
  - [ ] Consent management implemented
  - [ ] 72-hour breach notification procedure documented

---

### 9. Documentation 📚

- [ ] **Admin user guide available**
- [ ] **API documentation accessible** (Swagger/L5-Swagger)
  - Accessible at `/api/documentation`
- [ ] **Deployment guide updated**
- [ ] **Incident response plan accessible to team**
- [ ] **Uptime monitoring setup guide followed**
- [ ] **All technical documentation up-to-date**

---

### 10. Third-Party Services 🔌

- [ ] **Email service configured and tested**
  ```bash
  php artisan tinker
  Mail::raw('Test email', function($msg) {
    $msg->to('test@example.com')->subject('Test');
  });
  ```

- [ ] **SMS service configured** (if applicable)
  - Test SMS delivery

- [ ] **Payment gateway configured** (if applicable)
  - Test mode disabled
  - Production API keys configured
  - Webhooks configured
  - Test transaction processed

- [ ] **File storage configured**
  - S3/DigitalOcean Spaces configured (if using cloud storage)
  - File upload tested
  - File permissions verified

---

## Deployment Steps

### Phase 1: Pre-Deployment (T-24 hours)

- [ ] **1. Announce maintenance window**
  - Email to all users
  - Update status page
  - Social media announcement (if applicable)

- [ ] **2. Freeze feature development**
  - No new features merged
  - Only critical bug fixes allowed

- [ ] **3. Final backup of existing system** (if upgrading)
  ```bash
  ./scripts/backup-database-encrypted.sh
  ```
  - Store backup in safe location
  - Test restoration on staging

### Phase 2: Deployment (T-0)

- [ ] **4. Put application in maintenance mode** (if upgrading)
  ```bash
  php artisan down --message="System upgrade in progress" --retry=60
  ```

- [ ] **5. Pull latest code**
  ```bash
  git fetch --all
  git checkout main
  git pull origin main
  ```

- [ ] **6. Install/update dependencies**
  ```bash
  composer install --no-dev --optimize-autoloader
  ```

- [ ] **7. Run database migrations**
  ```bash
  php artisan migrate --force
  ```

- [ ] **8. Clear and rebuild cache**
  ```bash
  php artisan cache:clear
  php artisan config:cache
  php artisan route:cache
  php artisan view:cache
  ```

- [ ] **9. Restart services**
  ```bash
  sudo supervisorctl restart all
  sudo systemctl restart php8.2-fpm
  sudo systemctl restart nginx
  ```

- [ ] **10. Bring application online**
  ```bash
  php artisan up
  ```

### Phase 3: Post-Deployment Verification (T+15 minutes)

- [ ] **11. Verify application is accessible**
  - Test homepage loads
  - Test API endpoints respond
  - Test login functionality

- [ ] **12. Verify health checks**
  ```bash
  curl https://your-domain.com/api/health
  curl https://your-domain.com/api/health/detailed
  ```
  - All should return status 200

- [ ] **13. Check logs for errors**
  ```bash
  tail -f storage/logs/laravel.log
  ```
  - No critical errors

- [ ] **14. Verify database connectivity**
  - Test database queries via application
  - Check database connection pool

- [ ] **15. Verify Redis connectivity**
  ```bash
  redis-cli ping
  php artisan tinker
  Cache::put('test', 'value', 60);
  Cache::get('test');
  ```

- [ ] **16. Test critical user workflows**
  - [ ] User registration
  - [ ] User login
  - [ ] Student enrollment
  - [ ] Payment processing
  - [ ] RFID gate access
  - [ ] Report generation

- [ ] **17. Monitor performance**
  - Check response times
  - Check server resources (CPU, memory, disk)
  - Check Sentry for errors

---

## Post-Deployment (First 24 hours)

### Hour 0-1: Critical Monitoring

- [ ] **Monitor error rates** (Sentry)
  - No critical errors
  - Error rate < 0.1%

- [ ] **Monitor API response times**
  - Average < 500ms
  - 95th percentile < 1s

- [ ] **Monitor database performance**
  - Query time < 100ms average
  - No connection pool exhaustion

- [ ] **Monitor uptime**
  - All health checks passing
  - No downtime alerts

### Hour 1-4: Active Monitoring

- [ ] **Review application logs** (hourly)
  ```bash
  tail -n 100 storage/logs/laravel.log
  ```

- [ ] **Check server resources** (hourly)
  ```bash
  htop
  df -h
  ```

- [ ] **Monitor user feedback**
  - Support tickets
  - User emails
  - Social media mentions

### Hour 4-24: Passive Monitoring

- [ ] **Review Sentry dashboard** (every 4 hours)
- [ ] **Check uptime monitoring** (every 4 hours)
- [ ] **Review server metrics** (every 4 hours)

---

## Rollback Plan

**If critical issues occur within first 4 hours:**

1. **Put application in maintenance mode**
   ```bash
   php artisan down
   ```

2. **Restore previous database backup**
   ```bash
   ./scripts/restore-database-encrypted.sh /backups/database/backup_PREVIOUS.gpg
   ```

3. **Checkout previous Git version**
   ```bash
   git checkout <previous-stable-commit>
   ```

4. **Clear cache and restart services**
   ```bash
   php artisan cache:clear
   sudo supervisorctl restart all
   ```

5. **Bring application online**
   ```bash
   php artisan up
   ```

6. **Notify stakeholders**
   - Email users about rollback
   - Update status page

---

## Post-Deployment Tasks (Week 1)

- [ ] **Day 1: Intensive monitoring**
  - Review all logs
  - Check all metrics
  - Respond to user feedback

- [ ] **Day 2-3: Standard monitoring**
  - Daily log review
  - Daily metrics check
  - Address any issues

- [ ] **Day 4-7: Reduced monitoring**
  - Check metrics every 2 days
  - Review weekly summary

- [ ] **Week 1 Report**
  - [ ] Uptime percentage
  - [ ] Error rate
  - [ ] Average response time
  - [ ] User feedback summary
  - [ ] Issues resolved
  - [ ] Lessons learned

---

## Success Criteria

**Deployment is considered successful if:**

✅ **Zero critical errors** in first 24 hours
✅ **Uptime ≥ 99.5%** in first week
✅ **Average response time < 500ms**
✅ **Error rate < 0.1%**
✅ **All health checks passing**
✅ **No data loss or corruption**
✅ **All critical workflows functional**
✅ **Positive user feedback** (< 5% negative)

---

## Deployment Sign-Off

### Pre-Deployment Approval

**Technical Lead:** _____________________ Date: ___________
**Security Lead:** _____________________ Date: ___________
**Product Owner:** _____________________ Date: ___________
**Legal Review:** _____________________ Date: ___________ (if required)

### Deployment Execution

**Deployed By:** _____________________
**Deployment Start:** ___________ (Date/Time)
**Deployment Complete:** ___________ (Date/Time)
**Duration:** ___________ minutes

### Post-Deployment Verification

**Verified By:** _____________________
**Verification Complete:** ___________ (Date/Time)
**Status:** ☐ Success ☐ Success with issues ☐ Rolled back

**Issues Found:**
- _____________________________________________________
- _____________________________________________________
- _____________________________________________________

**Resolution:**
- _____________________________________________________
- _____________________________________________________
- _____________________________________________________

---

## Emergency Contacts

**Technical Lead:**
Name: _____________________
Phone: _____________________
Email: _____________________

**DevOps Engineer:**
Name: _____________________
Phone: _____________________
Email: _____________________

**Database Administrator:**
Name: _____________________
Phone: _____________________
Email: _____________________

**Hosting Provider Support:**
Phone: _____________________
Email: _____________________
Account ID: _____________________

**SSL Certificate Provider:**
Support: _____________________
Account ID: _____________________

---

## Additional Resources

- [Deployment Guide](./DEPLOYMENT_GUIDE.md)
- [Incident Response Plan](./INCIDENT_RESPONSE_PLAN.md)
- [Encrypted Backups Guide](./ENCRYPTED_BACKUPS_GUIDE.md)
- [Uptime Monitoring Setup](./UPTIME_MONITORING_SETUP.md)
- [Security Audit Checklist](./SECURITY_AUDIT_CHECKLIST.md)

---

**Document Version:** 1.0
**Last Updated:** 2026-01-10
**Next Review:** Before next deployment

**© 2026 Tuition Management System. All rights reserved.**
