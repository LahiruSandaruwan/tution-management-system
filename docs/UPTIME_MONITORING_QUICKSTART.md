# Uptime Monitoring - Quick Start Guide

**Estimated Time:** 30 minutes
**Service:** UptimeRobot (Free Tier)
**Status:** Ready to configure

---

## Step 1: Create UptimeRobot Account (5 minutes)

### 1.1 Sign Up
1. Visit: https://uptimerobot.com
2. Click **"Register for FREE"**
3. Fill in details:
   - Email: [your-email@domain.com]
   - Password: [strong password]
4. Verify email address
5. Log in to dashboard

**Free Tier Includes:**
- 50 monitors
- 5-minute check intervals
- Unlimited alerts
- Public status pages

---

## Step 2: Add Health Check Monitors (15 minutes)

### 2.1 Main Health Check Monitor

1. Click **"+ Add New Monitor"**
2. Configure:

```
Monitor Type: HTTP(s)
Friendly Name: Tuition MS - Health Check
URL: https://your-domain.com/api/health
Monitoring Interval: 5 minutes
Monitor Timeout: 30 seconds
```

3. Click **"Create Monitor"**

---

### 2.2 Detailed System Health Monitor

1. Click **"+ Add New Monitor"**
2. Configure:

```
Monitor Type: HTTP(s)
Friendly Name: Tuition MS - System Health
URL: https://your-domain.com/api/health/detailed
Monitoring Interval: 5 minutes
Keyword Monitoring: "healthy"
Alert When Keyword: not found
```

3. Click **"Create Monitor"**

---

### 2.3 Database Health Monitor

1. Click **"+ Add New Monitor"**
2. Configure:

```
Monitor Type: HTTP(s)
Friendly Name: Tuition MS - Database
URL: https://your-domain.com/api/health/database
Monitoring Interval: 5 minutes
Keyword Monitoring: "successful"
Alert When Keyword: not found
```

3. Click **"Create Monitor"**

---

### 2.4 Cache Health Monitor

1. Click **"+ Add New Monitor"**
2. Configure:

```
Monitor Type: HTTP(s)
Friendly Name: Tuition MS - Cache
URL: https://your-domain.com/api/health/cache
Monitoring Interval: 5 minutes
Keyword Monitoring: "successful"
Alert When Keyword: not found
```

3. Click **"Create Monitor"**

---

## Step 3: Configure Alerts (5 minutes)

### 3.1 Add Email Alert

1. Go to **"My Settings"** → **"Alert Contacts"**
2. Click **"Add Alert Contact"**
3. Configure:

```
Contact Type: E-mail
Email Address: alerts@your-domain.com
Friendly Name: System Alerts Email
```

4. Verify email address
5. Assign to all monitors

---

### 3.2 Add Slack Alert (Optional)

1. Go to your Slack workspace
2. Create incoming webhook:
   - Go to: https://api.slack.com/messaging/webhooks
   - Create new app
   - Enable Incoming Webhooks
   - Copy webhook URL

3. In UptimeRobot:
   - Go to **"Alert Contacts"**
   - Click **"Add Alert Contact"**
   - Select **"Webhook"**

```
Friendly Name: Slack Alerts
URL: [Your Slack Webhook URL]
POST Value: {"text":"*{{monitorFriendlyName}}* is {{monitorAlertType}}\n{{monitorURL}}"}
```

4. Assign to critical monitors

---

### 3.3 Add SMS Alert (Optional - Paid)

1. Go to **"Alert Contacts"**
2. Click **"Add Alert Contact"**
3. Select **"SMS"**

```
Phone Number: +94 XXX XXX XXXX
Friendly Name: Emergency SMS
```

4. Assign to critical monitors only (to avoid spam)

---

## Step 4: Create Public Status Page (5 minutes)

### 4.1 Create Status Page

1. Go to **"Public Status Pages"**
2. Click **"Add New Status Page"**
3. Configure:

```
Friendly Name: Tuition Management System Status
Custom URL: tuitionms-status (or your preference)
Monitors: [Select all 4 monitors]
Show Uptime Percentages: Yes
Show Response Times: Yes
Show Logs: Last 7 days
Custom Domain: (Optional) status.your-domain.com
```

4. Click **"Create Status Page"**

---

### 4.2 Customize Status Page

1. **Design Settings:**
   - Logo: Upload your logo
   - Favicon: Upload favicon
   - Color scheme: Match your brand

2. **Content:**
   - Add custom header message
   - Add contact information
   - Add maintenance schedule

3. **Save Changes**

---

### 4.3 Get Status Page URL

Your status page will be available at:
```
https://stats.uptimerobot.com/your-custom-url
```

**Share this URL with:**
- Users (for transparency)
- Team members (for monitoring)
- Stakeholders (for reporting)

---

## Step 5: Test Monitoring (Optional)

### 5.1 Test Downtime Alert

**WARNING:** This will trigger alerts!

1. Temporarily stop your application:
   ```bash
   # Docker
   docker-compose stop app

   # Or put in maintenance mode
   php artisan down
   ```

2. Wait 5-10 minutes for UptimeRobot to detect

3. Verify you receive alerts via:
   - Email
   - Slack (if configured)
   - SMS (if configured)

4. Restart application:
   ```bash
   # Docker
   docker-compose start app

   # Or bring back online
   php artisan up
   ```

5. Verify recovery notification received

---

### 5.2 Test Keyword Monitoring

1. Temporarily break health check response:
   ```php
   // In HealthController.php - detailed() method
   // Change 'healthy' to 'unhealthy' temporarily
   'status' => 'unhealthy',
   ```

2. Wait for keyword alert

3. Revert change:
   ```php
   'status' => 'healthy',
   ```

4. Verify recovery

---

## Step 6: Configure Alert Thresholds (Advanced)

### 6.1 Alert Settings per Monitor

For each monitor, click **"Edit"** and configure:

**Alert Contacts:**
- ☑ Email (all monitors)
- ☑ Slack (critical only)
- ☑ SMS (database down only)

**Alert After:**
- Main Health: Alert after 1 check (5 min)
- Database: Alert immediately (critical)
- Cache: Alert after 2 checks (10 min)
- System: Alert after 1 check (5 min)

---

## Step 7: Set Up Maintenance Windows (Optional)

When you need scheduled maintenance:

1. Select monitor
2. Click **"Edit"**
3. Go to **"Maintenance Windows"**
4. Add window:

```
Start: [Date/Time]
End: [Date/Time]
Reason: Scheduled Maintenance
```

5. Monitoring automatically pauses during window

---

## Verification Checklist

After setup, verify:

- [ ] 4 monitors created and active
- [ ] All monitors showing "Up" status
- [ ] Email alerts configured and verified
- [ ] Slack alerts configured (if applicable)
- [ ] Public status page created
- [ ] Status page accessible
- [ ] Test alert sent and received
- [ ] Recovery notification received
- [ ] Maintenance window procedure tested

---

## Monitor Configuration Summary

| Monitor Name | URL | Interval | Keyword | Alert After |
|--------------|-----|----------|---------|-------------|
| Health Check | /api/health | 5 min | - | 1 check |
| System Health | /api/health/detailed | 5 min | "healthy" | 1 check |
| Database | /api/health/database | 5 min | "successful" | Immediately |
| Cache | /api/health/cache | 5 min | "successful" | 2 checks |

---

## Alert Channels

| Channel | Recipients | Monitors | Critical Only |
|---------|-----------|----------|---------------|
| Email | alerts@domain.com | All 4 | No |
| Slack | #alerts | All 4 | No |
| SMS | +94 XXX | Database | Yes |

---

## Expected Behavior

### Normal Operation
- All monitors: **Green (Up)**
- Response time: 30-500ms
- Uptime: 99.9%+

### Alert Triggers
- **Down:** Site unreachable
- **Keyword Missing:** "healthy" or "successful" not found
- **Timeout:** Response > 30 seconds
- **SSL:** Certificate expiring soon

### Recovery
- Automatic recovery notification
- Downtime duration logged
- Incident added to history

---

## Daily Monitoring Routine

### Morning Check (5 minutes)
1. Check UptimeRobot dashboard
2. Review overnight alerts
3. Verify all monitors green
4. Check response times

### Weekly Review (15 minutes)
1. Generate weekly report
2. Review uptime percentage
3. Analyze downtime incidents
4. Plan improvements

### Monthly Report (30 minutes)
1. Export monthly statistics
2. Calculate SLA compliance
3. Review trends
4. Share with stakeholders

---

## Troubleshooting

### Monitor Shows Down But Site Works

**Cause:** Firewall blocking UptimeRobot IPs

**Solution:**
```bash
# Whitelist UptimeRobot IPs
# Get current IPs: https://uptimerobot.com/help/locations/
# Add to firewall whitelist
```

---

### False Positive Alerts

**Causes:**
- Temporary network hiccups
- UptimeRobot maintenance
- DNS propagation

**Solutions:**
- Increase timeout (30 → 60 seconds)
- Increase alert threshold (1 → 2 checks)
- Check from multiple locations

---

### Missing Alerts

**Causes:**
- Email in spam folder
- Incorrect contact configuration
- Quiet hours configured

**Solutions:**
- Whitelist uptimerobot.com
- Verify contact settings
- Check notification logs

---

## Integration with Incident Response

When monitoring detects an issue:

1. **Alert Received** → Acknowledge immediately
2. **Investigate** → Use detailed health checks
3. **Classify** → Follow incident response plan
4. **Resolve** → Fix issue and verify restoration
5. **Document** → Log in incident response system

**See:** [INCIDENT_RESPONSE_PLAN.md](./INCIDENT_RESPONSE_PLAN.md)

---

## Cost Optimization

### Free Tier (Recommended for Start)
- 50 monitors available
- Use 4-10 monitors strategically
- 5-minute intervals sufficient
- Unlimited alerts included

**What to Monitor:**
- 4 health endpoints ✅
- 1-2 critical API endpoints
- 1 SSL certificate monitor
- **Total:** 6-7 monitors

### Paid Tier ($7/month - Optional)
- Unlimited monitors
- 1-minute check intervals
- SMS alerts included
- Advanced analytics
- Multi-location monitoring

**Upgrade When:**
- Need faster detection (< 5 min)
- Require SMS alerts
- Want advanced analytics
- Multiple locations needed

---

## Next Steps

After completing this setup:

1. ✅ **Uptime monitoring configured**
2. → **Continue with deployment** - See [DEPLOYMENT_CHECKLIST.md](./DEPLOYMENT_CHECKLIST.md)
3. → **Monitor first 24 hours** - Intensive monitoring
4. → **Generate first report** - Weekly uptime report

---

## Support & Resources

**UptimeRobot Support:**
- Help Center: https://uptimerobot.com/help/
- Community: https://uptimerobot.com/community/
- Email: support@uptimerobot.com

**Alternative Services:**
- Better Uptime: https://betteruptime.com
- Pingdom: https://www.pingdom.com
- StatusCake: https://www.statuscake.com

---

## Status Page Example

Your status page will show:

```
🟢 All Systems Operational

✅ Health Check        | 100.0% uptime | 45ms
✅ System Health       | 100.0% uptime | 120ms
✅ Database           | 100.0% uptime | 80ms
✅ Cache              | 100.0% uptime | 25ms

Last 7 Days Uptime: 99.98%
Incidents: 0
```

---

**Setup Time:** ⏱️ 30 minutes
**Status:** ✅ **READY TO CONFIGURE**

Start now: https://uptimerobot.com/signup

---

**Document Version:** 1.0
**Last Updated:** 2026-01-10
**Next Review:** After first deployment
