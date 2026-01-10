# Load Tests

## Quick Start

### Prerequisites
```bash
# Install K6
# Ubuntu/Debian
sudo apt-get install k6

# macOS
brew install k6

# Or use Docker
docker pull grafana/k6
```

### Run Tests

#### 1. Health Check Test (Simple)
```bash
# Local environment
k6 run health-check.js

# Staging environment
BASE_URL=https://staging.your-domain.com k6 run health-check.js
```

#### 2. Mixed Workload Test (Realistic)
```bash
# Generate API token first from your app
# Then run:
BASE_URL=https://staging.your-domain.com \
API_TOKEN=your-token-here \
k6 run mixed-workload.js
```

### Using Docker
```bash
# Health check
docker run --rm -i grafana/k6 run - <health-check.js

# With environment variables
docker run --rm -i \
  -e BASE_URL=https://staging.your-domain.com \
  -e API_TOKEN=your-token \
  grafana/k6 run - <mixed-workload.js
```

## Test Files

- `health-check.js` - Basic health endpoint load test (10 VUs)
- `mixed-workload.js` - Realistic mixed traffic simulation (up to 100 VUs)

## Expected Results

### Health Check
- 100% success rate
- Average response time < 50ms
- 95th percentile < 100ms
- Throughput > 100 req/s

### Mixed Workload
- < 2% failure rate (some rate limiting expected)
- Dashboard: p95 < 1s
- Students: p95 < 2s
- Health: p95 < 200ms

## Generating API Token

```bash
# Login and get token
curl -X POST https://staging.your-domain.com/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@test.com","password":"Admin@Test123"}'

# Use the token from response
```

## Monitoring During Tests

```bash
# Terminal 1: Run K6 test
k6 run mixed-workload.js

# Terminal 2: Monitor server resources
htop

# Terminal 3: Watch application logs
tail -f backend/storage/logs/laravel.log

# Terminal 4: Monitor database connections
watch -n 1 'mysql -u root -p -e "SHOW STATUS LIKE \"Threads_connected\";"'
```

## Troubleshooting

**High failure rate:**
- Check if rate limiting is too strict
- Verify API token is valid
- Check server resources (CPU, memory)

**Slow response times:**
- Enable OPcache
- Check database query performance
- Verify Redis is running
- Review application logs for errors

## More Information

See [LOAD_TESTING_GUIDE.md](../docs/LOAD_TESTING_GUIDE.md) for comprehensive testing procedures.
