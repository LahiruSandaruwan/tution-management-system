import http from 'k6/http';
import { check, sleep, group } from 'k6';

export const options = {
  stages: [
    { duration: '2m', target: 30 },   // Morning traffic
    { duration: '3m', target: 50 },   // Peak traffic
    { duration: '3m', target: 100 },  // Busiest period
    { duration: '3m', target: 50 },   // Cooling down
    { duration: '1m', target: 0 },    // End
  ],
  thresholds: {
    'http_req_duration{scenario:dashboard}': ['p(95)<1000'],
    'http_req_duration{scenario:students}': ['p(95)<2000'],
    'http_req_duration{scenario:health}': ['p(95)<200'],
    http_req_failed: ['rate<0.02'], // < 2% failure rate
  },
};

const BASE_URL = __ENV.BASE_URL || 'http://localhost:8000';
const API_TOKEN = __ENV.API_TOKEN || '';

export default function () {
  const params = {
    headers: {
      'Authorization': `Bearer ${API_TOKEN}`,
      'Accept': 'application/json',
    },
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
      // May be 200 or 401 if no token
      check(res, { 'payments response': (r) => r.status === 200 || r.status === 401 });
    });
  }

  sleep(Math.random() * 2 + 1); // Random 1-3 seconds
}
