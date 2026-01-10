# Uptime Monitoring Setup Guide

**Implementation Date:** 2026-01-06
**Status:** ✅ COMPLETED
**Priority:** Medium (Operational Excellence)

---

## Overview

This guide explains how to set up external uptime monitoring for the Tuition Management System. Uptime monitoring ensures that you're immediately alerted when your service experiences downtime or performance issues.

**Benefits:**
- 🔔 **Instant Alerts** - Get notified immediately when your site goes down
- 📊 **Performance Metrics** - Track response times and uptime percentage
- 📈 **Historical Data** - Analyze uptime trends over time
- 🌐 **Public Status Page** - Keep users informed during outages
- 📱 **Multi-Channel Alerts** - Email, SMS, Slack, webhooks

---

## Health Check Endpoints

We've implemented comprehensive health check endpoints:

### 1. Basic Health Check

**Endpoint:** `GET /api/health`

**Purpose:** Quick health check for load balancers and monitoring services

**Response:**
```json
{
  "status": "ok",
  "timestamp": "2026-01-06T15:42:30Z"
}
```

**Status Codes:**
- `200` - Service is healthy

---

### 2. Detailed Health Check

**Endpoint:** `GET /api/health/detailed`

**Purpose:** Comprehensive health check with component status

**Response:**
```json
{
  "status": "healthy",
  "timestamp": "2026-01-06T15:42:30Z",
  "checks": {
    "database": {
      "status": "up",
      "message": "Database connection successful"
    },
    "cache": {
      "status": "up",
      "message": "Cache working correctly",
      "driver": "redis"
    },
    "storage": {
      "status": "up",
      "message": "Storage read/write successful"
    }
  },
  "application": {
    "name": "Tuition Management System",
    "environment": "production",
    "version": "1.0.0"
  },
  "system": {
    "php_version": "8.2.0",
    "laravel_version": "11.x"
  }
}
```

**Status Values:**
- `healthy` - All systems operational (HTTP 200)
- `degraded` - Partial functionality (HTTP 200)
- `unhealthy` - Service unavailable (HTTP 503)

---

### 3. Database Health Check

**Endpoint:** `GET /api/health/database`

**Response:**
```json
{
  "status": "up",
  "database": "tuition_db",
  "connection": "successful",
  "test_query": "passed",
  "timestamp": "2026-01-06T15:42:30Z"
}
```

---

### 4. Cache Health Check

**Endpoint:** `GET /api/health/cache`

**Response:**
```json
{
  "status": "up",
  "driver": "redis",
  "write": "successful",
  "read": "successful",
  "timestamp": "2026-01-06T15:42:30Z"
}
```

---

## Recommended Monitoring Services

### Option 1: UptimeRobot (Recommended for Starters)

**Pros:**
- ✅ Free tier (50 monitors, 5-minute intervals)
- ✅ Easy setup
- ✅ Public status pages
- ✅ Multi-channel alerts
- ✅ No credit card required

**Pricing:**
- **Free:** 50 monitors, 5-min checks
- **Pro ($7/mo):** Unlimited monitors, 1-min checks, advanced features

**Setup Time:** 10 minutes

---

### Option 2: Better Uptime

**Pros:**
- ✅ Modern interface
- ✅ Incident management
- ✅ On-call scheduling
- ✅ Status pages
- ✅ 30-second check intervals

**Pricing:**
- **Free:** 10 monitors
- **Team ($18/mo):** 50 monitors
- **Business ($69/mo):** 200 monitors

**Setup Time:** 15 minutes

---

### Option 3: Pingdom

**Pros:**
- ✅ Enterprise-grade monitoring
- ✅ Detailed performance insights
- ✅ Real user monitoring
- ✅ Transaction monitoring
- ✅ Mobile apps

**Pricing:**
- **Starter ($10/mo):** 10 uptime checks
- **Advanced ($34/mo):** 30 uptime checks, RUM
- **Professional ($80/mo):** 100 uptime checks

**Setup Time:** 20 minutes

---

### Option 4: StatusCake

**Pros:**
- ✅ Generous free tier
- ✅ Page speed monitoring
- ✅ Domain monitoring
- ✅ SSL monitoring
- ✅ Virus scanning

**Pricing:**
- **Free:** Unlimited tests, 5-min intervals
- **Superior ($24.99/mo):** 1-min intervals, advanced features

**Setup Time:** 15 minutes

---

## Setup Instructions

### UptimeRobot Setup (Step-by-Step)

#### Step 1: Create Account

1. Visit https://uptimerobot.com
2. Click "Register for FREE"
3. Enter email and password
4. Verify email address

#### Step 2: Add Main Monitor

1. Click "Add New Monitor"
2. Configure:

```
Monitor Type: HTTP(s)
Friendly Name: Tuition MS - Main Site
URL: https://your-domain.com/api/health
Monitoring Interval: 5 minutes
Monitor Timeout: 30 seconds
```

3. Click "Create Monitor"

#### Step 3: Add Detailed Health Monitor

1. Click "Add New Monitor"
2. Configure:

```
Monitor Type: HTTP(s)
Friendly Name: Tuition MS - System Health
URL: https://your-domain.com/api/health/detailed
Monitoring Interval: 5 minutes
Keyword Monitoring: "healthy"
Alert When Keyword: not found
```

3. Click "Create Monitor"

#### Step 4: Add Database Monitor

1. Click "Add New Monitor"
2. Configure:

```
Monitor Type: HTTP(s)
Friendly Name: Tuition MS - Database
URL: https://your-domain.com/api/health/database
Monitoring Interval: 5 minutes
Keyword Monitoring: "successful"
```

3. Click "Create Monitor"

#### Step 5: Add API Endpoint Monitor

1. Click "Add New Monitor"
2. Configure:

```
Monitor Type: HTTP(s)
Friendly Name: Tuition MS - API Login
URL: https://your-domain.com/api/auth/login
Monitoring Interval: 5 minutes
Method: POST (if supported)
Expected Status Code: 422 (validation error is OK - means API is responding)
```

3. Click "Create Monitor"

#### Step 6: Configure Alert Contacts

1. Go to "My Settings" > "Alert Contacts"
2. Add contacts:

**Email Alert:**
```
Contact Type: E-mail
Email Address: alerts@your-domain.com
Friendly Name: System Alerts Email
```

**SMS Alert (Optional):**
```
Contact Type: SMS
Phone Number: +94 XXX XXX XXXX
Friendly Name: Emergency SMS
```

**Slack Alert (Optional):**
```
Contact Type: Webhook
URL: [Your Slack Webhook URL]
Friendly Name: Slack Alerts
```

3. For each monitor, edit and assign alert contacts

#### Step 7: Create Public Status Page

1. Go to "Public Status Pages"
2. Click "Add New Status Page"
3. Configure:

```
Friendly Name: Tuition Management System Status
Custom URL: tuitionms-status (or your preference)
Select Monitors: [Select all monitors]
Show Uptime Percentages: Yes
Show Response Times: Yes
```

4. Click "Create Status Page"
5. Share URL: https://stats.uptimerobot.com/your-custom-url

---

## Alert Configuration Best Practices

### Alert Thresholds

**Immediate Alerts (Critical):**
- Service completely down
- Database connection failure
- 5xx error responses

**Warning Alerts (Medium):**
- Response time > 3 seconds
- Degraded health status
- SSL certificate expiring (30 days)

**Informational Alerts (Low):**
- Weekly uptime reports
- Monthly performance summaries

### Alert Channels

**Email:**
- All alerts
- Primary notification channel
- Distribution list: ops@, dev@, support@

**SMS:**
- Critical alerts only
- Service down > 5 minutes
- Database failures
- On-call personnel

**Slack:**
- All alerts
- #alerts or #operations channel
- Enables team collaboration

**PagerDuty/Opsgenie (Optional):**
- Critical alerts
- On-call rotation
- Escalation policies

### Alert Escalation

**Level 1 (0-5 minutes):**
- Email to on-call engineer
- Slack notification

**Level 2 (5-15 minutes):**
- SMS to on-call engineer
- Email to team lead

**Level 3 (15+ minutes):**
- SMS to team lead
- Email to management
- Activate incident response plan

---

## Monitoring Checklist

### Essential Monitors

- [ ] Main application health (`/api/health`)
- [ ] Detailed system health (`/api/health/detailed`)
- [ ] Database connectivity (`/api/health/database`)
- [ ] Cache functionality (`/api/health/cache`)
- [ ] Login API (`/api/auth/login`)
- [ ] Dashboard API (`/api/dashboard/stats`)

### Optional Monitors

- [ ] RFID gate API (`/api/gate/verify`)
- [ ] Payment processing
- [ ] File uploads
- [ ] Email sending
- [ ] SMS gateway

### Infrastructure Monitors

- [ ] SSL certificate expiration
- [ ] Domain expiration
- [ ] DNS resolution
- [ ] CDN status (if applicable)

### Performance Monitors

- [ ] Page load time < 2 seconds
- [ ] API response time < 500ms
- [ ] Database query time < 100ms

---

## SLA Targets

### Uptime Targets

| Service Tier | Monthly Uptime | Downtime Allowed | Response Time |
|--------------|----------------|------------------|---------------|
| **Starter** | 99.0% | ~7 hours | < 3 seconds |
| **Growth** | 99.5% | ~3.5 hours | < 2 seconds |
| **Professional** | 99.9% | ~43 minutes | < 1 second |
| **Enterprise** | 99.99% | ~4 minutes | < 500ms |

### Calculation

**Monthly Uptime:**
```
Uptime % = (Total Time - Downtime) / Total Time × 100

99.9% uptime = 99.9% × 730 hours = 729.27 hours up
Allowed downtime = 730 - 729.27 = 0.73 hours = 43.8 minutes
```

---

## Dashboard Integration

### Embed Status Badge

Add uptime status to your documentation:

```markdown
[![Uptime](https://img.shields.io/uptimerobot/ratio/7/m123456789-abc123def456)](https://stats.uptimerobot.com/your-page)
```

### Status Page Widget

Embed on your website:

```html
<script src="https://stats.uptimerobot.com/widget.js"></script>
<div class="uptime-widget" data-id="your-widget-id"></div>
```

---

## Incident Response Integration

When monitoring detects an issue:

1. **Automatic Alert** → Sent via configured channels
2. **Acknowledge** → On-call engineer acknowledges
3. **Investigate** → Use detailed health checks to diagnose
4. **Resolve** → Fix issue and verify restoration
5. **Post-Mortem** → Document in incident response plan

**Integration with Incident Response Plan:**
- Alerts trigger incident classification
- Health check data aids investigation
- Restoration verified by monitoring
- Uptime reports for post-mortems

---

## Maintenance Windows

### Scheduled Maintenance

**Best Practices:**
1. Announce 7 days in advance
2. Schedule during off-peak hours
3. Pause monitoring during maintenance
4. Keep maintenance under 4 hours
5. Update status page

**UptimeRobot Pause:**
```
1. Select monitor
2. Click "Edit"
3. Under "Maintenance Windows"
4. Set start and end time
5. Monitor automatically pauses/resumes
```

---

## Reporting

### Weekly Report

**Metrics to Track:**
- Overall uptime percentage
- Number of incidents
- Average response time
- Longest outage duration

**Distribution:**
- Engineering team
- Product owner
- Stakeholders

### Monthly Report

**Include:**
- Uptime trends
- Performance trends
- Incident summary
- Improvement recommendations
- SLA compliance status

**Template:**
```markdown
# Monthly Uptime Report - [Month Year]

## Summary
- Overall Uptime: 99.95%
- Total Incidents: 2
- Average Response Time: 180ms
- SLA Status: ✅ Met

## Incidents
1. [Date] - Database connectivity issue (15min)
2. [Date] - High traffic spike (5min)

## Performance
- Best Response Time: 95ms
- Worst Response Time: 450ms
- Average: 180ms

## Recommendations
- Optimize database queries
- Implement caching for dashboard
```

---

## Testing Monitoring

### Test Downtime Alert

1. Temporarily stop application:
   ```bash
   docker-compose stop app
   ```

2. Wait for alert (5 minutes on free tier)
3. Verify alert received via all channels
4. Restart application:
   ```bash
   docker-compose start app
   ```

5. Verify recovery notification

### Test Performance Alert

1. Simulate slow response:
   ```php
   // Temporarily add to health check
   sleep(5); // 5-second delay
   ```

2. Wait for response time alert
3. Remove delay
4. Verify recovery

---

## Cost Optimization

### Free Tier Recommendations

**UptimeRobot Free:**
- 50 monitors available
- Use 10-15 monitors strategically
- Focus on critical endpoints
- 5-minute intervals sufficient
- Public status page included

**What to Monitor on Free Tier:**
1. Main health check
2. Database health
3. Login API
4. Dashboard API
5. Payment API (if applicable)
6. SSL certificate

**Save Premium for:**
- 1-minute check intervals
- Advanced analytics
- Multi-location monitoring
- SMS alerts (pay per SMS)

---

## Advanced Configuration

### Multi-Location Monitoring

Monitor from multiple geographic locations:
- **North America:** New York, San Francisco
- **Europe:** London, Frankfurt
- **Asia:** Singapore, Tokyo

**Benefits:**
- Detect regional outages
- Verify CDN performance
- Measure global latency

### Transaction Monitoring

Monitor complex user flows:
1. Login
2. Navigate to dashboard
3. Create record
4. Verify creation

**Requires:** Pingdom or similar premium service

### API Key Authentication

For protected endpoints:
```
Custom HTTP Headers:
X-API-Key: your-api-key-here
```

---

## Troubleshooting

### False Positive Alerts

**Causes:**
- Network hiccups
- Monitoring service issues
- DNS propagation
- Firewall blocking monitoring IPs

**Solutions:**
- Increase timeout (30 → 60 seconds)
- Check from multiple locations
- Whitelist monitoring IPs
- Confirm with manual test

### Missing Alerts

**Causes:**
- Email in spam folder
- Incorrect contact configuration
- Alert contact not assigned to monitor
- Quiet hours configured

**Solutions:**
- Whitelist monitoring emails
- Verify contact configuration
- Check monitor alert settings
- Review notification logs

---

## Compliance

### SOC 2 Compliance

Uptime monitoring supports:
- **Availability:** Continuous monitoring
- **Performance:** Response time tracking
- **Incident Management:** Alert logs
- **Reporting:** Uptime reports

### GDPR Compliance

Ensure monitoring service:
- Has GDPR-compliant DPA
- Stores data in appropriate regions
- Provides data deletion
- Transparent privacy policy

---

## Next Steps

1. ✅ **Choose Monitoring Service** - UptimeRobot recommended for start
2. ✅ **Create Account** - Sign up and verify email
3. ✅ **Configure Monitors** - Add health check endpoints
4. ✅ **Set Up Alerts** - Configure email, SMS, Slack
5. ✅ **Create Status Page** - Public transparency
6. ✅ **Test Alerts** - Verify notifications work
7. ✅ **Document SLAs** - Set uptime targets
8. ✅ **Integrate with Incident Response** - Link to IR plan
9. ✅ **Schedule Reviews** - Weekly/monthly reports
10. ✅ **Continuous Improvement** - Optimize based on data

---

## Conclusion

External uptime monitoring is essential for maintaining service reliability and user trust. With properly configured monitoring:

- **Early Detection** - Know about issues before users complain
- **Faster Resolution** - Detailed health checks aid troubleshooting
- **Better Communication** - Status pages keep users informed
- **Data-Driven Decisions** - Performance data guides improvements
- **SLA Compliance** - Track and meet uptime commitments

**Status:** ✅ Infrastructure ready for monitoring
**Recommendation:** Set up UptimeRobot free tier within 24 hours

---

**Document Version:** 1.0
**Last Updated:** 2026-01-06
**Next Review:** Monthly
**Maintainer:** Operations Team
