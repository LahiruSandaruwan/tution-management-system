# Pre-Deployment Quick Start Guide

**Total Time:** 3-4 hours
**Status:** 🟢 Ready to Execute
**Date:** __________

---

## 🎯 Overview

This guide provides the fastest path from current state to production deployment. Follow these steps in order for a successful deployment.

---

## ✅ Pre-Flight Check (5 minutes)

### System Requirements
```bash
# 1. Check all services are running
cd backend

# 2. Verify Laravel
php artisan --version
# Expected: Laravel Framework 11.x

# 3. Check database connection
php artisan db:show
# Should show connection details

# 4. Check Redis
redis-cli ping
# Expected: PONG

# 5. Verify all tests pass
php artisan test
# Expected: All 91 tests passing
```

**Status:** ☐ All checks passed ☐ Issues found (fix before continuing)

---

## 📋 Step 1: Verify Health Endpoints (2 minutes)

### Run Automated Verification

```bash
cd "/home/lahirusandaruwan/Development/my personal projects/tution-management-system"

# Make script executable (if not already)
chmod +x scripts/verify-health-endpoints.sh

# Run verification (local)
./scripts/verify-health-endpoints.sh

# Or for staging environment
BASE_URL=https://staging.your-domain.com ./scripts/verify-health-endpoints.sh
```

### Expected Output
```
=== Health Endpoints Verification ===
Base URL: http://localhost:8000

=== Test 1: Basic Health Check ===
Testing GET /api/health... ✓ PASS (HTTP 200)
Testing GET /api/health response time... ✓ PASS (45ms < 100ms)

=== Test 2: Detailed Health Check ===
Testing GET /api/health/detailed... ✓ PASS (HTTP 200, keyword found)
...

=== Test Summary ===
Total Tests: 11
Passed: 11
Failed: 0

Success Rate: 100%
✓ All health check endpoints are working correctly!
```

**Action Items:**
- [ ] All 11 tests passed
- [ ] Response times within limits
- [ ] No errors in logs

**If Failed:**
- Check application logs: `tail -f backend/storage/logs/laravel.log`
- Verify database is running
- Verify Redis is running
- Fix issues and re-run

---

## 🔍 Step 2: Set Up Uptime Monitoring (30 minutes)

### Quick Setup

**Open guide:**
```bash
cat docs/UPTIME_MONITORING_QUICKSTART.md
```

### Action Steps

**1. Create UptimeRobot Account (5 min)**
- Go to: https://uptimerobot.com/signup
- Enter email and create password
- Verify email
- Login to dashboard

**2. Add Monitors (15 min)**

Create 4 monitors with these settings:

| Monitor | URL | Interval | Keyword | Alert After |
|---------|-----|----------|---------|-------------|
| Health Check | /api/health | 5 min | - | 1 check |
| System Health | /api/health/detailed | 5 min | "healthy" | 1 check |
| Database | /api/health/database | 5 min | "successful" | 1 check |
| Cache | /api/health/cache | 5 min | "successful" | 2 checks |

**3. Configure Alerts (5 min)**
- Add email: alerts@your-domain.com
- Optional: Add Slack webhook
- Optional: Add SMS (for database only)
- Assign to all monitors

**4. Create Status Page (5 min)**
- Name: "Tuition Management System Status"
- Custom URL: tuitionms-status
- Select all 4 monitors
- Show uptime percentages: Yes
- Show response times: Yes

**Action Items:**
- [ ] Account created
- [ ] 4 monitors configured
- [ ] Alerts set up
- [ ] Status page created
- [ ] Test alert sent and received

**Status Page URL:** https://stats.uptimerobot.com/________

---

## 🧪 Step 3: User Acceptance Testing (2-3 hours)

### Preparation

**1. Deploy to Staging**
```bash
# Ensure staging environment is running
# Follow deployment checklist for staging
```

**2. Create Test Users**
```bash
cd backend

# Create test admin
php artisan tinker
> User::factory()->create(['role' => 'admin', 'email' => 'admin@test.com', 'password' => Hash::make('Admin@Test123')]);

# Create test teacher
> User::factory()->create(['role' => 'teacher', 'email' => 'teacher@test.com', 'password' => Hash::make('Teacher@Test123')]);

# Create test student
> User::factory()->create(['role' => 'student', 'email' => 'student@test.com', 'password' => Hash::make('Student@Test123')]);
```

### Run Tests

**Open UAT checklist:**
```bash
cat docs/USER_ACCEPTANCE_TESTING.md
# Or open in browser/editor for better readability
```

### Critical Tests (Must Pass)

**Priority 1: Authentication (15 min)**
- [ ] Login with valid credentials
- [ ] Login with invalid password (should fail)
- [ ] Account lockout after 5 failed attempts
- [ ] Password reset flow
- [ ] Change password

**Priority 2: Student Management (20 min)**
- [ ] Create new student
- [ ] View student details
- [ ] Update student information
- [ ] Delete student
- [ ] List all students

**Priority 3: Class & Enrollment (20 min)**
- [ ] Create new class
- [ ] Enroll student in class
- [ ] View class roster
- [ ] Remove student from class
- [ ] View class schedule

**Priority 4: Payments (20 min)**
- [ ] Record payment
- [ ] View payment history
- [ ] Generate payment report
- [ ] View defaulters list

**Priority 5: GDPR Compliance (10 min)**
- [ ] Export user data (JSON download)
- [ ] Delete user account
- [ ] Verify cascade deletion

**Priority 6: Performance (10 min)**
- [ ] Dashboard loads in < 2 seconds
- [ ] Student list loads in < 3 seconds
- [ ] API responses in < 500ms

**Priority 7: Security (15 min)**
- [ ] HTTPS enforcement
- [ ] XSS prevention (test with <script>alert('xss')</script>)
- [ ] CSRF protection
- [ ] SQL injection prevention

### Test Results

**Total Tests Completed:** ___ / 60

**Critical Failures:** ___ (must be 0 to proceed)

**Action Items:**
- [ ] All critical tests passed
- [ ] No critical bugs found
- [ ] Performance targets met
- [ ] Security tests passed
- [ ] Results documented

**If Critical Failures:**
- Document in issue tracker
- Fix immediately
- Re-run failed tests
- Do not proceed to production

---

## ⚡ Step 4: Load Testing (1-2 hours - Optional but Recommended)

### Quick Load Test

**1. Install K6 (if not installed)**
```bash
# Ubuntu/Debian
sudo apt-get install k6

# macOS
brew install k6

# Verify
k6 version
```

**2. Run Basic Health Check Load Test (5 min)**
```bash
cd load-tests

# Test with 10 concurrent users
BASE_URL=https://staging.your-domain.com \
k6 run health-check.js
```

**Expected Results:**
```
✓ status is 200
✓ response time < 100ms

checks.........................: 100.00% ✓ 2000  ✗ 0
http_req_duration..............: avg=45ms   p(95)=80ms
http_reqs......................: 2000    33.33/s
```

**3. Run Mixed Workload Test (15 min)**
```bash
# First, generate API token
# Login to your app and get token from developer tools or:
curl -X POST https://staging.your-domain.com/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@test.com","password":"Admin@Test123"}'

# Run mixed workload test
BASE_URL=https://staging.your-domain.com \
API_TOKEN=your-token-here \
k6 run mixed-workload.js
```

**Expected Results:**
```
✓ dashboard ok
✓ students ok
✓ health ok

http_req_duration{scenario:dashboard}: p(95) < 1000ms
http_req_duration{scenario:students}:  p(95) < 2000ms
http_req_duration{scenario:health}:    p(95) < 200ms
http_req_failed: < 2%
```

### Monitor During Test

**Terminal 2 - System Resources:**
```bash
htop
# Watch CPU and memory usage
# Should stay under 70% CPU
```

**Terminal 3 - Application Logs:**
```bash
tail -f backend/storage/logs/laravel.log
# Watch for errors
```

**Terminal 4 - Database Connections:**
```bash
watch -n 1 'mysql -u root -p -e "SHOW STATUS LIKE \"Threads_connected\";"'
# Should stay under 100 connections
```

### Load Test Results

**Performance Metrics:**
- Average response time: _____ ms
- 95th percentile: _____ ms
- Throughput: _____ req/s
- Failure rate: _____ %
- Max concurrent users tested: _____

**Action Items:**
- [ ] Health check: p95 < 100ms ✓
- [ ] Dashboard: p95 < 1s ✓
- [ ] Failure rate < 2% ✓
- [ ] No database errors ✓
- [ ] No memory leaks ✓

**System Capacity:**
- Can handle _____ concurrent users
- Production target: _____ concurrent users
- Headroom: _____ % (should be > 50%)

---

## 📝 Step 5: Final Pre-Deployment Checklist (15 minutes)

### Environment Configuration

**Production .env file:**
- [ ] `APP_ENV=production`
- [ ] `APP_DEBUG=false`
- [ ] `APP_URL` set to production domain
- [ ] `APP_KEY` generated (32 characters)
- [ ] Database credentials configured
- [ ] Redis credentials configured
- [ ] Mail server configured (SMTP/SendGrid)
- [ ] Sentry DSN configured
- [ ] CORS origins restricted
- [ ] `BACKUP_GPG_PASSPHRASE` set
- [ ] No sensitive data in version control

### Security Checklist

- [ ] SSL/TLS certificate installed and valid
- [ ] HTTPS redirect enabled
- [ ] Security headers configured (nginx/Apache)
- [ ] Firewall rules configured (UFW)
  - [ ] Port 22 (SSH) - restricted
  - [ ] Port 80 (HTTP) - redirect to 443
  - [ ] Port 443 (HTTPS) - open
  - [ ] Port 3306 (MySQL) - closed externally
  - [ ] Port 6379 (Redis) - closed externally
- [ ] SSH key authentication enabled
- [ ] Root login disabled
- [ ] Strong database passwords set
- [ ] File permissions correct (755/775)

### Database

- [ ] Production database created
- [ ] Database user with limited privileges
- [ ] Migrations tested on staging
- [ ] Database backups configured
- [ ] Backup encryption working
- [ ] Restore procedure tested

### Performance

- [ ] OPcache enabled
- [ ] Application cache built:
  ```bash
  php artisan config:cache
  php artisan route:cache
  php artisan view:cache
  ```
- [ ] Queue worker running (Supervisor)
- [ ] Scheduler configured (cron)
- [ ] Redis running and accessible

### Monitoring

- [ ] Sentry configured and tested
- [ ] Uptime monitoring configured (UptimeRobot)
- [ ] Health check endpoints verified
- [ ] Alert channels tested
- [ ] Status page created
- [ ] Log rotation configured

### Documentation

- [ ] Privacy Policy accessible
- [ ] Terms of Service accessible
- [ ] Cookie Policy accessible
- [ ] API documentation accessible
- [ ] Admin guide available
- [ ] Incident response plan accessible

### Legal & Compliance

- [ ] Privacy Policy reviewed
- [ ] Terms of Service reviewed
- [ ] GDPR data export tested
- [ ] Account deletion tested
- [ ] Compliance documentation complete

---

## 🚀 Step 6: Deploy to Production

### Deployment Process

**Follow the comprehensive deployment checklist:**
```bash
cat docs/DEPLOYMENT_CHECKLIST.md
```

**Quick Deployment Steps:**

1. **Backup Current System** (if upgrading)
   ```bash
   ./scripts/backup-database-encrypted.sh
   ```

2. **Put in Maintenance Mode**
   ```bash
   php artisan down --message="Deploying new version" --retry=60
   ```

3. **Deploy Code**
   ```bash
   git pull origin main
   composer install --no-dev --optimize-autoloader
   ```

4. **Run Migrations**
   ```bash
   php artisan migrate --force
   ```

5. **Build Cache**
   ```bash
   php artisan config:cache
   php artisan route:cache
   php artisan view:cache
   ```

6. **Restart Services**
   ```bash
   sudo supervisorctl restart all
   sudo systemctl restart php8.2-fpm
   sudo systemctl restart nginx
   ```

7. **Bring Online**
   ```bash
   php artisan up
   ```

8. **Verify Deployment**
   ```bash
   # Test health endpoints
   curl https://your-domain.com/api/health
   curl https://your-domain.com/api/health/detailed

   # Check logs
   tail -f storage/logs/laravel.log
   ```

---

## 📊 Step 7: Post-Deployment Monitoring (First 24 Hours)

### Hour 0-1: Critical Monitoring (Continuous)

**Every 15 minutes:**
- [ ] Check UptimeRobot dashboard (all green?)
- [ ] Check application logs for errors
- [ ] Check Sentry for exceptions
- [ ] Test critical user workflows
- [ ] Monitor server resources (CPU, memory, disk)

**Metrics to Watch:**
- Uptime: Should be 100%
- Error rate: Should be < 0.1%
- Response time: < 500ms average
- Database connections: < 100

### Hour 1-4: Active Monitoring (Hourly)

**Every hour:**
- [ ] Review application logs
- [ ] Check server resources
- [ ] Review Sentry dashboard
- [ ] Check uptime monitoring
- [ ] Monitor user feedback

### Hour 4-24: Passive Monitoring (Every 4 Hours)

**Every 4 hours:**
- [ ] Check all metrics
- [ ] Review incident reports
- [ ] Address any issues
- [ ] Update status page if needed

### First Week: Daily Monitoring

**Daily:**
- [ ] Review 24-hour metrics
- [ ] Check weekly trends
- [ ] Address user feedback
- [ ] Plan optimizations

---

## ✅ Success Criteria

### Deployment is Successful If:

**Technical:**
- ✅ Zero critical errors in first 24 hours
- ✅ Uptime ≥ 99.5% in first week
- ✅ Average response time < 500ms
- ✅ Error rate < 0.1%
- ✅ All health checks passing
- ✅ No data loss or corruption

**User Experience:**
- ✅ All critical workflows functional
- ✅ No security incidents
- ✅ Positive user feedback (< 5% negative)
- ✅ Support ticket volume normal

**Operational:**
- ✅ Monitoring working correctly
- ✅ Alerts functioning
- ✅ Backups running successfully
- ✅ Team can access all systems

---

## 🔄 Rollback Plan (If Needed)

### Immediate Rollback (Critical Issues)

If critical issues occur within first 4 hours:

```bash
# 1. Put in maintenance mode
php artisan down

# 2. Restore previous database backup
./scripts/restore-database-encrypted.sh /backups/database/backup_PREVIOUS.gpg

# 3. Checkout previous code version
git checkout <previous-stable-commit>
composer install --no-dev

# 4. Clear cache and restart
php artisan cache:clear
sudo supervisorctl restart all

# 5. Bring back online
php artisan up

# 6. Verify rollback successful
./scripts/verify-health-endpoints.sh
```

### Notify Stakeholders
- Update status page
- Send email to users
- Update team via Slack
- Document issue in incident response log

---

## 📞 Emergency Contacts

**Technical Lead:**
- Name: _____________________
- Phone: _____________________
- Email: _____________________

**DevOps/Infrastructure:**
- Name: _____________________
- Phone: _____________________
- Email: _____________________

**Product Owner:**
- Name: _____________________
- Phone: _____________________
- Email: _____________________

**Hosting Provider Support:**
- Phone: _____________________
- Email: _____________________

---

## 📋 Final Sign-Off

### Pre-Deployment Approval

**All pre-deployment tasks completed:**
- [ ] Health endpoints verified ✓
- [ ] Uptime monitoring configured ✓
- [ ] User acceptance testing passed ✓
- [ ] Load testing completed ✓
- [ ] Environment configured ✓
- [ ] Security verified ✓
- [ ] Documentation complete ✓

**Authorized to Deploy:**

**Technical Lead:** _____________________  Date: __________

**Security Lead:** _____________________  Date: __________

**Product Owner:** _____________________  Date: __________

---

## 🎯 Timeline Summary

| Phase | Duration | When |
|-------|----------|------|
| Pre-flight check | 5 min | Now |
| Health verification | 2 min | Now |
| Uptime monitoring setup | 30 min | Now |
| User acceptance testing | 2-3 hrs | Today |
| Load testing | 1-2 hrs | Today (optional) |
| Final checklist | 15 min | Before deploy |
| Deployment | 30 min | During maintenance window |
| **TOTAL** | **4-7 hrs** | **1 Day** |

---

## 🎉 You're Ready!

**Current Status:** 🟢 All preparation complete

**Next Action:** Execute steps 1-7 in order

**Support:** See comprehensive guides in `/docs` directory

**Good luck with your deployment!** 🚀

---

**Document Version:** 1.0
**Created:** 2026-01-10
**Last Updated:** 2026-01-10
**Valid For:** Production deployment v1.0.0
