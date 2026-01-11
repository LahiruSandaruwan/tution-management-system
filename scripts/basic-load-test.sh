#!/bin/bash
# Basic Load Testing with curl
# Alternative to K6 for quick performance baseline

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
BASE_URL="${BASE_URL:-http://127.0.0.1:8000}"
CONCURRENT_REQUESTS="${CONCURRENT_REQUESTS:-50}"
TOTAL_REQUESTS="${TOTAL_REQUESTS:-500}"

echo -e "${BLUE}=== Basic Load Test ===${NC}"
echo "Base URL: $BASE_URL"
echo "Concurrent Requests: $CONCURRENT_REQUESTS"
echo "Total Requests: $TOTAL_REQUESTS"
echo "Date: $(date)"
echo ""

# Test 1: Health Endpoint Performance
echo -e "${BLUE}Test 1: Health Endpoint Load Test${NC}"
echo "Testing: GET /api/health with $CONCURRENT_REQUESTS concurrent requests"

START_TIME=$(date +%s%N)
SUCCESS=0
FAILED=0

# Run concurrent requests
for i in $(seq 1 $CONCURRENT_REQUESTS); do
    {
        status=$(curl -o /dev/null -s -w '%{http_code}' "$BASE_URL/api/health" 2>/dev/null)
        if [ "$status" = "200" ]; then
            echo "200" >> /tmp/load-test-results.txt
        else
            echo "ERR" >> /tmp/load-test-results.txt
        fi
    } &
done

# Wait for all background jobs
wait

END_TIME=$(date +%s%N)
DURATION=$(( ($END_TIME - $START_TIME) / 1000000 ))

# Count results
SUCCESS=$(grep -c "200" /tmp/load-test-results.txt 2>/dev/null || echo 0)
FAILED=$(grep -c "ERR" /tmp/load-test-results.txt 2>/dev/null || echo 0)
rm -f /tmp/load-test-results.txt

echo -e "${GREEN}Results:${NC}"
echo "  Successful: $SUCCESS"
echo "  Failed: $FAILED"
echo "  Total Time: ${DURATION}ms"
echo "  Avg Time/Request: $(( $DURATION / $CONCURRENT_REQUESTS ))ms"
echo "  Requests/Second: $(echo "scale=2; $CONCURRENT_REQUESTS * 1000 / $DURATION" | bc 2>/dev/null || echo "N/A")"
echo ""

# Test 2: Sequential Request Timing
echo -e "${BLUE}Test 2: Sequential Request Performance${NC}"
echo "Measuring response times for 10 sequential requests"

TIMES=()
for i in {1..10}; do
    TIME=$(curl -o /dev/null -s -w '%{time_total}' "$BASE_URL/api/health" 2>/dev/null)
    TIME_MS=$(echo "$TIME * 1000" | bc | cut -d'.' -f1)
    TIMES+=($TIME_MS)
    echo "  Request $i: ${TIME_MS}ms"
done

# Calculate average
SUM=0
for t in "${TIMES[@]}"; do
    SUM=$(($SUM + $t))
done
AVG=$(($SUM / 10))

echo -e "${GREEN}Average Response Time: ${AVG}ms${NC}"
echo ""

# Test 3: Sustained Load Test
echo -e "${BLUE}Test 3: Sustained Load (100 requests over 10 seconds)${NC}"

rm -f /tmp/sustained-load-results.txt
START_TIME=$(date +%s)

for i in {1..100}; do
    {
        start=$(date +%s%N)
        status=$(curl -o /dev/null -s -w '%{http_code}' "$BASE_URL/api/health" 2>/dev/null)
        end=$(date +%s%N)
        duration=$(( ($end - $start) / 1000000 ))
        echo "$status,$duration" >> /tmp/sustained-load-results.txt
    } &

    # Limit concurrent connections to 10
    if [ $(($i % 10)) -eq 0 ]; then
        wait
    fi
done

wait
END_TIME=$(date +%s)
TOTAL_DURATION=$(($END_TIME - $START_TIME))

SUCCESS=$(grep -c "^200," /tmp/sustained-load-results.txt 2>/dev/null || echo 0)
FAILED=$(( 100 - $SUCCESS ))

# Calculate response time stats
cat /tmp/sustained-load-results.txt | cut -d',' -f2 | sort -n > /tmp/times.txt
MIN=$(head -1 /tmp/times.txt)
MAX=$(tail -1 /tmp/times.txt)
MEDIAN=$(sed -n '50p' /tmp/times.txt)
P95=$(sed -n '95p' /tmp/times.txt)

echo -e "${GREEN}Results:${NC}"
echo "  Total Time: ${TOTAL_DURATION}s"
echo "  Successful: $SUCCESS/100"
echo "  Failed: $FAILED/100"
echo "  Throughput: $(echo "scale=2; 100 / $TOTAL_DURATION" | bc) req/s"
echo "  Response Times:"
echo "    Min: ${MIN}ms"
echo "    Median: ${MEDIAN}ms"
echo "    P95: ${P95}ms"
echo "    Max: ${MAX}ms"

rm -f /tmp/sustained-load-results.txt /tmp/times.txt

echo ""
echo -e "${GREEN}=== Load Test Complete ===${NC}"

# Pass/Fail Criteria
echo ""
echo -e "${BLUE}Performance Targets:${NC}"
if [ "$AVG" -lt 500 ]; then
    echo -e "  ${GREEN}✓ Avg Response Time: ${AVG}ms < 500ms target${NC}"
else
    echo -e "  ${YELLOW}⚠ Avg Response Time: ${AVG}ms > 500ms target${NC}"
fi

if [ "$P95" -lt 1000 ]; then
    echo -e "  ${GREEN}✓ P95 Response Time: ${P95}ms < 1000ms target${NC}"
else
    echo -e "  ${YELLOW}⚠ P95 Response Time: ${P95}ms > 1000ms target${NC}"
fi

SUCCESS_RATE=$(echo "scale=2; $SUCCESS * 100 / 100" | bc)
if (( $(echo "$SUCCESS_RATE >= 99" | bc -l) )); then
    echo -e "  ${GREEN}✓ Success Rate: ${SUCCESS_RATE}% >= 99% target${NC}"
else
    echo -e "  ${YELLOW}⚠ Success Rate: ${SUCCESS_RATE}% < 99% target${NC}"
fi

echo ""
echo "Note: For comprehensive load testing, install K6 and run:"
echo "  k6 run load-tests/mixed-workload.js"
