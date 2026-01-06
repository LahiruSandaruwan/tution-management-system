# Incident Response Plan

**Document Version:** 1.0
**Effective Date:** 2026-01-06
**Review Frequency:** Quarterly
**Next Review:** 2026-04-06

---

## Table of Contents

1. [Purpose](#purpose)
2. [Scope](#scope)
3. [Incident Response Team](#incident-response-team)
4. [Incident Classification](#incident-classification)
5. [Response Procedures](#response-procedures)
6. [Communication Plan](#communication-plan)
7. [Recovery Procedures](#recovery-procedures)
8. [Post-Incident Activities](#post-incident-activities)
9. [Contact Information](#contact-information)

---

## Purpose

This Incident Response Plan establishes procedures for identifying, responding to, and recovering from security incidents affecting the Tuition Management System. The plan aims to:

- Minimize damage and recovery time
- Preserve evidence for investigation
- Maintain system availability and data integrity
- Comply with legal and regulatory requirements
- Learn from incidents to improve security

---

## Scope

### Covered Incidents

This plan covers security incidents including:

- **Data Breaches** - Unauthorized access to student/payment data
- **System Compromise** - Malware, ransomware, or unauthorized access
- **Denial of Service** - Attacks that impact system availability
- **Data Loss** - Accidental or malicious data deletion
- **Account Compromise** - Unauthorized access to user accounts
- **Infrastructure Failures** - Database, server, or network failures
- **Third-Party Breaches** - Compromise of integrated services

### Out of Scope

- General IT support requests
- Planned maintenance
- User error (unless security-related)
- Natural disasters (covered in Business Continuity Plan)

---

## Incident Response Team

### Team Structure

| Role | Responsibilities | Contact |
|------|------------------|---------|
| **Incident Commander** | Overall incident coordination | TBD |
| **Technical Lead** | Technical investigation and remediation | TBD |
| **Communications Lead** | Internal and external communications | TBD |
| **Legal Counsel** | Legal compliance and liability | TBD |
| **Data Protection Officer** | Privacy and GDPR compliance | TBD |

### Team Activation

The team is activated when:
- Critical severity incident detected
- Data breach suspected or confirmed
- System unavailability exceeds 30 minutes
- Regulatory reporting required

---

## Incident Classification

### Severity Levels

#### 🔴 CRITICAL (P1)
**Response Time:** Immediate (within 15 minutes)

**Examples:**
- Active data breach with confirmed data exfiltration
- Ransomware encryption of production data
- Complete system outage affecting all users
- Payment processing system compromise

**Actions:**
- Activate full incident response team
- Implement containment immediately
- Notify executive leadership within 1 hour
- Consider law enforcement notification

---

#### 🟠 HIGH (P2)
**Response Time:** Within 1 hour

**Examples:**
- Suspected unauthorized access to database
- Malware detected on production servers
- DDoS attack causing performance degradation
- Privilege escalation vulnerability exploited

**Actions:**
- Activate incident response team
- Begin investigation and containment
- Notify management within 4 hours
- Prepare customer communication

---

#### 🟡 MEDIUM (P3)
**Response Time:** Within 4 hours

**Examples:**
- Brute force attack on login endpoints
- Suspicious user account activity
- Minor data exposure (limited scope)
- Service degradation affecting specific features

**Actions:**
- Assign incident to technical lead
- Investigate and document
- Implement fixes within 24 hours
- Internal notification only

---

#### 🟢 LOW (P4)
**Response Time:** Within 24 hours

**Examples:**
- Failed login attempts (within normal thresholds)
- Minor configuration issues
- Outdated software dependencies
- Non-critical vulnerabilities

**Actions:**
- Log and track in ticketing system
- Address during normal maintenance
- No immediate escalation required

---

## Response Procedures

### Phase 1: Detection & Analysis (0-30 minutes)

#### 1.1 Detection Methods

- **Automated Monitoring**
  - Sentry error tracking
  - Log aggregation (ELK stack)
  - Intrusion detection systems
  - Uptime monitoring alerts

- **Manual Detection**
  - User reports
  - Security audit findings
  - Penetration test results

#### 1.2 Initial Assessment

**Checklist:**
- [ ] Confirm incident is genuine (not false positive)
- [ ] Classify severity level (P1-P4)
- [ ] Document initial observations
- [ ] Preserve evidence (logs, screenshots)
- [ ] Activate appropriate response team

**Key Questions:**
1. What systems are affected?
2. When did the incident start?
3. How was it detected?
4. What data is at risk?
5. Is it still ongoing?

---

### Phase 2: Containment (30-60 minutes)

#### 2.1 Short-Term Containment

**For Data Breach:**
```bash
# 1. Isolate affected systems
docker-compose stop app

# 2. Block malicious IP addresses
iptables -A INPUT -s <MALICIOUS_IP> -j DROP

# 3. Disable compromised accounts
mysql -u root -p -e "UPDATE users SET is_active=0 WHERE email IN (...);"

# 4. Enable enhanced logging
sed -i 's/LOG_LEVEL=info/LOG_LEVEL=debug/' .env
docker-compose restart
```

**For Malware/Ransomware:**
```bash
# 1. Disconnect from network immediately
docker network disconnect tuition-network app

# 2. Take memory dump for forensics
docker exec app cat /proc/*/maps > memory_dump.txt

# 3. Snapshot current state
docker commit app compromised-app-snapshot

# 4. Kill malicious processes
docker exec app pkill -f <MALICIOUS_PROCESS>
```

**For DDoS Attack:**
```bash
# 1. Enable rate limiting
# Edit nginx.conf
limit_req_zone $binary_remote_addr zone=ddos:10m rate=10r/s;
limit_req zone=ddos burst=20 nodelay;

# 2. Block attack source
# Update firewall rules

# 3. Enable CloudFlare DDoS protection
# Login to CloudFlare dashboard, enable "I'm Under Attack" mode
```

#### 2.2 Long-Term Containment

- Deploy security patches
- Implement additional access controls
- Rebuild compromised systems from clean backups
- Update firewall rules permanently

---

### Phase 3: Eradication (1-4 hours)

#### 3.1 Root Cause Analysis

**Investigation Steps:**
1. **Review Logs**
   ```bash
   # Application logs
   tail -1000 storage/logs/laravel.log | grep ERROR

   # Nginx access logs
   docker logs tuition-nginx | grep "POST /api/auth/login"

   # Database query logs
   docker exec mysql cat /var/lib/mysql/mysql-slow.log
   ```

2. **Check for Backdoors**
   ```bash
   # Search for suspicious files
   find . -name "*.php" -mtime -7 -exec grep -l "eval\|base64_decode\|system" {} \;

   # Check for unauthorized users
   mysql -u root -p -e "SELECT * FROM users WHERE created_at > NOW() - INTERVAL 24 HOUR;"
   ```

3. **Verify Integrity**
   ```bash
   # Compare file checksums
   find . -type f -exec md5sum {} \; > current_checksums.txt
   diff baseline_checksums.txt current_checksums.txt
   ```

#### 3.2 Remediation Actions

| Incident Type | Remediation |
|---------------|-------------|
| **SQL Injection** | Patch vulnerable code, update prepared statements |
| **XSS Attack** | Implement output encoding, CSP headers |
| **Compromised Credentials** | Force password reset, revoke all tokens |
| **Malware** | Remove malicious code, rebuild from clean state |
| **Misconfiguration** | Correct settings, implement IaC validation |

---

### Phase 4: Recovery (4-24 hours)

#### 4.1 System Restoration

**From Encrypted Backup:**
```bash
# 1. List available backups
ls -lh /backups/database/*.gpg

# 2. Verify backup integrity
sha256sum /backups/database/backup_*.gpg

# 3. Restore database
./scripts/restore-database-encrypted.sh /backups/database/backup_latest.gpg

# 4. Verify restoration
mysql -u root -p -e "SELECT COUNT(*) FROM students;"

# 5. Restart services
docker-compose up -d
```

#### 4.2 Service Validation

**Post-Recovery Checklist:**
- [ ] All services running
- [ ] Database connectivity verified
- [ ] User authentication working
- [ ] Payment processing functional
- [ ] RFID gate access operational
- [ ] Email sending working
- [ ] Reports generating correctly
- [ ] Mobile app connectivity confirmed

#### 4.3 Monitoring

**Enhanced Monitoring (48 hours post-incident):**
```bash
# Increase log retention
LOG_RETENTION_DAYS=90

# Enable detailed access logging
NGINX_LOG_LEVEL=debug

# Alert on suspicious patterns
# Set up alerts for:
# - Multiple failed logins
# - Unusual database queries
# - Large data exports
# - Off-hours admin access
```

---

## Communication Plan

### Internal Communication

#### Immediate Notification (Within 15 minutes)
**Recipients:** Incident Response Team
**Method:** Phone call + SMS
**Template:**
```
URGENT: Security Incident Detected

Severity: [P1/P2/P3/P4]
System: Tuition Management System
Impact: [Brief description]
Status: [Detection/Containment/Recovery]

Incident Commander: [Name]
War Room: [Video call link]
Updates: Every 30 minutes
```

#### Management Notification (Within 1-4 hours)
**Recipients:** Executive Team, Board of Directors (if P1)
**Method:** Email + Executive Dashboard
**Template:**
```
Subject: Security Incident Report - [Severity Level]

Executive Summary:
- Incident Type: [Data breach/System compromise/etc.]
- Detection Time: [Timestamp]
- Affected Systems: [List]
- Data Impact: [Number of records/users affected]
- Current Status: [Contained/Under investigation/Resolved]

Actions Taken:
1. [Action 1]
2. [Action 2]
3. [Action 3]

Next Steps:
- [Timeline and planned actions]

Risk Assessment:
- Reputation: [Low/Medium/High]
- Financial: [Estimated cost]
- Regulatory: [Reporting requirements]

Contact: [Incident Commander Name & Phone]
```

---

### External Communication

#### Customer Notification (P1/P2 Incidents)

**Timing:** Within 72 hours of discovery (GDPR requirement)

**Template:**
```
Subject: Important Security Notice - Tuition Management System

Dear [Institute Name],

We are writing to inform you of a security incident that may have affected
your data in our Tuition Management System.

What Happened:
On [Date], we discovered [brief description of incident]. We immediately
took action to [containment measures].

What Information Was Involved:
The incident may have affected: [specific data types - names, emails, etc.]

What We Are Doing:
- Investigated and contained the incident
- Enhanced security measures
- Notified appropriate authorities
- Offering [credit monitoring/support/etc.]

What You Can Do:
- Change your password immediately
- Enable two-factor authentication
- Monitor account for suspicious activity
- Contact us with any concerns: [phone/email]

We sincerely apologize for this incident and the concern it may cause.

For more information: [FAQ link]
Support: [contact information]

Sincerely,
[Name, Title]
Tuition Management System
```

#### Regulatory Notification

**GDPR - Data Protection Authority:**
- **Timeline:** Within 72 hours
- **Method:** Online portal submission
- **Requirements:** Nature of breach, data categories, likely consequences, measures taken

**Payment Card Industry (if applicable):**
- **Timeline:** Immediately
- **Recipients:** Payment processor, acquiring bank
- **Requirements:** Detailed incident report, forensics, remediation plan

---

## Recovery Procedures

### Database Recovery

**Scenario: Complete database loss**

```bash
# 1. Verify database is unavailable
docker exec mysql mysql -u root -p -e "SHOW DATABASES;"

# 2. Stop all services
docker-compose down

# 3. Restore from latest encrypted backup
./scripts/restore-database-encrypted.sh /backups/database/backup_latest.gpg

# 4. Verify restoration
docker-compose up -d mysql
docker exec mysql mysql -u root -p -e "SELECT COUNT(*) FROM users;"

# 5. Restart application services
docker-compose up -d

# 6. Run database migrations (if needed)
docker exec app php artisan migrate --force

# 7. Clear caches
docker exec app php artisan cache:clear
docker exec app php artisan config:clear

# 8. Verify application functionality
curl -X POST http://localhost/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@test.com","password":"password"}'
```

---

### Application Recovery

**Scenario: Compromised application code**

```bash
# 1. Stop compromised containers
docker-compose down app

# 2. Pull clean code from repository
git fetch origin
git reset --hard origin/main

# 3. Rebuild application image
docker-compose build --no-cache app

# 4. Rotate all secrets
# Update .env file with new:
# - APP_KEY
# - DB_PASSWORD
# - API_KEYS

# 5. Revoke all user sessions
docker exec mysql mysql -u root -p -e "TRUNCATE personal_access_tokens;"

# 6. Restart services
docker-compose up -d

# 7. Force all users to reset passwords
docker exec app php artisan auth:clear-sessions
```

---

## Post-Incident Activities

### Lessons Learned Meeting

**Timeline:** Within 5 business days of incident resolution

**Agenda:**
1. Incident timeline review
2. What went well?
3. What could be improved?
4. Root cause analysis
5. Action items

**Attendees:**
- Incident Response Team
- Affected system owners
- Management (for P1/P2)

---

### Post-Incident Report

**Template:**

```markdown
# Incident Post-Mortem Report

**Incident ID:** INC-2026-001
**Date:** 2026-01-06
**Severity:** P1
**Duration:** 4 hours

## Executive Summary
[2-3 sentence overview]

## Timeline
| Time | Event |
|------|-------|
| 14:30 | Initial detection via Sentry alert |
| 14:35 | Team activated |
| 14:45 | Containment implemented |
| 15:30 | Root cause identified |
| 17:00 | Systems restored |
| 18:30 | Full functionality confirmed |

## Impact
- **Users Affected:** 150 institutes
- **Data Exposed:** Student names and email addresses
- **Downtime:** 4 hours
- **Financial:** $5,000 estimated

## Root Cause
[Detailed technical explanation]

## Response Effectiveness
**What Went Well:**
- Rapid detection (5 minutes)
- Clear communication
- Backup restoration worked flawlessly

**What Could Improve:**
- Faster containment (target <30 min)
- Better runbook documentation
- Automated rollback capability

## Action Items
| Action | Owner | Due Date | Priority |
|--------|-------|----------|----------|
| Implement WAF rules | Security Team | 2026-01-20 | High |
| Update incident playbook | Tech Lead | 2026-01-13 | Medium |
| Conduct DR drill | Ops Team | 2026-02-01 | High |

## Recommendations
1. Implement intrusion detection system
2. Enhanced logging for auth endpoints
3. Quarterly security training

**Report Prepared By:** [Name]
**Date:** [Date]
```

---

### Continuous Improvement

**Quarterly Activities:**
- Review and update incident response plan
- Conduct tabletop exercises
- Test backup restoration
- Update contact information
- Review incident trends

**Annual Activities:**
- Full disaster recovery drill
- Third-party security assessment
- Incident response training
- Plan effectiveness review

---

## Contact Information

### Emergency Contacts

| Role | Name | Phone | Email | Backup |
|------|------|-------|-------|--------|
| **Incident Commander** | TBD | +94 XXX XXX XXXX | TBD@email.com | TBD |
| **Technical Lead** | TBD | +94 XXX XXX XXXX | TBD@email.com | TBD |
| **Communications Lead** | TBD | +94 XXX XXX XXXX | TBD@email.com | TBD |
| **Legal Counsel** | TBD | +94 XXX XXX XXXX | TBD@email.com | TBD |
| **DPO** | TBD | +94 XXX XXX XXXX | TBD@email.com | TBD |

---

### External Contacts

| Organization | Contact | Phone | Purpose |
|--------------|---------|-------|---------|
| **Hosting Provider** | [Provider Name] | TBD | Infrastructure support |
| **Payment Processor** | [Processor Name] | TBD | Payment incident reporting |
| **Data Protection Authority** | [Country DPA] | TBD | GDPR breach reporting |
| **Law Enforcement** | [Local Cyber Crime Unit] | TBD | Criminal investigations |
| **Insurance** | [Cyber Insurance Provider] | TBD | Incident claims |

---

### Vendor Contacts

| Service | Provider | Support Contact | SLA |
|---------|----------|----------------|-----|
| **Cloud Hosting** | TBD | support@provider.com | 24/7 |
| **Database** | MySQL | enterprise-support | Business hours |
| **Email Service** | TBD | support@email.com | 24/7 |
| **Monitoring** | Sentry | support@sentry.io | 24/7 |

---

## Appendices

### Appendix A: Incident Logging Template

```
INCIDENT LOG
============
Incident ID: INC-YYYY-NNN
Start Time: [Timestamp]
Severity: [P1/P2/P3/P4]

TIMELINE:
[HH:MM] - Event description
[HH:MM] - Action taken
[HH:MM] - Result/outcome

AFFECTED SYSTEMS:
- System 1
- System 2

ACTIONS TAKEN:
1. Action 1
2. Action 2

EVIDENCE PRESERVED:
- Log files: /path/to/logs
- Screenshots: /path/to/screenshots
- Network captures: /path/to/pcap

STATUS: [Open/Contained/Resolved]
```

---

### Appendix B: Evidence Collection

**Digital Evidence Checklist:**
- [ ] System logs (last 7 days)
- [ ] Application logs (all ERROR/CRITICAL)
- [ ] Database query logs
- [ ] Network traffic captures
- [ ] User access logs
- [ ] File modification times
- [ ] Memory dumps (if applicable)
- [ ] Screenshots of anomalies

**Chain of Custody:**
```
Evidence Item: [Description]
Collected By: [Name]
Date/Time: [Timestamp]
Hash: [MD5/SHA256]
Storage Location: [Path]
Access Restricted To: [Names]
```

---

### Appendix C: Quick Reference Commands

**Common Incident Response Commands:**

```bash
# Check current connections
docker exec mysql mysql -u root -p -e "SHOW PROCESSLIST;"

# View active sessions
docker exec mysql mysql -u root -p -e "SELECT * FROM personal_access_tokens WHERE last_used_at > NOW() - INTERVAL 1 HOUR;"

# Check recent failed logins
docker exec mysql mysql -u root -p -e "SELECT * FROM login_attempts WHERE attempted_at > NOW() - INTERVAL 1 HOUR AND successful=0;"

# Review locked accounts
docker exec mysql mysql -u root -p -e "SELECT * FROM account_lockouts WHERE locked_until > NOW();"

# Check system resources
docker stats

# View recent file modifications
find /var/www -type f -mtime -1 -ls

# Network connections
docker exec app netstat -tulpn
```

---

## Document Control

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2026-01-06 | Development Team | Initial version |

**Approval:**
- [ ] Technical Lead: _________________ Date: _______
- [ ] Security Officer: _________________ Date: _______
- [ ] Executive Sponsor: _________________ Date: _______

**Next Review Date:** 2026-04-06

---

**CONFIDENTIAL - INTERNAL USE ONLY**

This document contains sensitive security information and should not be shared outside the organization without proper authorization.
