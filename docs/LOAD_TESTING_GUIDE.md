# Load Testing Guide

**Estimated Time:** 1-2 hours
**Tool:** Apache Bench (ab) or K6
**Environment:** Staging
**Purpose:** Verify system handles expected load

---

## Overview

Load testing ensures your application can handle expected user traffic without performance degradation or crashes.

**Testing Goals:**
- Verify response times under load
- Identify performance bottlenecks
- Determine maximum concurrent users
- Validate database connection pooling
- Test cache effectiveness

---

## Prerequisites

### Install Load Testing Tools

**Option 1: Apache Bench (Simple, Built-in)**
```bash
# Already installed on most systems
ab -V

# If not installed:
# Ubuntu/Debian
sudo apt-get install apache2-utils

# macOS (comes with Apache)
which ab
```

**Option 2: K6 (Advanced, Recommended)**
```bash
# Ubuntu/Debian
sudo gpg -k
sudo gpg --no-default-keyring --keyring /usr/share/keyrings/k6-archive-keyring.gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys C5AD17C747E3415A3642D57D77C6C491D6AC1D69
echo "deb [signed-by=/usr/share/keyrings/k6-archive-keyring.gpg] https://dl.k6.io/deb stable main" | sudo tee /etc/apt/sources.list.d/k6.list
sudo apt-get update
sudo apt-get install k6

# macOS
brew install k6

# Verify
k6 version
```

---

## Test Scenarios

### Expected Load (Calculate First)

**Assumptions:**
- Institute: 500 students
- Teachers: 50
- Admin staff: 10
- Peak hours: 8 AM - 10 AM, 4 PM - 6 PM

**Concurrent Users:**
- Students checking schedule: 50-100
- Teachers marking attendance: 5-10
- Admin managing payments: 2-5
- **Total Peak:** 60-120 concurrent users

**Requests per Second:**
- API calls: 10-50 req/s during peak
- Dashboard loads: 5-20 req/s
- **Target:** Handle 100 req/s comfortably

---

## Test 1: Basic Health Check Load (5 minutes)

### Purpose
Verify health endpoints can handle monitoring traffic.

### Apache Bench Test
```bash
# Test health endpoint
# -n: Total requests (1000)
# -c: Concurrent requests (10)
# -t: Timeout (30s)

ab -n 1000 -c 10 -t 30 https://staging.your-domain.com/api/health

# Expected Results:
# - 0% failed requests
# - Average response < 100ms
# - Requests per second > 100
```

### Success Criteria
- ✅ 100% successful requests
- ✅ Average response time < 100ms
- ✅ Throughput > 100 req/s
- ✅ No timeouts

---

## Test 2: Authentication Load (10 minutes)

### Purpose
Test login endpoint under load (rate-limited).

### K6 Script

Create `load-tests/auth-test.js`:
```javascript
import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  stages: [
    { duration: '1m', target: 10 },  // Ramp up to 10 users
    { duration: '3m', target: 10 },  // Stay at 10 users
    { duration: '1m', target: 0 },   // Ramp down
  ],
  thresholds: {
    http_req_duration: ['p(95)<2000'], // 95% requests < 2s
    http_req_failed: ['rate<0.1'],     // < 10% failure rate
  },
};

export default function () {
  const payload = JSON.stringify({
    email: 'test@example.com',
    password: 'Test@Password123',
  });

  const params = {
    headers: {
      'Content-Type': 'application/json',
    },
  };

  const res = http.post(
    'https://staging.your-domain.com/api/auth/login',
    payload,
    params
  );

  check(res, {
    'status is 200 or 401': (r) => r.status === 200 || r.status === 401,
    'response time < 2s': (r) => r.timings.duration < 2000,
  });

  sleep(1); // Wait 1 second between requests
}
```

### Run Test
```bash
k6 run load-tests/auth-test.js
```

### Success Criteria
- ✅ < 10% failed requests (some may hit rate limit)
- ✅ 95th percentile < 2 seconds
- ✅ No server errors (500)
- ✅ Rate limiting working (429 responses expected)

---

## Test 3: Dashboard Load (15 minutes)

### Purpose
Test dashboard API under realistic load.

### K6 Script

Create `load-tests/dashboard-test.js`:
```javascript
import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  stages: [
    { duration: '2m', target: 50 },   // Ramp to 50 users
    { duration: '5m', target: 50 },   // Maintain 50 users
    { duration: '2m', target: 100 },  // Spike to 100 users
    { duration: '3m', target: 100 },  // Maintain spike
    { duration: '2m', target: 0 },    // Ramp down
  ],
  thresholds: {
    http_req_duration: ['p(95)<1000'], // 95% < 1s
    http_req_failed: ['rate<0.01'],    // < 1% failure
  },
};

const API_TOKEN = __ENV.API_TOKEN || 'your-test-token';

export default function () {
  const params = {
    headers: {
      'Authorization': `Bearer ${API_TOKEN}`,
      'Accept': 'application/json',
    },
  };

  // Dashboard stats request
  const res = http.get(
    'https://staging.your-domain.com/api/dashboard/stats',
    params
  );

  check(res, {
    'status is 200': (r) => r.status === 200,
    'response time < 1s': (r) => r.timings.duration < 1000,
    'has statistics': (r) => {
      const body = JSON.parse(r.body);
      return body.data && body.data.total_students !== undefined;
    },
  });

  sleep(Math.random() * 3 + 2); // Random 2-5 seconds
}
```

### Run Test
```bash
# Generate API token first
# Then run test
API_TOKEN="your-token-here" k6 run load-tests/dashboard-test.js
```

### Success Criteria
- ✅ < 1% failed requests
- ✅ 95th percentile < 1 second
- ✅ Average response time < 500ms
- ✅ No database connection errors

---

## Test 4: Mixed Workload (20 minutes)

### Purpose
Simulate realistic mixed usage patterns.

### K6 Script

Create `load-tests/mixed-workload.js`:
```javascript
import http from 'k6/http';
import { check, sleep, group } from 'k6';

export const options = {
  stages: [
    { duration: '3m', target: 30 },   // Morning traffic
    { duration: '5m', target: 50 },   // Peak traffic
    { duration: '5m', target: 100 },  // Busiest period
    { duration: '5m', target: 50 },   // Cooling down
    { duration: '2m', target: 0 },    // End
  ],
  thresholds: {
    'http_req_duration{scenario:dashboard}': ['p(95)<1000'],
    'http_req_duration{scenario:students}': ['p(95)<2000'],
    'http_req_duration{scenario:health}': ['p(95)<200'],
  },
};

const BASE_URL = 'https://staging.your-domain.com';
const API_TOKEN = __ENV.API_TOKEN || 'your-test-token';

export default function () {
  const params = {
    headers: {
      'Authorization': `Bearer ${API_TOKEN}`,
      'Accept': 'application/json',
    },
    tags: { scenario: 'mixed' },
  };

  // Scenario 1: Check dashboard (40% of traffic)
  if (Math.random() < 0.4) {
    group('Dashboard', () => {
      const res = http.get(`${BASE_URL}/api/dashboard/stats`, {
        ...params,
        tags: { scenario: 'dashboard' },
      });
      check(res, { 'dashboard ok': (r) => r.status === 200 });
    });
  }

  // Scenario 2: List students (30% of traffic)
  else if (Math.random() < 0.7) {
    group('Students', () => {
      const res = http.get(`${BASE_URL}/api/students`, {
        ...params,
        tags: { scenario: 'students' },
      });
      check(res, { 'students ok': (r) => r.status === 200 });
    });
  }

  // Scenario 3: Health check (20% of traffic)
  else if (Math.random() < 0.9) {
    group('Health', () => {
      const res = http.get(`${BASE_URL}/api/health/detailed`, {
        tags: { scenario: 'health' },
      });
      check(res, { 'health ok': (r) => r.status === 200 });
    });
  }

  // Scenario 4: View payments (10% of traffic)
  else {
    group('Payments', () => {
      const res = http.get(`${BASE_URL}/api/payments`, {
        ...params,
        tags: { scenario: 'payments' },
      });
      check(res, { 'payments ok': (r) => r.status === 200 });
    });
  }

  sleep(Math.random() * 2 + 1); // Random 1-3 seconds
}
```

### Run Test
```bash
API_TOKEN="your-token-here" k6 run load-tests/mixed-workload.js
```

### Success Criteria
- ✅ All scenarios pass thresholds
- ✅ < 1% overall failure rate
- ✅ CPU usage < 70%
- ✅ Memory usage stable
- ✅ Database connections < 100

---

## Test 5: Stress Test (Find Breaking Point)

### Purpose
Find the maximum load before system degrades.

### K6 Script

Create `load-tests/stress-test.js`:
```javascript
import http from 'k6/http';
import { check } from 'k6';

export const options = {
  stages: [
    { duration: '2m', target: 100 },   // Normal load
    { duration: '5m', target: 100 },   // Stay at normal
    { duration: '2m', target: 200 },   // Double load
    { duration: '5m', target: 200 },   // Maintain
    { duration: '2m', target: 300 },   // Triple load
    { duration: '5m', target: 300 },   // Maintain
    { duration: '10m', target: 0 },    // Recovery
  ],
  thresholds: {
    http_req_failed: ['rate<0.05'], // < 5% failure acceptable in stress test
  },
};

const BASE_URL = 'https://staging.your-domain.com';
const API_TOKEN = __ENV.API_TOKEN || 'your-test-token';

export default function () {
  const res = http.get(`${BASE_URL}/api/health`, {
    headers: {
      'Authorization': `Bearer ${API_TOKEN}`,
    },
  });

  check(res, {
    'status is 200': (r) => r.status === 200,
  });
}
```

### Run Test
```bash
API_TOKEN="your-token-here" k6 run load-tests/stress-test.js
```

### Monitor During Test
```bash
# Terminal 1: System resources
htop

# Terminal 2: Database connections
mysql -u root -p -e "SHOW STATUS LIKE 'Threads_connected';" -r -N

# Terminal 3: Application logs
tail -f storage/logs/laravel.log
```

### Success Criteria
- ✅ System handles 100 concurrent users easily
- ✅ Graceful degradation at higher loads
- ✅ No crashes or data corruption
- ✅ Recovery after load decreases

---

## Monitoring During Tests

### System Metrics to Watch

**Server Resources:**
```bash
# CPU, Memory, Disk
htop

# Or
top

# Disk I/O
iostat -x 2
```

**Database:**
```bash
# MySQL connections
watch -n 1 'mysql -u root -p -e "SHOW STATUS LIKE \"Threads_connected\";"'

# Slow queries
mysql -u root -p -e "SHOW FULL PROCESSLIST;"
```

**Application:**
```bash
# Laravel logs
tail -f storage/logs/laravel.log

# Queue workers
supervisorctl status

# Redis
redis-cli INFO stats
```

**Network:**
```bash
# Network connections
netstat -an | grep :443 | wc -l

# Bandwidth
iftop
```

---

## Analyzing Results

### K6 Output

Example output:
```
scenarios: (100.00%) 1 scenario, 100 max VUs, 30m30s max duration

✓ status is 200
✓ response time < 1s

checks.........................: 100.00% ✓ 50000 ✗ 0
data_received..................: 75 MB   125 kB/s
data_sent......................: 5.0 MB  8.3 kB/s
http_req_blocked...............: avg=1.2ms   min=0s   med=1ms   max=50ms   p(95)=2ms
http_req_connecting............: avg=0.5ms   min=0s   med=0s    max=20ms   p(95)=1ms
http_req_duration..............: avg=250ms   min=50ms med=200ms max=2s     p(95)=800ms
http_req_failed................: 0.00%   ✓ 0     ✗ 50000
http_req_receiving.............: avg=1ms     min=0s   med=0s    max=10ms   p(95)=2ms
http_req_sending...............: avg=0.5ms   min=0s   med=0s    max=5ms    p(95)=1ms
http_req_tls_handshaking.......: avg=0.7ms   min=0s   med=0s    max=30ms   p(95)=2ms
http_req_waiting...............: avg=248ms   min=48ms med=198ms max=1.99s  p(95)=798ms
http_reqs......................: 50000   83.33/s
iteration_duration.............: avg=1.25s   min=1.05s med=1.2s max=3s     p(95)=1.8s
iterations.....................: 50000   83.33/s
vus............................: 100     min=0   max=100
vus_max........................: 100     min=100 max=100
```

### Key Metrics

**Response Time:**
- `p(95) < 1s` ✅ Good
- `p(95) 1-2s` ⚠️ Acceptable
- `p(95) > 2s` ❌ Needs optimization

**Failure Rate:**
- `< 0.1%` ✅ Excellent
- `0.1-1%` ⚠️ Acceptable
- `> 1%` ❌ Investigate

**Throughput:**
- Target: 50-100 req/s
- Actual: _____ req/s
- Status: ☐ Pass ☐ Fail

---

## Performance Optimization

### If Tests Fail

**Slow Response Times:**
1. Enable OPcache
   ```bash
   # Verify OPcache enabled
   php -i | grep opcache
   ```

2. Optimize database queries
   ```bash
   # Enable slow query log
   mysql -u root -p -e "SET GLOBAL slow_query_log = 'ON';"
   ```

3. Increase cache usage
   ```php
   // Cache dashboard stats for 5 minutes
   Cache::remember('dashboard_stats', 300, function() {
       // expensive query
   });
   ```

**High Memory Usage:**
1. Optimize PHP memory limit
2. Clear unnecessary caches
3. Review eager loading in Eloquent

**Database Connection Issues:**
1. Increase connection pool size
   ```env
   DB_CONNECTION_POOL=20
   ```

2. Enable connection pooling in Laravel

---

## Load Testing Checklist

- [ ] Apache Bench or K6 installed
- [ ] Staging environment ready
- [ ] API tokens generated
- [ ] Baseline metrics recorded
- [ ] Test 1: Health check load ✅
- [ ] Test 2: Authentication load ✅
- [ ] Test 3: Dashboard load ✅
- [ ] Test 4: Mixed workload ✅
- [ ] Test 5: Stress test ✅
- [ ] Results documented
- [ ] Performance issues identified
- [ ] Optimizations applied
- [ ] Re-tested after optimizations
- [ ] Production capacity planned

---

## Test Results Template

### Load Test Report

**Date:** __________
**Environment:** Staging
**Tester:** __________

| Test | VUs | Req/s | Avg Response | P95 Response | Failure Rate | Status |
|------|-----|-------|--------------|--------------|--------------|--------|
| Health Check | 10 | | | | | ☐ Pass ☐ Fail |
| Authentication | 10 | | | | | ☐ Pass ☐ Fail |
| Dashboard | 50 | | | | | ☐ Pass ☐ Fail |
| Mixed Workload | 100 | | | | | ☐ Pass ☐ Fail |
| Stress Test | 300 | | | | | ☐ Pass ☐ Fail |

**Bottlenecks Identified:**
- _______________________________________________________
- _______________________________________________________

**Recommendations:**
- _______________________________________________________
- _______________________________________________________

**Capacity Planning:**
- Current max users: ___________
- Expected production users: ___________
- Headroom: _________ % ☐ Sufficient ☐ Insufficient

---

## Production Capacity Planning

### Based on Test Results

If tests show:
- 100 concurrent users handled easily
- Response times under thresholds
- < 1% failure rate

**Then production can handle:**
- 50-70 concurrent users comfortably (70% of tested capacity)
- 80-90 concurrent users during peak (90% of tested capacity)
- 100+ concurrent users requires scaling

### Scaling Recommendations

**Horizontal Scaling (Add Servers):**
- Load balancer + 2-3 application servers
- Read replicas for database
- Redis cluster for caching

**Vertical Scaling (Bigger Servers):**
- Increase CPU/RAM on current server
- Optimize database server resources

---

**Estimated Testing Time:** 2-3 hours
**Status:** ✅ **READY TO TEST**

---

**Document Version:** 1.0
**Last Updated:** 2026-01-10
